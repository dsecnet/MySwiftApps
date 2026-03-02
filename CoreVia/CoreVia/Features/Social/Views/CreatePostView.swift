import SwiftUI
import PhotosUI
import os.log

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CreatePostViewModel()
    let loc = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Post Type Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("social_post_type"))
                            .font(.headline)

                        Picker("", selection: $viewModel.postType) {
                            Text(loc.localized("social_general")).tag("general")
                            Text(loc.localized("social_workout")).tag("workout")
                            Text(loc.localized("social_meal")).tag("meal")
                            Text(loc.localized("social_progress")).tag("progress")
                            Text(loc.localized("social_achievement")).tag("achievement")
                        }
                        .pickerStyle(.segmented)
                    }

                    // Content Text Editor
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("social_post_content"))
                            .font(.headline)

                        TextEditor(text: $viewModel.content)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }

                    // Image Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("social_add_image"))
                            .font(.headline)

                        if let selectedImage = viewModel.selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 300)
                                    .cornerRadius(12)

                                Button {
                                    viewModel.selectedImage = nil
                                    viewModel.selectedPhotoItem = nil
                                    // FIX 8: Clear caption when image is removed
                                    viewModel.imageCaption = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white, .red)
                                        .padding(8)
                                }
                            }

                            // FIX 8: NEW - Image Caption Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Şəkil Açıqlaması")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                TextField("Şəkil haqqında məlumat əlavə edin...", text: $viewModel.imageCaption)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                            .padding(.top, 8)
                        } else {
                            PhotosPicker(
                                selection: $viewModel.selectedPhotoItem,
                                matching: .images
                            ) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.title3)
                                    Text(loc.localized("social_select_image"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }

                    // Public/Private Toggle
                    Toggle(loc.localized("social_public_post"), isOn: $viewModel.isPublic)
                        .tint(Color("PrimaryColor"))

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle(loc.localized("social_create_post"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.localized("common_cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.localized("social_post")) {
                        Task {
                            let success = await viewModel.createPost()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) { newItem in
                Task {
                    await viewModel.loadImage(from: newItem)
                }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var postType: String = "general"
    @Published var content: String = ""
    @Published var isPublic: Bool = true
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // FIX 8: NEW - Image caption field
    @Published var imageCaption: String = ""

    func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            errorMessage = "Failed to load image"
        }
    }

    func createPost() async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            // 1. Create post
            let request = CreatePostRequest(
                postType: postType,
                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                workoutId: nil,
                foodEntryId: nil,
                isPublic: isPublic
            )

            let createdPost: SocialPost = try await APIService.shared.request(
                endpoint: "/api/v1/social/posts",
                method: "POST",
                body: request
            )

            // 2. Upload image if selected
            if let image = selectedImage {
                try await uploadImage(image, postId: createdPost.id)
            }

            isLoading = false
            return true

        } catch {
            AppLogger.network.error("Create post xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    private func uploadImage(_ image: UIImage, postId: String) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "CreatePost", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }

        // Use APIService uploadImage method
        _ = try await APIService.shared.uploadImage(
            endpoint: "/api/v1/social/posts/\(postId)/image",
            imageData: imageData,
            fieldName: "file",
            fileName: "post_image.jpg"
        )
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ProgressView()
                .tint(.white)
                .controlSize(.large)
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
    }
}

// #Preview { // iOS 17+ only
//     CreatePostView()
// }
