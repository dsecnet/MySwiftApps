import SwiftUI

/// AsyncImage replacement that loads images through APIService (with auth headers)
/// Fixes: images behind auth, SSL pinning, relative URL handling
struct AuthenticatedImage<Placeholder: View>: View {
    let url: URL?
    let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?
    @State private var failed = false

    init(url: URL?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if failed {
                placeholder()
            } else {
                placeholder()
                    .overlay(ProgressView())
                    .onAppear { loadImage() }
            }
        }
    }

    private func loadImage() {
        guard let url = url else {
            failed = true
            return
        }

        print("🖼️ AuthenticatedImage loading: \(url.absoluteString)")

        Task {
            do {
                var request = URLRequest(url: url)
                if let token = KeychainManager.shared.accessToken {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }

                let (data, response) = try await APIService.shared.imageSession.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    print("🖼️ Image response: \(httpResponse.statusCode) for \(url.lastPathComponent)")
                }

                guard let image = UIImage(data: data) else {
                    print("🖼️ Failed to create UIImage from data (\(data.count) bytes)")
                    await MainActor.run { failed = true }
                    return
                }

                print("🖼️ Image loaded successfully: \(url.lastPathComponent)")
                await MainActor.run { uiImage = image }
            } catch {
                print("🖼️ Image load error: \(error.localizedDescription) for \(url.absoluteString)")
                await MainActor.run { failed = true }
            }
        }
    }
}
