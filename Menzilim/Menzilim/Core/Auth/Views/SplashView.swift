import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    // MARK: - Animation States
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var iconRotation: Double = -10
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var glowOpacity: Double = 0
    @State private var pulseScale: CGFloat = 0.8
    @State private var particleOpacity: Double = 0
    @State private var fadeOut: Bool = false

    var body: some View {
        ZStack {
            // MARK: - Background
            AppTheme.Colors.background
                .ignoresSafeArea()

            // Subtle radial gradient from center
            RadialGradient(
                colors: [
                    AppTheme.Colors.accent.opacity(0.06),
                    Color.clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 300
            )
            .ignoresSafeArea()

            // MARK: - Content
            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                // MARK: - Building Icon with Glow
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(AppTheme.Colors.accent.opacity(0.1), lineWidth: 1.5)
                        .frame(width: 180, height: 180)
                        .scaleEffect(pulseScale)
                        .opacity(glowOpacity * 0.6)

                    // Second pulse ring
                    Circle()
                        .stroke(AppTheme.Colors.accent.opacity(0.08), lineWidth: 1)
                        .frame(width: 220, height: 220)
                        .scaleEffect(pulseScale * 0.9)
                        .opacity(glowOpacity * 0.4)

                    // Glow effect behind icon
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.Colors.accent.opacity(0.25),
                                    AppTheme.Colors.accent.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: glowRadius)
                        .opacity(glowOpacity)

                    // Icon container with gradient background
                    ZStack {
                        // Inner circle background
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.Colors.accent.opacity(0.15),
                                        AppTheme.Colors.accent.opacity(0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 15,
                                    endRadius: 70
                                )
                            )
                            .frame(width: 140, height: 140)

                        // Building icon
                        Image(systemName: "building.2.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.accent,
                                        Color(hex: "0099CC")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 12, x: 0, y: 4)
                    }
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .rotationEffect(.degrees(iconRotation))

                // MARK: - App Name
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("app_name".localized)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .tracking(1)

                    Text("REAL ESTATE")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(8)
                        .foregroundColor(AppTheme.Colors.accent.opacity(0.7))
                        .opacity(subtitleOpacity)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)

                Spacer()

                // MARK: - Bottom indicator
                VStack(spacing: AppTheme.Spacing.sm) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent.opacity(0.5)))
                        .scaleEffect(0.8)
                }
                .opacity(subtitleOpacity)
                .padding(.bottom, AppTheme.Spacing.xxxl + 20)
            }
        }
        .opacity(fadeOut ? 0 : 1)
        .onAppear {
            startAnimations()
            scheduleDismiss()
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        // Icon spring animation - scale up and rotate to center
        withAnimation(.spring(response: 0.9, dampingFraction: 0.6).delay(0.15)) {
            iconScale = 1.0
            iconOpacity = 1.0
            iconRotation = 0
        }

        // Text slide up and fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.45)) {
            textOpacity = 1.0
            textOffset = 0
        }

        // Subtitle fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            subtitleOpacity = 1.0
        }

        // Glow pulse animation - continuous
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.3)) {
            glowRadius = 30
            glowOpacity = 1.0
        }

        // Pulse rings animation - continuous
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.4)) {
            pulseScale = 1.1
        }

        // Particle fade
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.6)) {
            particleOpacity = 1.0
        }
    }

    // MARK: - Auto Navigate
    private func scheduleDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.4)) {
                fadeOut = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isActive = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashView(isActive: .constant(true))
}
