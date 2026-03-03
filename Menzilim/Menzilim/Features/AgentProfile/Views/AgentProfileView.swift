import SwiftUI

// MARK: - Agent Profile View (Instagram-style)
struct AgentProfileView: View {
    @StateObject private var viewModel: AgentProfileViewModel
    @Environment(\.dismiss) private var dismiss

    init(agent: Agent? = nil) {
        _viewModel = StateObject(wrappedValue: AgentProfileViewModel(agent: agent))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Profile Header
                profileHeader

                // MARK: - Agent Info
                agentInfoSection

                // MARK: - Action Buttons
                actionButtons

                // MARK: - Tab Selector
                tabSelector

                // MARK: - Tab Content
                tabContent
            }
        }
        .background(AppTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.agent.displayName)
                    .font(AppTheme.Fonts.title())
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Share action
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            HStack(spacing: AppTheme.Spacing.xxl) {
                // Profile Photo
                profilePhoto

                // Stats Row
                HStack(spacing: AppTheme.Spacing.xl) {
                    statItem(
                        count: "\(viewModel.agent.totalListings)",
                        label: "listings_count".localized
                    )
                    statItem(
                        count: "\(viewModel.followersCount)",
                        label: "followers".localized
                    )
                    statItem(
                        count: "\(viewModel.agent.totalSales)",
                        label: "sold".localized
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: - Profile Photo
    private var profilePhoto: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: URL(string: viewModel.agent.avatarUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Circle()
                        .fill(AppTheme.Colors.surfaceBackground)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        )
                }
            }
            .frame(width: 86, height: 86)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent, Color(hex: "0099CC")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )

            // Verified badge
            if viewModel.agent.isPremium {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.accent)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.background)
                            .frame(width: 22, height: 22)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }

    // MARK: - Stat Item
    private func statItem(count: String, label: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(count)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(label)
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Agent Info Section
    private var agentInfoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Name
            Text(viewModel.agent.displayName)
                .font(AppTheme.Fonts.bodyBold())
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Company
            if let company = viewModel.agent.companyName {
                Text(company)
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            // Bio
            if let bio = viewModel.agent.bio {
                Text(bio)
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(3)
                    .padding(.top, AppTheme.Spacing.xs)
            }

            // Level Badge with Stars
            HStack(spacing: AppTheme.Spacing.sm) {
                // Level badge
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 12))
                    Text(viewModel.agent.level.displayKey.localized)
                        .font(AppTheme.Fonts.smallBold())
                }
                .foregroundColor(Color(hex: viewModel.agent.level.badgeColor))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(Color(hex: viewModel.agent.level.badgeColor).opacity(0.15))
                .cornerRadius(AppTheme.CornerRadius.small)

                // Stars
                HStack(spacing: 2) {
                    ForEach(0..<viewModel.agent.level.stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.Colors.gold)
                    }
                }

                Spacer()
            }
            .padding(.top, AppTheme.Spacing.xs)

            // Location
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.accent)
                Text("Bakı, Azərbaycan")
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.top, AppTheme.Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Follow Button
            Button {
                viewModel.toggleFollow()
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: viewModel.isFollowing ? "person.badge.checkmark" : "person.badge.plus")
                        .font(.system(size: 14))
                    Text(viewModel.isFollowing ? "following".localized : "follow".localized)
                        .font(AppTheme.Fonts.captionBold())
                }
                .foregroundColor(viewModel.isFollowing ? AppTheme.Colors.textPrimary : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    viewModel.isFollowing
                        ? AppTheme.Colors.cardBackground
                        : AppTheme.Colors.accent
                )
                .cornerRadius(AppTheme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(
                            viewModel.isFollowing ? AppTheme.Colors.inputBorder : Color.clear,
                            lineWidth: 1
                        )
                )
            }

            // Message Button
            Button {
                // Message action
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                    Text("message".localized)
                        .font(AppTheme.Fonts.captionBold())
                }
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            // Grid Tab
            tabButton(
                icon: "square.grid.3x3.fill",
                tab: .grid
            )

            // Reviews Tab
            tabButton(
                icon: "text.bubble.fill",
                tab: .reviews
            )
        }
        .padding(.top, AppTheme.Spacing.lg)
    }

    private func tabButton(icon: String, tab: AgentProfileViewModel.AgentProfileTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedTab = tab
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(
                        viewModel.selectedTab == tab
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.textTertiary
                    )

                Rectangle()
                    .fill(
                        viewModel.selectedTab == tab
                            ? AppTheme.Colors.accent
                            : Color.clear
                    )
                    .frame(height: 1.5)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .grid:
            AgentGridView(listings: viewModel.listings)
        case .reviews:
            ReviewsView(
                reviews: viewModel.reviews,
                averageRating: viewModel.averageRating,
                totalReviews: viewModel.totalReviewsCount,
                ratingDistribution: viewModel.ratingDistribution
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AgentProfileView()
    }
}
