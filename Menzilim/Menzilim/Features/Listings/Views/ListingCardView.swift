import SwiftUI

// MARK: - Listing Card View (Horizontal Compact for Search Results)
struct ListingCardView: View {
    let listing: Listing
    var isFavorite: Bool = false
    var onFavoriteTap: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                // MARK: - Image Section (Left)
                imageSection

                // MARK: - Details Section (Right)
                detailsSection
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Image Section
    private var imageSection: some View {
        ZStack(alignment: .topLeading) {
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
                                .scaleEffect(0.7)
                        )
                @unknown default:
                    imagePlaceholder
                }
            }
            .frame(width: 130, height: 130)
            .clipped()
            .cornerRadius(AppTheme.CornerRadius.medium)

            // Boost badge
            if listing.isBoosted, let boostType = listing.boostType {
                Text(boostType.displayName)
                    .font(AppTheme.Fonts.smallBold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(badgeColor(for: boostType))
                    .cornerRadius(AppTheme.CornerRadius.small)
                    .padding(AppTheme.Spacing.xs)
            }
        }
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(AppTheme.Colors.surfaceBackground)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            )
    }

    private func badgeColor(for type: BoostType) -> Color {
        switch type {
        case .vip: return AppTheme.Colors.vipBadge
        case .premium: return AppTheme.Colors.premiumBadge
        case .standard: return AppTheme.Colors.newBadge
        }
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Price & Favorite
            HStack(alignment: .top) {
                Text(listing.formattedPrice)
                    .font(AppTheme.Fonts.title())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                Spacer()

                Button {
                    onFavoriteTap?()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(
                            isFavorite ? AppTheme.Colors.error : AppTheme.Colors.textTertiary
                        )
                        .frame(width: 30, height: 30)
                }
            }

            // Listing type tag
            Text(listing.listingType.displayKey.localized)
                .font(AppTheme.Fonts.smallBold())
                .foregroundColor(AppTheme.Colors.accent)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, 2)
                .background(AppTheme.Colors.accent.opacity(0.12))
                .cornerRadius(AppTheme.CornerRadius.small)

            // Address
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textTertiary)

                Text("\(listing.district), \(listing.city)")
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            // Property details row
            HStack(spacing: AppTheme.Spacing.md) {
                detailChip(icon: "bed.double.fill", value: "\(listing.rooms)")
                detailChip(icon: "ruler.fill", value: "\(Int(listing.areaSqm))m\u{00B2}")

                if let floorInfo = listing.floorInfo {
                    detailChip(icon: "building.2.fill", value: floorInfo)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func detailChip(icon: String, value: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.accent)

            Text(value)
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        ListingCardView(
            listing: Listing(
                id: "1", userId: "u1", agentId: "a1",
                title: "3 otaqli menzil Yasamalda",
                description: "Ela temirli",
                listingType: .sale, propertyType: .oldBuilding,
                price: 185000, currency: .AZN,
                city: "Baki", district: "Yasamal",
                address: "Hesen Aliyev kuc. 42",
                latitude: 40.3893, longitude: 49.8471,
                rooms: 3, areaSqm: 95, floor: 7, totalFloors: 16,
                renovation: .excellent, images: [], videoUrl: nil,
                status: .active, viewsCount: 234,
                isBoosted: true, boostType: .vip,
                boostExpiresAt: nil, createdAt: Date(), updatedAt: Date()
            ),
            isFavorite: true
        )

        ListingCardView(
            listing: Listing(
                id: "2", userId: "u2", agentId: nil,
                title: "2 otaqli menzil kiraye",
                description: "Yeni tikili",
                listingType: .rent, propertyType: .newBuilding,
                price: 650, currency: .AZN,
                city: "Baki", district: "Nerimanov",
                address: "Tabriz kuc. 18",
                latitude: 40.4093, longitude: 49.8671,
                rooms: 2, areaSqm: 72, floor: 12, totalFloors: 20,
                renovation: .good, images: [], videoUrl: nil,
                status: .active, viewsCount: 156,
                isBoosted: false, boostType: nil,
                boostExpiresAt: nil, createdAt: Date(), updatedAt: Date()
            )
        )
    }
    .padding()
    .background(AppTheme.Colors.background)
    .preferredColorScheme(.dark)
}
