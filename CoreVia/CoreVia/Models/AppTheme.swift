
import SwiftUI

struct AppTheme {
    
    // MARK: - Colors (Adaptiv)
    struct Colors {
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let primaryText = Color(UIColor.label)
        static let secondaryText = Color(UIColor.secondaryLabel)
        static let tertiaryText = Color(UIColor.tertiaryLabel)
        static let placeholderText = Color(UIColor.placeholderText)
        static let separator = Color(UIColor.separator)
        
        // Brand colors
        static let primary = Color.red
        static let secondary = Color.orange
        static let success = Color.green
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
