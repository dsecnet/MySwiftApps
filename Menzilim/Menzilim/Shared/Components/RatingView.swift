import SwiftUI

// MARK: - Rating View (Reusable Star Rating Component)
struct RatingView: View {
    @Binding var rating: Double
    var maxRating: Int = 5
    var starSize: CGFloat = 24
    var spacing: CGFloat = AppTheme.Spacing.xs
    var filledColor: Color = AppTheme.Colors.gold
    var emptyColor: Color = AppTheme.Colors.textTertiary
    var isInteractive: Bool = true

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                starImage(for: index)
                    .font(.system(size: starSize))
                    .foregroundColor(starColor(for: index))
                    .onTapGesture {
                        if isInteractive {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if rating == Double(index) {
                                    // Tap same star to deselect half
                                    rating = Double(index) - 0.5
                                } else {
                                    rating = Double(index)
                                }
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Star Image
    private func starImage(for index: Int) -> Image {
        let threshold = Double(index)
        if rating >= threshold {
            return Image(systemName: "star.fill")
        } else if rating >= threshold - 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }

    // MARK: - Star Color
    private func starColor(for index: Int) -> Color {
        let threshold = Double(index)
        if rating >= threshold - 0.5 {
            return filledColor
        } else {
            return emptyColor
        }
    }
}

// MARK: - Display-Only Rating View (Non-interactive convenience)
struct DisplayRatingView: View {
    let rating: Double
    var maxRating: Int = 5
    var starSize: CGFloat = 14
    var spacing: CGFloat = 2
    var filledColor: Color = AppTheme.Colors.gold
    var emptyColor: Color = AppTheme.Colors.textTertiary
    var showLabel: Bool = true

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            RatingView(
                rating: .constant(rating),
                maxRating: maxRating,
                starSize: starSize,
                spacing: spacing,
                filledColor: filledColor,
                emptyColor: emptyColor,
                isInteractive: false
            )

            if showLabel {
                Text(String(format: "%.1f", rating))
                    .font(AppTheme.Fonts.smallBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Compact Rating Badge
struct RatingBadge: View {
    let rating: Double
    var size: RatingBadgeSize = .regular

    enum RatingBadgeSize {
        case small, regular

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .regular: return 12
            }
        }

        var font: Font {
            switch self {
            case .small: return AppTheme.Fonts.small()
            case .regular: return AppTheme.Fonts.smallBold()
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return AppTheme.Spacing.xs
            case .regular: return AppTheme.Spacing.sm
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 2
            case .regular: return AppTheme.Spacing.xs
            }
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: size.iconSize))
                .foregroundColor(AppTheme.Colors.gold)

            Text(String(format: "%.1f", rating))
                .font(size.font)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 30) {
            // Interactive rating
            VStack(alignment: .leading, spacing: 8) {
                Text("Interactive (tappable)")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                RatingView(rating: .constant(3.5))
            }

            // Display-only rating
            VStack(alignment: .leading, spacing: 8) {
                Text("Display-only with label")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                DisplayRatingView(rating: 4.2)
            }

            // Small display rating
            VStack(alignment: .leading, spacing: 8) {
                Text("Small display (for cards)")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                DisplayRatingView(rating: 4.8, starSize: 12, spacing: 1)
            }

            // Rating badges
            VStack(alignment: .leading, spacing: 8) {
                Text("Rating badges")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                HStack(spacing: 12) {
                    RatingBadge(rating: 4.5, size: .regular)
                    RatingBadge(rating: 3.8, size: .small)
                }
            }

            // Different sizes
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom sizes")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                RatingView(
                    rating: .constant(4.0),
                    starSize: 32,
                    spacing: 6,
                    isInteractive: false
                )
            }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
