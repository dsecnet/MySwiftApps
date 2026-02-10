import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// Camera Picker
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// Image Upload Helper
class ImageUploadHelper {
    static func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxSizeKB * 1024 && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }

        return imageData
    }

    static func uploadImage(_ image: UIImage, endpoint: String, token: String) async throws -> String {
        guard let imageData = compressImage(image) else {
            throw ImageUploadError.compressionFailed
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)

        struct UploadResponse: Codable {
            let url: String
        }

        let response = try JSONDecoder().decode(UploadResponse.self, from: data)
        return response.url
    }

    enum ImageUploadError: LocalizedError {
        case compressionFailed
        case uploadFailed

        var errorDescription: String? {
            switch self {
            case .compressionFailed:
                return "Şəkil sıxışdırıla bilmədi"
            case .uploadFailed:
                return "Şəkil yüklənə bilmədi"
            }
        }
    }
}

// Image selection sheet
struct ImageSelectionSheet: View {
    @Binding var showSheet: Bool
    @Binding var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Şəkil Seç")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Button {
                    showSheet = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding()

            Divider()

            // Options
            VStack(spacing: 0) {
                Button {
                    showCamera = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primaryColor)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.primaryColor.opacity(0.15))
                            .cornerRadius(10)

                        Text("Kamera")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                }

                Divider().padding(.leading, 60)

                Button {
                    showImagePicker = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "photo.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.secondaryColor)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.secondaryColor.opacity(0.15))
                            .cornerRadius(10)

                        Text("Foto Kitabxana")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                }
            }

            Spacer()
        }
        .background(AppTheme.backgroundColor)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(selectedImage: $selectedImage)
        }
    }
}
