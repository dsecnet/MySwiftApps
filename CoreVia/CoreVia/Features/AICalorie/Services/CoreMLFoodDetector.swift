//
//  CoreMLFoodDetector.swift
//  CoreVia
//
//  YOLOv8n Core ML modeli ile on-device yemek detection
//  Model yuklenmedikde → butun sekil bir yemek kimi qaytarilir (fallback)
//  Model yuklenirse → Vision framework ile detection + fallback
//

import Vision
import UIKit
import CoreML
import os.log

// MARK: - Detection Result

struct FoodDetection {
    let className: String
    let confidence: Float
    let boundingBox: CGRect       // Normalized coordinates (0-1)
    let croppedImage: CGImage
}

// MARK: - Core ML Error

enum CoreMLError: LocalizedError {
    case invalidImage
    case modelLoadFailed
    case predictionFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Şəkil emal edilə bilmədi"
        case .modelLoadFailed: return "ML model yüklənmədi"
        case .predictionFailed(let msg): return "Proqnoz uğursuz: \(msg)"
        }
    }
}

// MARK: - Detector

class CoreMLFoodDetector {
    static let shared = CoreMLFoodDetector()

    private var mlModel: MLModel?
    private var visionModel: VNCoreMLModel?
    private let confidenceThreshold: Float = 0.25
    private let iouThreshold: Float = 0.5
    private var modelLoaded = false

    private init() {
        loadModel()
    }

    private func loadModel() {
        let config = MLModelConfiguration()
        config.computeUnits = .all

        // 1. Auto-generated class
        do {
            let detector = try FoodDetector(configuration: config)
            mlModel = detector.model
            visionModel = try? VNCoreMLModel(for: detector.model)
            modelLoaded = true
            AppLogger.ml.info("FoodDetector Core ML model yuklendi")
            return
        } catch {
            AppLogger.ml.warning("FoodDetector auto-generated xetasi: \(error.localizedDescription)")
        }

        // 2. Bundle fallback
        if let url = Bundle.main.url(forResource: "FoodDetector", withExtension: "mlmodelc") {
            do {
                mlModel = try MLModel(contentsOf: url, configuration: config)
                visionModel = try? VNCoreMLModel(for: mlModel!)
                modelLoaded = true
                AppLogger.ml.info("FoodDetector yuklendi (bundle .mlmodelc)")
                return
            } catch {
                AppLogger.ml.warning("FoodDetector .mlmodelc xetasi: \(error.localizedDescription)")
            }
        }

        // 3. Runtime compile fallback
        if let url = Bundle.main.url(forResource: "FoodDetector", withExtension: "mlpackage") {
            do {
                let compiledUrl = try MLModel.compileModel(at: url)
                mlModel = try MLModel(contentsOf: compiledUrl, configuration: config)
                visionModel = try? VNCoreMLModel(for: mlModel!)
                modelLoaded = true
                AppLogger.ml.info("FoodDetector yuklendi (runtime compile)")
                return
            } catch {
                AppLogger.ml.warning("FoodDetector runtime compile xetasi: \(error.localizedDescription)")
            }
        }

        AppLogger.ml.warning("FoodDetector model tapilmadi -- fallback mode isleyecek")
        mlModel = nil
        visionModel = nil
        modelLoaded = false
    }

    // MARK: - Detection (HER ZAMAN en azi 1 netice qaytarir!)

    func detectFoods(in image: UIImage) async throws -> [FoodDetection] {
        guard let cgImage = image.cgImage else {
            throw CoreMLError.invalidImage
        }

        // Model yuklenmedikde → butun sekili bir yemek kimi qaytarirıq
        guard modelLoaded, mlModel != nil else {
            AppLogger.ml.info("FoodDetector: Model yoxdur, full image fallback istifade olunur")
            return [fullImageFallback(cgImage)]
        }

        // 1. Vision framework ile cehd et
        do {
            let visionResult = try await detectWithVision(cgImage: cgImage)
            if !visionResult.isEmpty {
                AppLogger.ml.info("FoodDetector: Vision ile \(visionResult.count) yemek tapildi")
                return visionResult
            }
        } catch {
            AppLogger.ml.warning("FoodDetector Vision xetasi: \(error.localizedDescription)")
        }

        // 2. Raw model prediction + manual NMS
        do {
            let rawResult = try await detectWithRawModel(cgImage: cgImage)
            if !rawResult.isEmpty {
                AppLogger.ml.info("FoodDetector: Raw model ile \(rawResult.count) yemek tapildi")
                return rawResult
            }
        } catch {
            AppLogger.ml.warning("FoodDetector raw model xetasi: \(error.localizedDescription)")
        }

        // 3. Her sey ugursuz olsa da — full image fallback (HEC VAXT bos array qaytarmiriq!)
        AppLogger.ml.info("FoodDetector: Hec bir detection tapilmadi, full image fallback")
        return [fullImageFallback(cgImage)]
    }

    // MARK: - Vision Framework Detection

    private func detectWithVision(cgImage: CGImage) async throws -> [FoodDetection] {
        guard let vModel = visionModel else { return [] }

        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            let resumeOnce: (Result<[FoodDetection], Error>) -> Void = { result in
                guard !hasResumed else { return }
                hasResumed = true
                switch result {
                case .success(let detections):
                    continuation.resume(returning: detections)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            let request = VNCoreMLRequest(model: vModel) { [weak self] request, error in
                guard let self = self else {
                    resumeOnce(.success([]))
                    return
                }

                if error != nil {
                    resumeOnce(.success([]))
                    return
                }

                // VNRecognizedObjectObservation — NMS tetbiq olunmus model
                if let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty {
                    var detections: [FoodDetection] = []
                    let imageWidth = CGFloat(cgImage.width)
                    let imageHeight = CGFloat(cgImage.height)

                    for observation in results {
                        guard observation.confidence >= self.confidenceThreshold else { continue }

                        let topLabel = observation.labels.first?.identifier ?? "food"
                        let bbox = observation.boundingBox

                        let cropRect = CGRect(
                            x: bbox.origin.x * imageWidth,
                            y: (1 - bbox.origin.y - bbox.height) * imageHeight,
                            width: bbox.width * imageWidth,
                            height: bbox.height * imageHeight
                        ).integral

                        let imageBounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
                        let clampedRect = cropRect.intersection(imageBounds)

                        guard !clampedRect.isEmpty,
                              clampedRect.width > 10,
                              clampedRect.height > 10,
                              let croppedCG = cgImage.cropping(to: clampedRect) else { continue }

                        detections.append(FoodDetection(
                            className: topLabel,
                            confidence: observation.confidence,
                            boundingBox: bbox,
                            croppedImage: croppedCG
                        ))
                    }

                    resumeOnce(.success(detections))
                    return
                }

                // Vision basa dusmedikde bos array qaytaririq
                resumeOnce(.success([]))
            }

            request.imageCropAndScaleOption = .scaleFill

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                resumeOnce(.success([]))
            }
        }
    }

    // MARK: - Raw Model Detection (YOLOv8 manual NMS)

    private func detectWithRawModel(cgImage: CGImage) async throws -> [FoodDetection] {
        guard let model = mlModel else {
            return []
        }

        // Sekili CVPixelBuffer-e cevir (640x640)
        guard let pixelBuffer = cgImage.toPixelBuffer(width: 640, height: 640) else {
            return []
        }

        let input = FoodDetectorInput(
            image: pixelBuffer,
            iouThreshold: Double(iouThreshold),
            confidenceThreshold: Double(confidenceThreshold)
        )

        let output = try model.prediction(from: input)

        // Raw output: confidence [numBoxes x numClasses] ve coordinates [numBoxes x 4]
        guard let confidenceArray = output.featureValue(for: "confidence")?.multiArrayValue,
              let coordinatesArray = output.featureValue(for: "coordinates")?.multiArrayValue else {
            return []
        }

        let numBoxes = confidenceArray.shape[0].intValue
        let numClasses = confidenceArray.shape.count > 1 ? confidenceArray.shape[1].intValue : 1

        AppLogger.ml.debug("FoodDetector raw: \(numBoxes) boxes, \(numClasses) classes")

        var rawDetections: [(box: CGRect, confidence: Float, classIdx: Int)] = []

        for i in 0..<numBoxes {
            var maxConf: Float = 0
            var maxClass: Int = 0

            if numClasses > 1 {
                for c in 0..<numClasses {
                    let idx = [NSNumber(value: i), NSNumber(value: c)]
                    let conf = confidenceArray[idx].floatValue
                    if conf > maxConf {
                        maxConf = conf
                        maxClass = c
                    }
                }
            } else {
                let idx = [NSNumber(value: i), NSNumber(value: 0)]
                maxConf = confidenceArray[idx].floatValue
                maxClass = 0
            }

            guard maxConf >= confidenceThreshold else { continue }

            // Coordinates: [cx, cy, w, h] normalized
            let cx = coordinatesArray[[NSNumber(value: i), NSNumber(value: 0)]].floatValue
            let cy = coordinatesArray[[NSNumber(value: i), NSNumber(value: 1)]].floatValue
            let w = coordinatesArray[[NSNumber(value: i), NSNumber(value: 2)]].floatValue
            let h = coordinatesArray[[NSNumber(value: i), NSNumber(value: 3)]].floatValue

            let box = CGRect(
                x: CGFloat(cx - w / 2),
                y: CGFloat(cy - h / 2),
                width: CGFloat(w),
                height: CGFloat(h)
            )

            rawDetections.append((box: box, confidence: maxConf, classIdx: maxClass))
        }

        AppLogger.ml.debug("FoodDetector raw: \(rawDetections.count) detections (threshold >\(self.confidenceThreshold))")

        // NMS tetbiq et
        let nmsDetections = nonMaxSuppression(rawDetections, iouThreshold: iouThreshold)

        if nmsDetections.isEmpty {
            return []
        }

        // CGImage crop-la
        var detections: [FoodDetection] = []
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)

        for det in nmsDetections {
            let cropRect = CGRect(
                x: det.box.origin.x * imageWidth,
                y: det.box.origin.y * imageHeight,
                width: det.box.width * imageWidth,
                height: det.box.height * imageHeight
            ).integral

            let imageBounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
            let clampedRect = cropRect.intersection(imageBounds)

            guard !clampedRect.isEmpty,
                  clampedRect.width > 10,
                  clampedRect.height > 10,
                  let croppedCG = cgImage.cropping(to: clampedRect) else { continue }

            detections.append(FoodDetection(
                className: "food",
                confidence: det.confidence,
                boundingBox: det.box,
                croppedImage: croppedCG
            ))
        }

        return detections
    }

    // MARK: - NMS (Non-Maximum Suppression)

    private func nonMaxSuppression(
        _ detections: [(box: CGRect, confidence: Float, classIdx: Int)],
        iouThreshold: Float
    ) -> [(box: CGRect, confidence: Float, classIdx: Int)] {
        let sorted = detections.sorted { $0.confidence > $1.confidence }
        var selected: [(box: CGRect, confidence: Float, classIdx: Int)] = []

        for det in sorted {
            var shouldSelect = true
            for sel in selected {
                if computeIoU(det.box, sel.box) > iouThreshold {
                    shouldSelect = false
                    break
                }
            }
            if shouldSelect {
                selected.append(det)
            }
        }
        return selected
    }

    private func computeIoU(_ a: CGRect, _ b: CGRect) -> Float {
        let intersection = a.intersection(b)
        guard !intersection.isNull else { return 0 }
        let intersectionArea = intersection.width * intersection.height
        let unionArea = a.width * a.height + b.width * b.height - intersectionArea
        guard unionArea > 0 else { return 0 }
        return Float(intersectionArea / unionArea)
    }

    // MARK: - Fallback

    private func fullImageFallback(_ cgImage: CGImage) -> FoodDetection {
        FoodDetection(
            className: "food",
            confidence: 0.5,
            boundingBox: CGRect(x: 0, y: 0, width: 1, height: 1),
            croppedImage: cgImage
        )
    }
}

// MARK: - CGImage → CVPixelBuffer

extension CGImage {
    func toPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width, height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }

        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return buffer
    }
}
