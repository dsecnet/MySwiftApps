import SwiftUI

// MARK: - Feed View (Listing cards with infinite scroll / pagination)
struct FeedView: View {
    @ObservedObject var viewModel: HomeViewModel
    var onListingTap: ((Listing) -> Void)? = nil

    var body: some View {
        LazyVStack(spacing: AppTheme.Spacing.lg) {
            ForEach(viewModel.recentListings) { listing in
                NavigationLink {
                    ListingDetailView(listing: listing)
                } label: {
                    ListingCard(
                        listing: listing,
                        isFavorite: false,
                        onFavoriteTap: {
                            // Handle favorite toggle
                        },
                        onContactTap: {
                            // Handle contact tap
                        },
                        agent: agentForListing(listing)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .onAppear {
                    Task {
                        await viewModel.loadMoreIfNeeded(currentItem: listing)
                    }
                }
            }

            // MARK: - Loading More Indicator
            if viewModel.isLoadingMore {
                loadingMoreIndicator
            }

            // MARK: - End of List
            if !viewModel.hasMore && !viewModel.recentListings.isEmpty {
                endOfListView
            }

            // MARK: - Empty State
            if viewModel.recentListings.isEmpty && !viewModel.isLoading {
                emptyStateView
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Agent Lookup
    private func agentForListing(_ listing: Listing) -> Agent? {
        guard let agentId = listing.agentId else { return nil }
        return viewModel.topAgents.first { $0.id == agentId }
    }

    // MARK: - Loading More Indicator
    private var loadingMoreIndicator: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))

            Text("loading".localized)
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
    }

    // MARK: - End of List
    private var endOfListView: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.success)

            Text("all".localized)
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "building.2")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textTertiary)

            Text("no_favorites".localized)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                Text("retry".localized)
                    .font(AppTheme.Fonts.bodyBold())
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.accent.opacity(0.12))
                    .cornerRadius(AppTheme.CornerRadius.medium)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxxl)
    }
}

// MARK: - Feed Skeleton Loader
struct FeedSkeletonView: View {
    var body: some View {
        LazyVStack(spacing: AppTheme.Spacing.lg) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    // Image placeholder
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                        .fill(AppTheme.Colors.surfaceBackground)
                        .frame(height: 200)

                    // Price placeholder
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .fill(AppTheme.Colors.surfaceBackground)
                        .frame(width: 150, height: 24)

                    // Address placeholder
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .fill(AppTheme.Colors.surfaceBackground)
                        .frame(width: 200, height: 16)

                    // Details placeholder
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                                .fill(AppTheme.Colors.surfaceBackground)
                                .frame(width: 60, height: 16)
                        }
                    }
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.large)
                .shimmering()
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}
