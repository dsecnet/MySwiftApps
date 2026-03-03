import SwiftUI

// MARK: - App Theme
struct AppTheme {

    // MARK: - Colors
    struct Colors {
        // Primary
        static let primary = Color("PrimaryBlue")
        static let primaryGradientStart = Color(hex: "00B4D8")
        static let primaryGradientEnd = Color(hex: "0077B6")

        // Background
        static let background = Color(hex: "0A0E1A")
        static let cardBackground = Color(hex: "111827")
        static let cardBackgroundLight = Color(hex: "1A2332")
        static let surfaceBackground = Color(hex: "151D2E")

        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "94A3B8")
        static let textTertiary = Color(hex: "64748B")

        // Accent
        static let accent = Color(hex: "00D4FF")
        static let accentCyan = Color(hex: "22D3EE")
        static let gold = Color(hex: "F59E0B")
        static let silver = Color(hex: "94A3B8")
        static let bronze = Color(hex: "CD7F32")

        // Status
        static let success = Color(hex: "10B981")
        static let warning = Color(hex: "F59E0B")
        static let error = Color(hex: "EF4444")
        static let info = Color(hex: "3B82F6")

        // Listing status
        static let statusActive = Color(hex: "10B981")
        static let statusPending = Color(hex: "F59E0B")
        static let statusSold = Color(hex: "3B82F6")
        static let statusArchived = Color(hex: "EF4444")

        // Boost badges
        static let vipBadge = Color(hex: "EF4444")
        static let premiumBadge = Color(hex: "8B5CF6")
        static let newBadge = Color(hex: "10B981")

        // Tab bar
        static let tabBarBackground = Color(hex: "0D1117")
        static let tabBarActive = Color(hex: "00D4FF")
        static let tabBarInactive = Color(hex: "64748B")

        // Input fields
        static let inputBackground = Color(hex: "1E293B")
        static let inputBorder = Color(hex: "334155")
        static let inputBorderActive = Color(hex: "00D4FF")

        // Gradient
        static var primaryGradient: LinearGradient {
            LinearGradient(
                colors: [primaryGradientStart, primaryGradientEnd],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        static var cyanGradient: LinearGradient {
            LinearGradient(
                colors: [Color(hex: "00D4FF"), Color(hex: "0099CC")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        static var backgroundGradient: LinearGradient {
            LinearGradient(
                colors: [Color(hex: "0A0E1A"), Color(hex: "111827")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Fonts
    struct Fonts {
        static func heading1() -> Font { .system(size: 28, weight: .bold) }
        static func heading2() -> Font { .system(size: 24, weight: .bold) }
        static func heading3() -> Font { .system(size: 20, weight: .semibold) }
        static func title() -> Font { .system(size: 18, weight: .semibold) }
        static func body() -> Font { .system(size: 16, weight: .regular) }
        static func bodyBold() -> Font { .system(size: 16, weight: .semibold) }
        static func caption() -> Font { .system(size: 14, weight: .regular) }
        static func captionBold() -> Font { .system(size: 14, weight: .medium) }
        static func small() -> Font { .system(size: 12, weight: .regular) }
        static func smallBold() -> Font { .system(size: 12, weight: .medium) }
        static func price() -> Font { .system(size: 22, weight: .bold) }
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let pill: CGFloat = 50
    }
}
