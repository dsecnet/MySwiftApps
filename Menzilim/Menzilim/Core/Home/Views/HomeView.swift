import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false

    // Property type pills for filtering
    private let propertyTypes: [PropertyType] = [.oldBuilding, .newBuilding, .house, .office, .garage, .land, .commercial]

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppTheme.Colors.background
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        // MARK: - Top Bar
                        topBar

                        // MARK: - Search Bar
                        searchBar

                        // MARK: - Property Type Pills
                        propertyTypePills

                        if viewModel.isLoading {
                            // Skeleton loading
                            featuredSkeletonSection
                            FeedSkeletonView()
                        } else {
                            // MARK: - Featured Listings
                            if !viewModel.featuredListings.isEmpty {
                                featuredListingsSection
                            }

                            // MARK: - Top Rated Agents
                            if !viewModel.topAgents.isEmpty {
                                topAgentsSection
                            }

                            // MARK: - VIP Listings
                            if !viewModel.vipListings.isEmpty {
                                vipListingsSection
                            }

                            // MARK: - Recent Listings Feed
                            recentListingsSection
                        }

                        // Bottom spacing for tab bar
                        Spacer()
                            .frame(height: 80)
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // App Icon
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .brightness(0.15)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: AppTheme.Colors.accent.opacity(0.5), radius: 6, x: 0, y: 2)

            // App Title
            Text("app_name".localized)
                .font(AppTheme.Fonts.heading2())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            // Notification Bell
            Button {
                // Navigate to notifications
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.Colors.cardBackground)
                        .clipShape(Circle())

                    // Notification badge
                    Circle()
                        .fill(AppTheme.Colors.error)
                        .frame(width: 10, height: 10)
                        .offset(x: 2, y: -2)
                }
            }

            // User Avatar
            Button {
                // Navigate to profile
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.accent, lineWidth: 2)
                    )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Search Bar (Tappable, navigates to SearchView)
    private var searchBar: some View {
        Button {
            showSearch = true
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.textTertiary)

                Text("search".localized)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textTertiary)

                Spacer()

                // Filter button
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.accent.opacity(0.12))
                    .cornerRadius(AppTheme.CornerRadius.small)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Property Type Pills
    private var propertyTypePills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                // "All" pill
                propertyPill(
                    title: "all".localized,
                    icon: "square.grid.2x2.fill",
                    isSelected: viewModel.selectedPropertyType == nil
                ) {
                    Task {
                        await viewModel.selectPropertyType(nil)
                    }
                }

                // Property type pills
                ForEach(propertyTypes, id: \.self) { type in
                    propertyPill(
                        title: type.displayKey.localized,
                        icon: type.icon,
                        isSelected: viewModel.selectedPropertyType == type
                    ) {
                        Task {
                            await viewModel.selectPropertyType(type)
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }

    private func propertyPill(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))

                Text(title)
                    .font(AppTheme.Fonts.captionBold())
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                    .stroke(
                        isSelected ? Color.clear : AppTheme.Colors.inputBorder,
                        lineWidth: 1
                    )
            )
        }
    }

    // MARK: - Featured Listings Section
    private var featuredListingsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section header
            sectionHeader(title: "featured_listings".localized)

            // Horizontal scroll of large listing cards
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppTheme.Spacing.lg) {
                    ForEach(viewModel.featuredListings) { listing in
                        NavigationLink {
                            ListingDetailView(listing: listing)
                        } label: {
                            CompactListingCard(
                                listing: listing,
                                isFavorite: false,
                                onFavoriteTap: {
                                    // Handle favorite
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
    }

    // MARK: - Top Agents Section
    private var topAgentsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section header
            sectionHeader(title: "top_agents".localized)

            // Horizontal scroll of agent circles
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppTheme.Spacing.md) {
                    ForEach(viewModel.topAgents) { agent in
                        AgentCard(
                            agent: agent,
                            isFollowing: false,
                            onFollowTap: {
                                // Handle follow
                            },
                            onTap: {
                                // Navigate to agent profile
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
    }

    // MARK: - VIP Listings Section
    private var vipListingsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section header with VIP badge
            HStack {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.gold)

                    Text("vip_listings".localized)
                        .font(AppTheme.Fonts.heading3())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }

                Spacer()

                Button {
                    // Navigate to see all VIP
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("see_all".localized)
                            .font(AppTheme.Fonts.captionBold())
                            .foregroundColor(AppTheme.Colors.accent)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)

            // Horizontal scroll of VIP listing cards
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppTheme.Spacing.lg) {
                    ForEach(viewModel.vipListings) { listing in
                        NavigationLink {
                            ListingDetailView(listing: listing)
                        } label: {
                            VIPListingCard(listing: listing)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
    }

    // MARK: - Recent Listings Section (Feed)
    private var recentListingsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section header
            sectionHeader(title: "new_listings".localized)

            // Vertical feed with pagination
            FeedView(
                viewModel: viewModel,
                onListingTap: { listing in
                    // Navigate to listing detail
                }
            )
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Button {
                // Navigate to see all
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Text("see_all".localized)
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.accent)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Featured Skeleton Section
    private var featuredSkeletonSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section header skeleton
            HStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .fill(AppTheme.Colors.surfaceBackground)
                    .frame(width: 160, height: 24)
                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)

            // Cards skeleton
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.lg) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .fill(AppTheme.Colors.surfaceBackground)
                                .frame(width: 260, height: 160)

                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                                .fill(AppTheme.Colors.surfaceBackground)
                                .frame(width: 120, height: 20)

                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                                .fill(AppTheme.Colors.surfaceBackground)
                                .frame(width: 180, height: 14)
                        }
                        .frame(width: 260)
                        .padding(.bottom, AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(AppTheme.CornerRadius.large)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
            .shimmering()
        }
    }
}

// MARK: - VIP Listing Card
struct VIPListingCard: View {
    let listing: Listing
    @State private var isFavorited: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with golden VIP border
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: listing.mainImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(AppTheme.Colors.surfaceBackground)
                            .overlay(
                                ProgressView()
                                    .tint(AppTheme.Colors.accent)
                            )
                    }
                }
                .frame(width: 280, height: 180)
                .clipped()
                .cornerRadius(AppTheme.CornerRadius.medium, corners: [.topLeft, .topRight])

                // VIP badge
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                    Text("VIP")
                        .font(AppTheme.Fonts.smallBold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.gold, Color(hex: "D97706")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppTheme.CornerRadius.small)
                .padding(AppTheme.Spacing.sm)

                // Favorite button
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                isFavorited.toggle()
                            }
                        } label: {
                            Image(systemName: isFavorited ? "heart.fill" : "heart")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isFavorited ? AppTheme.Colors.error : .white)
                                .frame(width: 30, height: 30)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        .padding(AppTheme.Spacing.sm)
                    }
                    Spacer()
                }
            }

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(listing.formattedPrice)
                    .font(AppTheme.Fonts.title())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(listing.title)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)

                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.gold)

                    Text("\(listing.district), \(listing.city)")
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: AppTheme.Spacing.md) {
                    Label("\(listing.rooms)", systemImage: "bed.double.fill")
                    Label("\(Int(listing.areaSqm))m\u{00B2}", systemImage: "ruler.fill")
                    if let floorInfo = listing.floorInfo {
                        Label(floorInfo, systemImage: "building.2.fill")
                    }
                }
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(AppTheme.Spacing.md)
        }
        .frame(width: 280)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.Colors.gold.opacity(0.6), AppTheme.Colors.gold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(LocalizationManager.shared)
}
