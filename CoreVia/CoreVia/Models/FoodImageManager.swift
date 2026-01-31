//
//  FoodImageManager.swift
//  CoreVia
//
//  Qida şəkillərini local storage-də saxlama
//

import SwiftUI
import UIKit

class FoodImageManager: ObservableObject {

    static let shared = FoodImageManager()

    private let imageKeyPrefix = "food_image_"

    // MARK: - Save Image
    func saveImage(_ image: UIImage, forEntryId entryId: String) {
        guard let resizedImage = resizeImage(image, targetSize: CGSize(width: 500, height: 500)) else {
            return
        }

        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            return
        }

        let base64String = imageData.base64EncodedString()
        UserDefaults.standard.set(base64String, forKey: imageKeyPrefix + entryId)
    }

    // MARK: - Load Image
    func loadImage(forEntryId entryId: String) -> UIImage? {
        guard let base64String = UserDefaults.standard.string(forKey: imageKeyPrefix + entryId) else {
            return nil
        }

        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }

        return UIImage(data: imageData)
    }

    // MARK: - Delete Image
    func deleteImage(forEntryId entryId: String) {
        UserDefaults.standard.removeObject(forKey: imageKeyPrefix + entryId)
    }

    // MARK: - Helper: Resize Image
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        // Əgər artıq kiçikdirsə, resize lazım deyil
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
