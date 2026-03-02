import Foundation
import SwiftUI
import os.log

@MainActor
class SocialFeedViewModel: ObservableObject {
    @Published var posts: [SocialPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMore = true

    private var currentPage = 1
    private let pageSize = 20

    // MARK: - Load Feed

    func loadFeed(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            hasMore = true
        }

        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let response: FeedResponse = try await APIService.shared.request(
                endpoint: "/api/v1/social/feed",
                method: "GET",
                queryItems: [
                    URLQueryItem(name: "page", value: "\(currentPage)"),
                    URLQueryItem(name: "page_size", value: "\(pageSize)")
                ]
            )

            if refresh {
                posts = response.posts
            } else {
                posts.append(contentsOf: response.posts)
            }

            hasMore = response.hasMore
            currentPage += 1

        } catch {
            AppLogger.network.error("Load social feed xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Like/Unlike

    func toggleLike(post: SocialPost) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }

        let wasLiked = posts[index].isLiked

        // Optimistic update
        posts[index].isLiked.toggle()
        posts[index].likesCount += wasLiked ? -1 : 1

        do {
            if wasLiked {
                // Unlike
                let _: EmptyResponse = try await APIService.shared.request(
                    endpoint: "/api/v1/social/posts/\(post.id)/like",
                    method: "DELETE"
                )
            } else {
                // Like
                let _: EmptyResponse = try await APIService.shared.request(
                    endpoint: "/api/v1/social/posts/\(post.id)/like",
                    method: "POST"
                )
            }
        } catch {
            // Revert on error
            posts[index].isLiked = wasLiked
            posts[index].likesCount += wasLiked ? 1 : -1
            AppLogger.network.error("Toggle like xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete Post

    func deletePost(_ post: SocialPost) async {
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/api/v1/social/posts/\(post.id)",
                method: "DELETE"
            )

            // Remove from local array
            posts.removeAll { $0.id == post.id }

        } catch {
            AppLogger.network.error("Delete post xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Empty Response Helper

struct EmptyResponse: Codable {}
