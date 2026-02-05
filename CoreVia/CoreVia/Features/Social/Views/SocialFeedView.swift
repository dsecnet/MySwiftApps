import SwiftUI

/// Social Feed View - MVVM Pattern
struct SocialFeedView: View {
    @StateObject private var viewModel = SocialFeedViewModel()
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Feed Content
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    loadingView
                } else if viewModel.posts.isEmpty {
                    emptyStateView
                } else {
                    feedListView
                }
            }
            .navigationTitle(loc.localized("social_feed"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreatePost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("PrimaryColor"))
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
            .refreshable {
                await viewModel.loadFeed(refresh: true)
            }
            .task {
                await viewModel.loadFeed()
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
        }
    }

    // MARK: - Feed List

    private var feedListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    PostCardView(
                        post: post,
                        onLike: {
                            Task {
                                await viewModel.toggleLike(post: post)
                            }
                        },
                        onDelete: {
                            Task {
                                await viewModel.deletePost(post)
                            }
                        }
                    )
                }

                // Load More Indicator
                if viewModel.hasMore {
                    ProgressView()
                        .padding()
                        .onAppear {
                            Task {
                                await viewModel.loadFeed()
                            }
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 70))
                .foregroundColor(.gray)

            Text(loc.localized("social_no_posts"))
                .font(.title3)
                .fontWeight(.semibold)

            Text(loc.localized("social_start_sharing"))
                .font(.subheadline)
                .foregroundColor(.gray)

            Button {
                showCreatePost = true
            } label: {
                Text(loc.localized("social_create_post"))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("PrimaryColor"))
                    .cornerRadius(20)
            }
            .padding(.top)
        }
        .padding()
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text(loc.localized("common_loading"))
                .foregroundColor(.gray)
                .padding(.top)
            Spacer()
        }
    }
}

#Preview {
    SocialFeedView()
}
