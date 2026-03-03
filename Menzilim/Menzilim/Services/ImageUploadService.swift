import SwiftUI
import PhotosUI

// MARK: - Image Upload Service
class ImageUploadService: ObservableObject {
    static let shared = ImageUploadService()

    @Published var isUploading = false
    @Published var uploadProgress: Double = 0

    private let api = APIService.shared

    // MARK: - Upload Single Image
    func uploadImage(_ image: UIImage, type: String = "listing") async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.noData
        }

        isUploading = true
        defer {
            Task { @MainActor in
                self.isUploading = false
            }
        }

        return try await api.uploadImage(imageData: data, type: type)
    }

    // MARK: - Upload Multiple Images
    func uploadImages(_ images: [UIImage], type: String = "listing") async throws -> [String] {
        var urls: [String] = []

        for (index, image) in images.enumerated() {
            let url = try await uploadImage(image, type: type)
            urls.append(url)

            await MainActor.run {
                self.uploadProgress = Double(index + 1) / Double(images.count)
            }
        }

        await MainActor.run {
            self.uploadProgress = 0
        }

        return urls
    }

    // MARK: - Compress Image
    func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        var compression: CGFloat = 1.0
        var data = image.jpegData(compressionQuality: compression)

        while let d = data, d.count > maxSizeKB * 1024, compression > 0.1 {
            compression -= 0.1
            data = image.jpegData(compressionQuality: compression)
        }

        return data
    }
}
