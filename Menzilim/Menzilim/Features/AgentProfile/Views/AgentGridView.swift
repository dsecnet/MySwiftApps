import SwiftUI

// MARK: - Agent Grid View (3-column Instagram-style grid)
struct AgentGridView: View {
    let listings: [Listing]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        if listings.isEmpty {
            emptyState
        } else {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(listings) { listing in
                    NavigationLink {
                        // Navigate to listing detail
                        listingDetailPlaceholder(listing)
                    } label: {
                        gridCell(listing)
                    }
                }
            }
            .padding(.top, 2)
        }
    }

    // MARK: - Grid Cell
    private func gridCell(_ listing: Listing) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: listing.mainImage)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
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
            .frame(minWidth: 0, maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .clipped()

            // Overlay with price and type
            VStack(alignment: .leading, spacing: 2) {
                // Boost badge
                if listing.isBoosted, let boostType = listing.boostType {
                    Text(boostType.displayName)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(hex: boostType.color))
                        .cornerRadius(3)
                }

                // Price label
                Text(listing.formattedPrice)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(3)
            }
            .padding(4)

            // Multi-image indicator
            if listing.images.count > 1 {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "square.fill.on.square.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2)
                            .padding(6)
                    }
                    Spacer()
                }
            }
        }
    }

    // MARK: - Image Placeholder
    private var imagePlaceholder: some View {
        Rectangle()
            .fill(AppTheme.Colors.surfaceBackground)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            )
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textTertiary)

            Text("active_listings".localized)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxxl * 2)
    }

    // MARK: - Listing Detail Placeholder
    private func listingDetailPlaceholder(_ listing: Listing) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                AsyncImage(url: URL(string: listing.mainImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16 / 10, contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(AppTheme.Colors.surfaceBackground)
                            .aspectRatio(16 / 10, contentMode: .fill)
                    }
                }
                .clipped()

                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text(listing.title)
                        .font(AppTheme.Fonts.heading2())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(listing.formattedPrice)
                        .font(AppTheme.Fonts.price())
                        .foregroundColor(AppTheme.Colors.accent)

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Text("\(listing.district), \(listing.city)")
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    HStack(spacing: AppTheme.Spacing.xl) {
                        Label("\(listing.rooms) \("rooms".localized)", systemImage: "bed.double.fill")
                        Label("\(Int(listing.areaSqm)) m\u{00B2}", systemImage: "ruler.fill")
                        if let floorInfo = listing.floorInfo {
                            Label(floorInfo, systemImage: "building.2.fill")
                        }
                    }
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                    Text(listing.description)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.top, AppTheme.Spacing.sm)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
        .background(AppTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ScrollView {
            AgentGridView(listings: AgentProfileViewModel.mockListings)
        }
        .background(AppTheme.Colors.background)
    }
}
