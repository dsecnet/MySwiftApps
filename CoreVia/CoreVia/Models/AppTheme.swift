
import SwiftUI

struct AppTheme {

    // MARK: - Colors
    struct Colors {
        // === Base (system adaptive) ===
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let primaryText = Color(UIColor.label)
        static let secondaryText = Color(UIColor.secondaryLabel)
        static let tertiaryText = Color(UIColor.tertiaryLabel)
        static let placeholderText = Color(UIColor.placeholderText)
        static let separator = Color(UIColor.separator)

        // === Brand ===
        static let accent = Color.red
        static let accentDark = Color(red: 0.7, green: 0.0, blue: 0.0)
        static let accentLight = Color.red.opacity(0.15)

        // === Semantic ===
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)
        static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
        static let info = Color(red: 0.3, green: 0.3, blue: 0.3)

        // === Interactive ===
        static let buttonPrimary = Color.red
        static let buttonSecondary = Color(UIColor.secondarySystemBackground)
        static let link = Color.red

        // === Category (trainer specialties) ===
        static let catFitness = Color.red
        static let catStrength = Color(red: 0.85, green: 0.2, blue: 0.15)
        static let catCardio = Color(red: 0.95, green: 0.3, blue: 0.3)
        static let catYoga = Color(red: 0.6, green: 0.1, blue: 0.1)
        static let catNutrition = Color(red: 0.4, green: 0.0, blue: 0.0)

        // === Meal type ===
        static let mealBreakfast = Color(red: 0.9, green: 0.35, blue: 0.25)
        static let mealLunch = Color(red: 0.8, green: 0.2, blue: 0.2)
        static let mealDinner = Color(red: 0.55, green: 0.1, blue: 0.1)
        static let mealSnack = Color(red: 0.7, green: 0.15, blue: 0.15)

        // === Plan type ===
        static let planWeightLoss = Color(red: 0.85, green: 0.25, blue: 0.2)
        static let planWeightGain = Color(red: 0.7, green: 0.1, blue: 0.1)
        static let planStrength = Color.red

        // === Activity type ===
        static let actWalking = Color(red: 0.8, green: 0.15, blue: 0.15)
        static let actRunning = Color.red
        static let actCycling = Color(red: 0.55, green: 0.05, blue: 0.05)

        // === Progress ===
        static let progressHigh = Color(red: 0.2, green: 0.78, blue: 0.35)
        static let progressMedium = Color.red.opacity(0.7)
        static let progressLow = Color.red

        // === Stats card icons ===
        static let statIcon = Color.red

        // === Gradient helpers ===
        static let gradientStart = Color.red.opacity(0.3)
        static let gradientEnd = Color.red

        static let premiumGradientStart = Color(red: 0.15, green: 0.0, blue: 0.0)
        static let premiumGradientEnd = Color.red

        // === Avatar palette (for student/user avatars) ===
        static let avatarPalette: [Color] = [
            Color.red,
            Color(red: 0.85, green: 0.2, blue: 0.15),
            Color(red: 0.7, green: 0.1, blue: 0.1),
            Color(red: 0.55, green: 0.05, blue: 0.05),
            Color(red: 0.4, green: 0.0, blue: 0.0),
            Color(red: 0.95, green: 0.3, blue: 0.3),
            Color(red: 0.6, green: 0.1, blue: 0.1),
            Color(red: 0.75, green: 0.15, blue: 0.15),
        ]

        // === Star rating ===
        static let starFilled = Color.red
        static let starEmpty = Color(UIColor.systemGray4)

        // === Badge ===
        static let badgeVerified = Color(red: 0.2, green: 0.78, blue: 0.35)
        static let badgePending = Color(red: 0.9, green: 0.55, blue: 0.1)
        static let badgeRejected = Color.red

        // === Deprecated aliases (for gradual migration) ===
        static let primary = accent
        static let secondary = accentDark
    }

    // MARK: - Spacing
    struct Spacing {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }
}

// MARK: - View Extension
extension View {
    func appBackground() -> some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            self
        }
    }
}
