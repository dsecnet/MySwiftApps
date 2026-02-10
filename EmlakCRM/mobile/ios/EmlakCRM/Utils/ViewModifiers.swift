import SwiftUI

// View modifier for card styling
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
    }
}

// View modifier for primary button styling
struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primaryGradient)
            .cornerRadius(12)
            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// View modifier for secondary button styling
struct SecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppTheme.primaryColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primaryColor.opacity(0.1))
            .cornerRadius(12)
    }
}

// Extensions for easy use
extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }

    func primaryButtonStyle() -> some View {
        self.modifier(PrimaryButtonModifier())
    }

    func secondaryButtonStyle() -> some View {
        self.modifier(SecondaryButtonModifier())
    }
}
