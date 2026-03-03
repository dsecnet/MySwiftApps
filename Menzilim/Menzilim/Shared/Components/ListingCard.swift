import SwiftUI

// MARK: - Listing Card Component
struct ListingCard: View {
    let listing: Listing
    var isFavorite: Bool = false
    var onFavoriteTap: (() -> Void)? = nil
    var onContactTap: (() -> Void)? = nil

    // Optional agent info to display on the card
    var agent: Agent? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // MARK: - Image Section
            imageSection

            // MARK: - Content Section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                // Price
                priceRow

                // Address
                addressRow

                // Details row (beds, baths, area)
                detailsRow

                // Agent info row
                if agent != nil {
                    agentRow
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }

    // MARK: - Image Section
    private var imageSection: some View {
        ZStack(alignment: .top) {
            // Listing Image
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
            .cornerRadius(AppTheme.CornerRadius.large, corners: [.topLeft, .topRight])

            // Overlays on image
            HStack(alignment: .top) {
                // Badge (NEW / VIP / PREMIUM)
                if listing.isBoosted, let boostType = listing.boostType {
                    boostBadge(for: boostType)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppTheme.Spacing.sm) {
                    // Favorite button
                    favoriteButton

                    // Rating badge
                    ratingBadge
                }
            }
            .padding(AppTheme.Spacing.md)
        }
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

    // MARK: - Boost Badge
    private func boostBadge(for type: BoostType) -> some View {
        Text(type.displayName)
            .font(AppTheme.Fonts.smallBold())
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(badgeColor(for: type))
            .cornerRadius(AppTheme.CornerRadius.small)
    }

    private func badgeColor(for type: BoostType) -> Color {
        switch type {
        case .vip:
            return AppTheme.Colors.vipBadge
        case .premium:
            return AppTheme.Colors.premiumBadge
        case .standard:
            return AppTheme.Colors.newBadge
        }
    }

    // MARK: - Favorite Button
    private var favoriteButton: some View {
        Button {
            onFavoriteTap?()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isFavorite ? AppTheme.Colors.error : .white)
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.4))
                .clipShape(Circle())
        }
    }

    // MARK: - Rating Badge
    private var ratingBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.gold)
            Text(String(format: "%.1f", 4.5))
                .font(AppTheme.Fonts.smallBold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(Color.black.opacity(0.5))
        .cornerRadius(AppTheme.CornerRadius.small)
    }

    // MARK: - Price Row
    private var priceRow: some View {
        HStack {
            Text(listing.formattedPrice)
                .font(AppTheme.Fonts.price())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            // Listing type tag
            Text(listing.listingType.displayKey.localized)
                .font(AppTheme.Fonts.smallBold())
                .foregroundColor(AppTheme.Colors.accent)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(AppTheme.Colors.accent.opacity(0.15))
                .cornerRadius(AppTheme.CornerRadius.small)
        }
    }

    // MARK: - Address Row
    private var addressRow: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textTertiary)

            Text("\(listing.district), \(listing.city)")
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(1)
        }
    }

    // MARK: - Details Row (beds, baths, area)
    private var detailsRow: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            // Rooms / Beds
            detailItem(icon: "bed.double.fill", value: "\(listing.rooms)", label: "beds".localized)

            divider

            // Baths
            detailItem(icon: "shower.fill", value: "1", label: "baths".localized)

            divider

            // Area
            detailItem(icon: "ruler.fill", value: "\(Int(listing.areaSqm))", label: "area_sqm".localized)

            if let floorInfo = listing.floorInfo {
                divider
                detailItem(icon: "building.2.fill", value: floorInfo, label: "floor".localized)
            }
        }
        .padding(.top, AppTheme.Spacing.xs)
    }

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

    private var divider: some View {
        Rectangle()
            .fill(AppTheme.Colors.inputBorder)
            .frame(width: 1, height: 16)
    }

    // MARK: - Agent Row
    @ViewBuilder
    private var agentRow: some View {
        if let agent = agent {
            Divider()
                .background(AppTheme.Colors.inputBorder)
                .padding(.top, AppTheme.Spacing.xs)

            HStack(spacing: AppTheme.Spacing.sm) {
                // Agent avatar
                AsyncImage(url: URL(string: agent.avatarUrl ?? "")) { phase in
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
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            )
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())

                // Agent name
                Text(agent.displayName)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                Spacer()

                // Contact button
                Button {
                    onContactTap?()
                } label: {
                    Text("contact".localized)
                        .font(AppTheme.Fonts.smallBold())
                        .foregroundColor(AppTheme.Colors.accent)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.accent.opacity(0.12))
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
            }
        }
    }
}

// MARK: - Compact Listing Card (Horizontal scroll variant)
struct CompactListingCard: View {
    let listing: Listing
    var isFavorite: Bool = false
    var onFavoriteTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: listing.mainImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16 / 10, contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(AppTheme.Colors.surfaceBackground)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            )
                    }
                }
                .frame(width: 260, height: 160)
                .clipped()
                .cornerRadius(AppTheme.CornerRadius.medium)

                // Overlays
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    // Favorite
                    Button {
                        onFavoriteTap?()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isFavorite ? AppTheme.Colors.error : .white)
                            .frame(width: 30, height: 30)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }

                    // Boost badge
                    if listing.isBoosted, let boostType = listing.boostType {
                        Text(boostType.displayName)
                            .font(AppTheme.Fonts.smallBold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: boostType.color))
                            .cornerRadius(AppTheme.CornerRadius.small)
                    }
                }
                .padding(AppTheme.Spacing.sm)
            }

            // Price
            Text(listing.formattedPrice)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Spacing.sm)

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
            .padding(.horizontal, AppTheme.Spacing.sm)

            // Quick info
            HStack(spacing: AppTheme.Spacing.md) {
                Label("\(listing.rooms)", systemImage: "bed.double.fill")
                Label("\(Int(listing.areaSqm))m\u{00B2}", systemImage: "ruler.fill")
            }
            .font(AppTheme.Fonts.small())
            .foregroundColor(AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
        .frame(width: 260)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

// MARK: - Corner Radius Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
