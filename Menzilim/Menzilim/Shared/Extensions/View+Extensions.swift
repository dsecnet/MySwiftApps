import SwiftUI

// MARK: - Card Style Modifier
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.CornerRadius.medium
    var padding: CGFloat = AppTheme.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(cornerRadius)
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.bodyBold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                isEnabled ?
                    LinearGradient(
                        colors: [AppTheme.Colors.accent, AppTheme.Colors.primaryGradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [AppTheme.Colors.inputBackground, AppTheme.Colors.inputBackground],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.bodyBold())
            .foregroundColor(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(cornerRadius: CGFloat = AppTheme.CornerRadius.medium, padding: CGFloat = AppTheme.Spacing.lg) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, padding: padding))
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func shimmerEffect() -> some View {
        self.redacted(reason: .placeholder)
            .shimmering()
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.1),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
