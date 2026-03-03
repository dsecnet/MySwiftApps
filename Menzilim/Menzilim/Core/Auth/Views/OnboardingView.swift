import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var hasCompletedOnboarding: Bool

    @State private var currentPage = 0
    @State private var navigateToLogin = false

    private let totalPages = 3

    // SF Symbols for each onboarding page illustration
    private let pageData: [(icon: String, secondaryIcon: String)] = [
        ("magnifyingglass.circle.fill", "house.fill"),
        ("person.2.badge.key.fill", "checkmark.shield.fill"),
        ("map.fill", "slider.horizontal.3")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                AppTheme.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Skip Button
                    HStack {
                        Spacer()

                        if currentPage < totalPages - 1 {
                            Button {
                                completeOnboarding()
                            } label: {
                                Text("skip".localized)
                                    .font(AppTheme.Fonts.captionBold())
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                                    .padding(.vertical, AppTheme.Spacing.sm)
                            }
                            .transition(.opacity)
                        }
                    }
                    .frame(height: 44)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .animation(.easeInOut(duration: 0.25), value: currentPage)

                    // MARK: - Page Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            OnboardingPageView(
                                pageIndex: index,
                                iconName: pageData[index].icon,
                                secondaryIconName: pageData[index].secondaryIcon,
                                titleKey: "onboarding_title_\(index + 1)",
                                descriptionKey: "onboarding_desc_\(index + 1)"
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentPage)

                    // MARK: - Bottom Section
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // Page Indicators
                        pageIndicators

                        // Action Buttons
                        VStack(spacing: AppTheme.Spacing.md) {
                            if currentPage == totalPages - 1 {
                                // Last page: "Get Started" button
                                Button {
                                    completeOnboarding()
                                } label: {
                                    HStack(spacing: AppTheme.Spacing.sm) {
                                        Text("get_started".localized)
                                            .font(AppTheme.Fonts.bodyBold())

                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                                    removal: .opacity
                                ))
                            } else {
                                // Next page button
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage += 1
                                    }
                                } label: {
                                    HStack(spacing: AppTheme.Spacing.sm) {
                                        Text("next".localized)
                                            .font(AppTheme.Fonts.bodyBold())

                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xxl)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                    .padding(.bottom, AppTheme.Spacing.xxxl + 10)
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView(viewModel: AuthViewModel())
            }
        }
    }

    // MARK: - Page Indicators
    private var pageIndicators: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.textTertiary.opacity(0.3)
                    )
                    .frame(
                        width: index == currentPage ? 28 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .padding(.bottom, AppTheme.Spacing.sm)
    }

    // MARK: - Complete Onboarding
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        navigateToLogin = true
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let pageIndex: Int
    let iconName: String
    let secondaryIconName: String
    let titleKey: String
    let descriptionKey: String

    @State private var imageOpacity: Double = 0
    @State private var imageScale: CGFloat = 0.85
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0
    @State private var floatingOffset: CGFloat = 0
    @State private var secondaryRotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // MARK: - Illustration Area
                ZStack {
                    // Dark card background
                    AppTheme.Colors.cardBackground
                        .overlay(
                            // Bottom gradient fade
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    AppTheme.Colors.background.opacity(0.5),
                                    AppTheme.Colors.background
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Decorative background elements
                    VStack {
                        HStack {
                            // Floating decorative circles
                            Circle()
                                .fill(AppTheme.Colors.accent.opacity(0.04))
                                .frame(width: 120, height: 120)
                                .offset(x: -30, y: 30 + floatingOffset)

                            Spacer()

                            Circle()
                                .fill(AppTheme.Colors.accent.opacity(0.03))
                                .frame(width: 80, height: 80)
                                .offset(x: 20, y: -20 - floatingOffset * 0.5)
                        }
                        Spacer()
                    }

                    // Main illustration
                    VStack(spacing: AppTheme.Spacing.lg) {
                        ZStack {
                            // Outer decorative ring
                            Circle()
                                .stroke(
                                    AppTheme.Colors.accent.opacity(0.08),
                                    lineWidth: 1
                                )
                                .frame(width: 260, height: 260)

                            // Middle ring
                            Circle()
                                .fill(AppTheme.Colors.accent.opacity(0.05))
                                .frame(width: 220, height: 220)

                            // Inner glow circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            AppTheme.Colors.accent.opacity(0.12),
                                            AppTheme.Colors.accent.opacity(0.03),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 200, height: 200)

                            // Primary icon
                            Image(systemName: iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppTheme.Colors.accent, Color(hex: "0099CC")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 16, x: 0, y: 8)

                            // Secondary floating icon
                            Image(systemName: secondaryIconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(AppTheme.Colors.accent.opacity(0.6))
                                .padding(AppTheme.Spacing.md)
                                .background(
                                    Circle()
                                        .fill(AppTheme.Colors.cardBackgroundLight)
                                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                                .offset(x: 80, y: -70)
                                .offset(y: floatingOffset)
                                .rotationEffect(.degrees(secondaryRotation))
                        }
                    }
                    .scaleEffect(imageScale)
                    .opacity(imageOpacity)
                }
                .frame(height: geometry.size.height * 0.52)
                .clipped()

                // MARK: - Text Content
                VStack(spacing: AppTheme.Spacing.md) {
                    Text(titleKey.localized)
                        .font(AppTheme.Fonts.heading1())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(descriptionKey.localized)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.xxl)
                .offset(y: textOffset)
                .opacity(textOpacity)

                Spacer()
            }
        }
        .onAppear {
            animateContent()
        }
    }

    // MARK: - Animation
    private func animateContent() {
        // Image entrance
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
            imageOpacity = 1.0
            imageScale = 1.0
        }

        // Text slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            textOffset = 0
            textOpacity = 1.0
        }

        // Floating animation - continuous
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.5)) {
            floatingOffset = -8
        }

        // Secondary icon subtle rotation
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true).delay(0.3)) {
            secondaryRotation = 5
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .environmentObject(AuthManager.shared)
        .environmentObject(LocalizationManager.shared)
}
