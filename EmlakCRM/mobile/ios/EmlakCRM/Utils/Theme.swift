import SwiftUI

struct AppTheme {
    // Soft Blue Color Palette (inspired by modern real estate apps)
    static let primaryColor = Color(hex: "4A90E2") // Soft Blue
    static let primaryDark = Color(hex: "357ABD")
    static let secondaryColor = Color(hex: "5CB3FF") // Light Blue
    static let accentColor = Color(hex: "FFB84D") // Soft Orange/Gold
    static let backgroundColor = Color(hex: "F5F8FA") // Very light blue-gray
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "1A1A2E") // Dark blue-black
    static let textSecondary = Color(hex: "7B8794") // Gray-blue
    static let errorColor = Color(hex: "FF6B6B")
    static let warningColor = Color(hex: "FFB84D")
    static let successColor = Color(hex: "51CF66")
    static let infoColor = Color(hex: "4A90E2")

    // Soft Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "5CB3FF"), Color(hex: "4A90E2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [Color(hex: "51CF66"), Color(hex: "40C057")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "FFFFFF"), Color(hex: "EDF2F7")],
        startPoint: .top,
        endPoint: .bottom
    )

    // Typography
    static func largeTitle() -> Font { .system(size: 34, weight: .bold) }
    static func title() -> Font { .system(size: 28, weight: .bold) }
    static func title2() -> Font { .system(size: 22, weight: .semibold) }
    static func headline() -> Font { .system(size: 17, weight: .semibold) }
    static func body() -> Font { .system(size: 17, weight: .regular) }
    static func callout() -> Font { .system(size: 16, weight: .regular) }
    static func subheadline() -> Font { .system(size: 15, weight: .medium) }
    static func caption() -> Font { .system(size: 12, weight: .regular) }
    static func caption2() -> Font { .system(size: 11, weight: .medium) }

    // Spacing
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32

    // Corner Radius - More rounded for modern feel
    static let cornerRadius: CGFloat = 20
    static let mediumCornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12

    // Shadow - Softer shadows
    static let shadowRadius: CGFloat = 15
    static let shadowColor = Color.black.opacity(0.05)
    static let cardShadow = Color(hex: "4A90E2").opacity(0.08)
}

// Note: Color(hex:) extension is in Extensions.swift

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppTheme.cardShadow, radius: AppTheme.shadowRadius, x: 0, y: 8)
    }

    func modernCardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadow, radius: 12, x: 0, y: 4)
            )
    }

    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .font(AppTheme.headline())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppTheme.primaryGradient)
            .cornerRadius(AppTheme.mediumCornerRadius)
            .shadow(color: AppTheme.primaryColor.opacity(0.25), radius: 12, x: 0, y: 6)
    }

    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(AppTheme.primaryColor)
            .font(AppTheme.headline())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                    .fill(AppTheme.primaryColor.opacity(0.08))
            )
    }

    func destructiveButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .font(AppTheme.headline())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppTheme.errorColor)
            .cornerRadius(AppTheme.mediumCornerRadius)
            .shadow(color: AppTheme.errorColor.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Custom Modifiers
struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(Color.white.opacity(0.7))
                    .background(.ultraThinMaterial)
            )
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
}

// MARK: - Reusable Components

/// Modern Balance Card - inspired by the reference design
struct BalanceCard: View {
    let title: String
    let amount: String
    let subtitle: String?
    var gradient: LinearGradient = AppTheme.primaryGradient

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                Text(amount)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(gradient)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

/// Modern Stat Card - clean and minimal
struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let trend: String?
    var color: Color = AppTheme.primaryColor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)

                Spacer()

                if let trend = trend {
                    Text(trend)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.successColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.successColor.opacity(0.1))
                        .cornerRadius(6)
                }
            }

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.mediumCornerRadius)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 4)
    }
}
