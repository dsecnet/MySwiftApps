import SwiftUI

@main
struct MenzilimApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared

    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView(isActive: $showSplash)
                        .transition(.opacity)
                } else {
                    rootView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.02)),
                            removal: .opacity
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .environmentObject(authManager)
            .environmentObject(localizationManager)
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Root View Routing
    @ViewBuilder
    private var rootView: some View {
        switch authManager.authState {
        case .unknown:
            loadingView

        case .unauthenticated:
            if hasCompletedOnboarding {
                NavigationStack {
                    LoginView(viewModel: AuthViewModel())
                }
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }

        case .authenticated:
            MainTabView()
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.lg) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                    .scaleEffect(1.5)

                Text("loading".localized)
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }
}
