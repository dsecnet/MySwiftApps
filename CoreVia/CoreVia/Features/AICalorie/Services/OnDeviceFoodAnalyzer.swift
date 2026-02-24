//
//  OnDeviceFoodAnalyzer.swift
//  CoreVia
//
//  Tam on-device qida analiz pipeline-i
//  Backend ai_food_service.py ilə eyni axın:
//  1. Şəkil → YOLOv8 detect → bbox-lar
//  2. Hər bbox → EfficientNet classify → food_name
//  3. food_name → USDA database → kalori/makro
//  4. Aggregate → AICalorieResult
//
//  Heç bir network lazım deyil — tam offline işləyir
//

import UIKit

class OnDeviceFoodAnalyzer {
    static let shared = OnDeviceFoodAnalyzer()

    private let detector = CoreMLFoodDetector.shared
    private let classifier = CoreMLFoodClassifier.shared
    private let database = FoodDatabaseService.shared

    private init() {}

    // MARK: - Full Analysis Pipeline

    /// Şəkili analiz edir və AICalorieResult qaytarır (eyni struct — UI dəyişiklik lazım deyil!)
    func analyzeFood(image: UIImage) async throws -> AICalorieResult {
        print("🔍 OnDeviceFoodAnalyzer: Analiz başlayır...")

        // Step 1: Detect food regions
        let detections = try await detector.detectFoods(in: image)
        print("🔍 OnDeviceFoodAnalyzer: \(detections.count) detection tapıldı")

        // Step 2+3: Classify each detection + DB lookup
        var detectedFoods: [DetectedFood] = []
        var totalCalories: Double = 0
        var totalProtein: Double = 0
        var totalCarbs: Double = 0
        var totalFat: Double = 0
        var totalConfidence: Double = 0

        for detection in detections {
            do {
                // Classify the cropped image
                let classification = try await classifier.classify(image: detection.croppedImage)
                print("🔍 Classification: \(classification.displayName) (\(classification.confidence))")

                // Lookup nutrition from local database
                let nutrition = database.getNutrition(for: classification.displayName)
                print("🔍 Nutrition: \(nutrition.foodName) - \(nutrition.calories) kcal")

                // Confidence = ağırlıqlı ortalama (vurma çox pesimist idi)
                // Classification-a 50% ağırlıq (ən vacib), Detection 30%, DB match 20%
                let combinedConfidence = max(
                    Double(detection.confidence) * 0.3
                    + Double(classification.confidence) * 0.5
                    + nutrition.confidence * 0.2,
                    0.3  // minimum 30% floor
                )

                let food = DetectedFood(
                    id: UUID().uuidString,
                    name: nutrition.foodName,
                    calories: Double(nutrition.calories),
                    protein: nutrition.protein,
                    carbs: nutrition.carbs,
                    fat: nutrition.fat,
                    portionGrams: nutrition.portionGrams,
                    confidence: combinedConfidence
                )

                detectedFoods.append(food)
                totalCalories += Double(nutrition.calories)
                totalProtein += nutrition.protein
                totalCarbs += nutrition.carbs
                totalFat += nutrition.fat
                totalConfidence += combinedConfidence
            } catch {
                // Classifier xəta versə — bu detection-ı atla, digərlərini davam et
                print("⚠️ Classification xətası: \(error.localizedDescription)")
                continue
            }
        }

        // Heç bir food tapılmadısa — xəta at (backend fallback işə düşəcək)
        guard !detectedFoods.isEmpty else {
            print("⚠️ OnDeviceFoodAnalyzer: Heç bir yemək classify olunmadı")
            throw CoreMLError.predictionFailed("Şəkildə yemək aşkar edilmədi")
        }

        // Average confidence, max 0.95 (backend ile eyni)
        let avgConfidence = min(totalConfidence / Double(detectedFoods.count), 0.95)

        print("✅ OnDeviceFoodAnalyzer: \(detectedFoods.count) yemək tapıldı, \(Int(totalCalories)) kcal")

        return AICalorieResult(
            foods: detectedFoods,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            confidence: avgConfidence,
            imageUrl: nil  // On-device — server image URL yoxdur
        )
    }
}
