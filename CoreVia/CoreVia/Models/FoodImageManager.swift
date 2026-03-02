//
//  FoodImageManager.swift
//  CoreVia
//
//  Qida şəkillərini backend-ə upload etmə
//

import SwiftUI
import UIKit
import os.log

class FoodImageManager: ObservableObject {

    static let shared = FoodImageManager()

    @Published var lastError: String?

    private let api = APIService.shared
    private let imageCache = NSCache<NSString, UIImage>()

    private init() {
        imageCache.countLimit = 50
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    // MARK: - Save (Upload) Image to Backend
    func saveImage(_ image: UIImage, forEntryId entryId: String) {
        guard let resizedImage = resizeImage(image, targetSize: CGSize(width: 500, height: 500)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            AppLogger.food.error("Image resize failed for entry: \(entryId)")
            lastError = "Image resize failed for entry: \(entryId)"
            return
        }

        // Cache locally
        imageCache.setObject(resizedImage, forKey: entryId as NSString)

        Task {
            do {
                let _ = try await api.uploadImage(
                    endpoint: "/api/v1/food/\(entryId)/image",
                    imageData: imageData,
                    fieldName: "file",
                    fileName: "food_\(entryId).jpg"
                )
            } catch {
                AppLogger.food.error("Food image upload xetasi: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Load Image
    func loadImage(forEntryId entryId: String) -> UIImage? {
        return imageCache.object(forKey: entryId as NSString)
    }

    // MARK: - Load Image from URL
    func loadImage(from urlString: String, forEntryId entryId: String) {
        if imageCache.object(forKey: entryId as NSString) != nil { return }

        let baseURL = APIService.shared.baseURL
        let fullURL: String
        if urlString.hasPrefix("http") {
            fullURL = urlString
        } else {
            fullURL = baseURL + urlString
        }

        guard let url = URL(string: fullURL) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.imageCache.setObject(image, forKey: entryId as NSString)
                    }
                }
            } catch {
                AppLogger.food.error("Image download xetasi: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Delete Image
    func deleteImage(forEntryId entryId: String) {
        imageCache.removeObject(forKey: entryId as NSString)
    }

    // MARK: - Helper: Resize Image
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        if scaleFactor >= 1.0 { return image }

        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }

        return scaledImage
    }
}
