//
//  ProfileImageManager.swift
//  CoreVia
//
//  Profil şəkillərini backend-ə upload etmə
//

import SwiftUI
import UIKit

class ProfileImageManager: ObservableObject {

    static let shared = ProfileImageManager()

    @Published var profileImage: UIImage?

    private let api = APIService.shared

    init() {
        loadImageFromBackend()
    }

    // MARK: - Upload Image to Backend
    func saveImage(_ image: UIImage) {
        guard let resizedImage = resizeImage(image, targetSize: CGSize(width: 300, height: 300)) else {
            return
        }

        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            return
        }

        DispatchQueue.main.async {
            self.profileImage = resizedImage
        }

        Task {
            do {
                let _ = try await api.uploadImage(
                    endpoint: "/api/v1/uploads/profile-image",
                    imageData: imageData,
                    fieldName: "file",
                    fileName: "profile.jpg"
                )
            } catch {
                print("Profile image upload xətası: \(error)")
            }
        }
    }

    // MARK: - Load Image from Backend
    func loadImageFromBackend() {
        guard KeychainManager.shared.isLoggedIn else { return }

        guard let user = AuthManager.shared.currentUser,
              let imageUrl = user.profileImageUrl else { return }

        let baseURL = api.baseURL
        let fullURL: String
        if imageUrl.hasPrefix("http") {
            fullURL = imageUrl
        } else {
            fullURL = baseURL + imageUrl
        }

        guard let url = URL(string: fullURL) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.profileImage = image
                    }
                }
            } catch {
                print("Profile image download xətası: \(error)")
            }
        }
    }

    // MARK: - Load Image from URL string
    func loadImage() {
        loadImageFromBackend()
    }

    // MARK: - Delete Image
    func deleteImage() {
        DispatchQueue.main.async {
            self.profileImage = nil
        }
    }

    // MARK: - Helper: Resize Image
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
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
