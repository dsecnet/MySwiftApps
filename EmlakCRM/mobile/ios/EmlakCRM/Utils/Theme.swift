import SwiftUI

struct AppTheme {
    // Modern Color Palette
    static let primaryColor = Color(hex: "6366F1") // Indigo
    static let primaryDark = Color(hex: "4F46E5")
    static let secondaryColor = Color(hex: "10B981") // Emerald
    static let accentColor = Color(hex: "F59E0B") // Amber
    static let backgroundColor = Color(hex: "F8FAFC")
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "0F172A")
    static let textSecondary = Color(hex: "64748B")
    static let errorColor = Color(hex: "EF4444")
    static let warningColor = Color(hex: "F59E0B")
    static let successColor = Color(hex: "10B981")
    static let infoColor = Color(hex: "3B82F6")

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [Color(hex: "10B981"), Color(hex: "059669")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "F8FAFC"), Color(hex: "E2E8F0")],
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

    // Corner Radius
    static let cornerRadius: CGFloat = 16
    static let mediumCornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8

    // Shadow
    static let shadowRadius: CGFloat = 12
    static let shadowColor = Color.black.opacity(0.08)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)
    }

    func modernCardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.shadowColor, radius: 8, x: 0, y: 2)
            )
    }

    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .font(AppTheme.headline())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.primaryGradient)
            .cornerRadius(AppTheme.mediumCornerRadius)
            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(AppTheme.primaryColor)
            .font(AppTheme.headline())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.primaryColor.opacity(0.1))
            .cornerRadius(AppTheme.mediumCornerRadius)
    }

    func destructiveButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .font(AppTheme.headline())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.errorColor)
            .cornerRadius(AppTheme.mediumCornerRadius)
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
