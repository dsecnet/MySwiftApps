//
//  FoodImageManager.swift
//  CoreVia
//
//  Qida şəkillərini backend-ə upload etmə
//

import SwiftUI
import UIKit

class FoodImageManager: ObservableObject {

    static let shared = FoodImageManager()

    private let api = APIService.shared
    private var imageCache: [String: UIImage] = [:]

    // MARK: - Save (Upload) Image to Backend
    func saveImage(_ image: UIImage, forEntryId entryId: String) {
        guard let resizedImage = resizeImage(image, targetSize: CGSize(width: 500, height: 500)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            return
        }

        // Cache locally
        imageCache[entryId] = resizedImage

        Task {
            do {
                let _ = try await api.uploadImage(
                    endpoint: "/api/v1/food/\(entryId)/image",
                    imageData: imageData,
                    fieldName: "file",
                    fileName: "food_\(entryId).jpg"
                )
            } catch {
                print("Food image upload xətası: \(error)")
            }
        }
    }

    // MARK: - Load Image
    func loadImage(forEntryId entryId: String) -> UIImage? {
        return imageCache[entryId]
    }

    // MARK: - Load Image from URL
    func loadImage(from urlString: String, forEntryId entryId: String) {
        if imageCache[entryId] != nil { return }

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
                        self.imageCache[entryId] = image
                    }
                }
            } catch {
                print("Image download xətası: \(error)")
            }
        }
    }

    // MARK: - Delete Image
    func deleteImage(forEntryId entryId: String) {
        imageCache.removeValue(forKey: entryId)
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
