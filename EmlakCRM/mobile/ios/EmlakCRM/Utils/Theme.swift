import SwiftUI

struct AppTheme {
    // Colors
    static let primaryColor = Color(hex: "2563EB")
    static let secondaryColor = Color(hex: "10B981")
    static let backgroundColor = Color(hex: "F9FAFB")
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "111827")
    static let textSecondary = Color(hex: "6B7280")
    static let errorColor = Color(hex: "EF4444")
    static let warningColor = Color(hex: "F59E0B")
    static let successColor = Color(hex: "10B981")

    // Typography
    static func largeTitle() -> Font { .system(size: 34, weight: .bold) }
    static func title() -> Font { .system(size: 28, weight: .semibold) }
    static func headline() -> Font { .system(size: 17, weight: .semibold) }
    static func body() -> Font { .system(size: 17, weight: .regular) }
    static func caption() -> Font { .system(size: 12, weight: .regular) }

    // Spacing
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing24: CGFloat = 24

    // Corner Radius
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8

    // Shadow
    static let shadowRadius: CGFloat = 8
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
            .shadow(color: Color.black.opacity(0.05), radius: AppTheme.shadowRadius, x: 0, y: 2)
    }

    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .font(AppTheme.headline())
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primaryColor)
            .cornerRadius(AppTheme.cornerRadius)
    }

    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(AppTheme.primaryColor)
            .font(AppTheme.headline())
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.primaryColor, lineWidth: 2)
            )
    }
}
