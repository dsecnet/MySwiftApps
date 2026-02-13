import SwiftUI

struct CommentsView: View {
    let postId: String
    @StateObject private var viewModel: CommentsViewModel
    @State private var newComment: String = ""
    let loc = LocalizationManager.shared

    init(postId: String) {
        self.postId = postId
        _viewModel = StateObject(wrappedValue: CommentsViewModel(postId: postId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Comments List
            ScrollView {
                if viewModel.comments.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.comments) { comment in
                            CommentRow(comment: comment, onDelete: {
                                Task {
                                    await viewModel.deleteComment(comment)
                                }
                            })
                        }
                    }
                    .padding()
                }
            }
            .refreshable {
                await viewModel.loadComments()
            }

            Divider()

            // Comment Input
            HStack(spacing: 12) {
                TextField(loc.localized("social_write_comment"), text: $newComment, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...5)

                Button {
                    Task {
                        await submitComment()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(canSubmit ? Color("PrimaryColor") : .gray)
                }
                .disabled(!canSubmit || viewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .navigationTitle(loc.localized("social_comments"))
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading && viewModel.comments.isEmpty {
                ProgressView()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .task {
            await viewModel.loadComments()
        }
    }

    private var canSubmit: Bool {
        !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(loc.localized("social_no_comments"))
                .font(.headline)
                .foregroundColor(.gray)
            Text(loc.localized("social_be_first_comment"))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func submitComment() async {
        let commentText = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !commentText.isEmpty else { return }

        newComment = ""

        await viewModel.addComment(content: commentText)
    }
}

// MARK: - Comment Row

struct CommentRow: View {
    let comment: PostComment
    let onDelete: () -> Void
    @State private var showDeleteAlert = false
    let loc = LocalizationManager.shared

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile Image
            if let imageUrl = comment.author?.profileImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color(.systemGray5))
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color("PrimaryColor").opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text((comment.author?.name.prefix(1) ?? "U").uppercased())
                            .font(.headline)
                            .foregroundColor(Color("PrimaryColor"))
                    }
            }

            // Comment Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.author?.name ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(comment.createdAt.timeAgo())
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Text(comment.content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Delete Button (if user's own comment)
            if comment.userId == UserDefaults.standard.string(forKey: "userId") {
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .alert(loc.localized("social_delete_comment"), isPresented: $showDeleteAlert) {
                    Button(loc.localized("common_cancel"), role: .cancel) {}
                    Button(loc.localized("common_delete"), role: .destructive) {
                        onDelete()
                    }
                } message: {
                    Text(loc.localized("social_delete_comment_confirm"))
                }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
class CommentsViewModel: ObservableObject {
    let postId: String
    @Published var comments: [PostComment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(postId: String) {
        self.postId = postId
    }

    func loadComments() async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedComments: [PostComment] = try await APIService.shared.request(
                endpoint: "/api/v1/social/posts/\(postId)/comments",
                method: "GET"
            )

            comments = loadedComments

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addComment(content: String) async {
        errorMessage = nil

        do {
            struct CreateCommentRequest: Codable {
                let content: String
            }

            let newComment: PostComment = try await APIService.shared.request(
                endpoint: "/api/v1/social/posts/\(postId)/comments",
                method: "POST",
                body: CreateCommentRequest(content: content)
            )

            // Add to beginning of list
            comments.insert(newComment, at: 0)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteComment(_ comment: PostComment) async {
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/api/v1/social/comments/\(comment.id)",
                method: "DELETE"
            )

            // Remove from local array
            comments.removeAll { $0.id == comment.id }

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// #Preview { // iOS 17+ only
//     NavigationStack {
//         CommentsView(postId: "123")
//     }
// }
