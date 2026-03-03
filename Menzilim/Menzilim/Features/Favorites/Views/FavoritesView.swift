import SwiftUI

// MARK: - Favorites View
struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Search Bar
                searchBar

                // MARK: - Filter Chips
                filterChips

                // MARK: - Content
                if viewModel.filteredFavorites.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("saved_properties".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textTertiary)

            TextField("search".localized, text: $viewModel.searchText)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.inputBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(FavoritesFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }

    private func filterChip(_ filter: FavoritesFilter) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedFilter = filter
            }
        } label: {
            Text(filter.displayKey.localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(
                    viewModel.selectedFilter == filter
                        ? .white
                        : AppTheme.Colors.textSecondary
                )
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    viewModel.selectedFilter == filter
                        ? AppTheme.Colors.accent
                        : AppTheme.Colors.cardBackground
                )
                .cornerRadius(AppTheme.CornerRadius.pill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                        .stroke(
                            viewModel.selectedFilter == filter
                                ? Color.clear
                                : AppTheme.Colors.inputBorder,
                            lineWidth: 1
                        )
                )
        }
    }

    // MARK: - Favorites List
    private var favoritesList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: AppTheme.Spacing.lg) {
                ForEach(viewModel.filteredFavorites) { listing in
                    favoriteCard(listing)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
    }

    // MARK: - Favorite Card
    private func favoriteCard(_ listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: listing.mainImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16 / 10, contentMode: .fill)
                    case .failure:
                        imagePlaceholder
                    case .empty:
                        imagePlaceholder
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                            )
                    @unknown default:
                        imagePlaceholder
                    }
                }
                .frame(height: 200)
                .clipped()

                // Overlays
                HStack(alignment: .top) {
                    // For Sale badge
                    Text(listing.listingType.displayKey.localized)
                        .font(AppTheme.Fonts.smallBold())
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.Colors.accent)
                        .cornerRadius(AppTheme.CornerRadius.small)

                    Spacer()

                    // Heart button (filled red)
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.toggleFavorite(listing)
                        }
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.error)
                            .frame(width: 36, height: 36)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(AppTheme.Spacing.md)
            }

            // Content section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                // Price
                Text(listing.formattedPrice)
                    .font(AppTheme.Fonts.price())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                // Location
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    Text("\(listing.district), \(listing.city)")
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }

                // Details row
                HStack(spacing: AppTheme.Spacing.lg) {
                    detailItem(icon: "bed.double.fill", value: "\(listing.rooms)", label: "rooms".localized)
                    detailDivider
                    detailItem(icon: "shower.fill", value: "1", label: "baths".localized)
                    detailDivider
                    detailItem(icon: "ruler.fill", value: "\(Int(listing.areaSqm)) m\u{00B2}", label: "area_sqm".localized)
                }
                .padding(.top, AppTheme.Spacing.xs)
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }

    // MARK: - Detail Item
    private func detailItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.accent)

            Text(value)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }

    private var detailDivider: some View {
        Rectangle()
            .fill(AppTheme.Colors.inputBorder)
            .frame(width: 1, height: 16)
    }

    // MARK: - Image Placeholder
    private var imagePlaceholder: some View {
        Rectangle()
            .fill(AppTheme.Colors.surfaceBackground)
            .frame(height: 200)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            )
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "heart.slash")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.Colors.textTertiary)

            Text("no_favorites".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("no_favorites_hint".localized)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppTheme.Spacing.xxxl)
    }
}

// MARK: - Preview
#Preview {
    FavoritesView()
}
