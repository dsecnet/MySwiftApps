import SwiftUI

/// Social Feed View - MVVM Pattern, Clean Code
struct SocialFeedView: View {

    @StateObject private var viewModel = SocialFeedViewModel()
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Feed Content
                    if viewModel.isLoading && viewModel.posts.isEmpty {
                        loadingView
                    } else if viewModel.posts.isEmpty {
                        emptyStateView
                    } else {
                        feedListView
                    }
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
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
            .refreshable {
                await viewModel.loadFeed()
            }
            .task {
                await viewModel.loadFeed()
            }
            .alert("Xəta", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            Text(loc.localized("social_feed_subtitle"))
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Spacer()

            // Filter buttons (optional)
            Menu {
                Button(loc.localized("social_all_posts")) {
                    // Filter: All
                }
                Button(loc.localized("social_my_posts")) {
                    // Filter: My posts only
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(AppTheme.Colors.accent)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Feed List

    private var feedListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    PostCardView(post: post)
                        .onTapGesture {
                            viewModel.selectedPost = post
                        }
                }

                // Load more
                if viewModel.hasMore {
                    ProgressView()
                        .padding()
                        .onAppear {
                            Task {
                                await viewModel.loadMorePosts()
                            }
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack.badge.person.crop")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(loc.localized("social_no_posts"))
                .font(.title2)
                .fontWeight(.semibold)

            Text(loc.localized("social_no_posts_subtitle"))
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                showCreatePost = true
            } label: {
                Text(loc.localized("social_create_first_post"))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text(loc.localized("common_loading"))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .padding(.top)
            Spacer()
        }
    }
}

// MARK: - Post Card View

struct PostCardView: View {
    let post: SocialPost
    @StateObject private var viewModel = PostViewModel()
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Info
            HStack(spacing: 12) {
                // Profile Image
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(post.author?.name.prefix(1).uppercased() ?? "?")
                            .foregroundColor(AppTheme.Colors.accent)
                            .fontWeight(.bold)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author?.name ?? loc.localized("social_unknown_user"))
                        .font(.system(size: 15, weight: .semibold))

                    Text(post.createdAt.timeAgoDisplay())
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                Spacer()

                // Post type badge
                PostTypeBadge(type: post.postType)
            }

            // Content
            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .lineLimit(10)
            }

            // Image (if exists)
            if let imageURL = post.imageUrl, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fit)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .cornerRadius(12)
                .clipped()
            }

            // Engagement (Likes, Comments)
            HStack(spacing: 20) {
                // Like Button
                Button {
                    Task {
                        await viewModel.toggleLike(post: post)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : AppTheme.Colors.secondaryText)
                        Text("\(post.likesCount)")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }

                // Comment Button
                Button {
                    // Show comments
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        Text("\(post.commentsCount)")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Post Type Badge

struct PostTypeBadge: View {
    let type: String

    var badgeInfo: (icon: String, color: Color) {
        switch type {
        case "workout":
            return ("figure.strengthtraining.traditional", .blue)
        case "meal":
            return ("fork.knife", .orange)
        case "progress":
            return ("chart.line.uptrend.xyaxis", .green)
        case "achievement":
            return ("trophy.fill", .yellow)
        default:
            return ("text.bubble", .gray)
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: badgeInfo.icon)
            //Text(type.capitalized)
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(badgeInfo.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeInfo.color.opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Helper Extension

extension Date {
    func timeAgoDisplay() -> String {
        let seconds = Date().timeIntervalSince(self)

        if seconds < 60 {
            return "İndicə"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes) dəq əvvəl"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours) saat əvvəl"
        } else {
            let days = Int(seconds / 86400)
            return "\(days) gün əvvəl"
        }
    }
}

#Preview {
    SocialFeedView()
}
