import SwiftUI

/// Post Card Component
struct PostCardView: View {
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
                    .fill(Color.gray.opacity(0.3))
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

                    Text(post.createdAt.timeAgo())
                        .font(.caption)
                        .foregroundColor(.gray)
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
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Post Image (if exists)
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(maxHeight: 300)
                .cornerRadius(12)
                .clipped()
            }

            // Engagement Row
            HStack(spacing: 24) {
                // Like Button
                Button {
                    onLike()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .gray)

                        Text("\(post.likesCount)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                // Comment Button
                NavigationLink {
                    CommentsView(postId: post.id)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.gray)

                        Text("\(post.commentsCount)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}
