import SwiftUI

/// Post Card Component
struct PostCardView: View {
    @Environment(\.colorScheme) var colorScheme
    let post: SocialPost
    let onLike: () -> Void
    let onDelete: () -> Void

    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack(spacing: 12) {
                // Profile Image
                Circle()
                    .fill(Color("PrimaryColor").opacity(0.7))
                    .frame(width: 40, height: 40)
                    .overlay {
                        if let author = post.author {
                            Text(author.name.prefix(1).uppercased())
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author?.name ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(post.createdAt.timeAgo())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Delete button (if own post)
                if post.userId == UserDefaults.standard.string(forKey: "userId") {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .confirmationDialog("Delete Post", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            onDelete()
                        }
                    }
                }
            }

            // Content
            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Post Image (if exists)
            if let imageUrl = post.imageUrl {
                let fullImageUrl = imageUrl.hasPrefix("http")
                    ? imageUrl
                    : "\(APIService.shared.baseURL)\(imageUrl)"

                if let url = URL(string: fullImageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay {
                                    ProgressView()
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay {
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(.gray)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .clipped()
                }
            }

            // Engagement Row
            HStack(spacing: 24) {
                // Like Button
                Button {
                    onLike()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .secondary)

                        Text("\(post.likesCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Comment Button
                NavigationLink {
                    CommentsView(postId: post.id)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.secondary)

                        Text("\(post.commentsCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            colorScheme == .dark
                ? Color(.systemGray6)
                : Color(.systemBackground)
        )
        .cornerRadius(16)
        .shadow(
            color: colorScheme == .dark
                ? Color.white.opacity(0.05)
                : Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}
