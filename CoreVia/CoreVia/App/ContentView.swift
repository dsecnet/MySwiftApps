import SwiftUI

struct ContentView: View {

    @StateObject private var authManager = AuthManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var showRegister: Bool = false
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var hasSeenPermissions: Bool = UserDefaults.standard.bool(forKey: "hasSeenPermissions")
    @Environment(\.scenePhase) private var scenePhase

    // Face ID / Biometric Lock
    @State private var isUnlocked = false
    @State private var isAuthenticating = false

    /// Face ID / Touch ID aktiv və istifadəçi login olub?
    private var needsBiometricUnlock: Bool {
        return authManager.isLoggedIn && settingsManager.faceIDEnabled && !isUnlocked
    }

    /// İlk açılışda permission screen lazımdır?
    private var needsPermissions: Bool {
        return !hasSeenPermissions
    }

    /// Trainer verification deaktiv — trainer birbaşa app-a daxil olur
    private var needsTrainerVerification: Bool {
        return false
    }

    /// Client onboarding tamamlanıb mı? (yalnız server state-ə əsasən)
    private var needsOnboarding: Bool {
        guard let user = authManager.currentUser else { return false }
        return user.userType == "client" && !onboardingManager.isCompleted
    }

    var body: some View {
        Group {
            if needsPermissions {
                PermissionsView(isGranted: $hasSeenPermissions)
            } else if authManager.isLoggedIn {
                if needsBiometricUnlock {
                    // Kilid ekranı — Face ID / Touch ID ilə açılmalıdır
                    BiometricLockView(
                        isAuthenticating: $isAuthenticating,
                        onAuthenticate: { authenticateBiometric() }
                    )
                } else if needsTrainerVerification {
                    TrainerVerificationView()
                } else if needsOnboarding {
                    OnboardingView()
                } else {
                    MainTabView(isLoggedIn: $authManager.isLoggedIn)
                        .environmentObject(workoutManager)
                }
            } else {
                NavigationStack {
                    if showRegister {
                        RegisterView(showRegister: $showRegister)
                    } else {
                        LoginView(
                            isLoggedIn: $authManager.isLoggedIn,
                            showRegister: $showRegister
                        )
                    }
                }
            }
        }
        .onAppear {
            // App açılanda login olubsa onboarding statusu yoxla
            if authManager.isLoggedIn {
                Task { await onboardingManager.checkStatus() }
            }
            // Face ID aktiv deyilsə, birbaşa unlock et
            if !settingsManager.faceIDEnabled {
                isUnlocked = true
            } else if authManager.isLoggedIn {
                authenticateBiometric()
            }
        }
        .onChange(of: authManager.isLoggedIn) { loggedIn in
            if loggedIn {
                Task { await onboardingManager.checkStatus() }
                // Yeni login olduqda unlock et (login özü autentifikasiyadır)
                isUnlocked = true
            } else {
                // Logout olduqda onboarding cache-i təmizlə
                onboardingManager.resetOnLogout()
                // Logout olduqda kilidi sıfırla
                isUnlocked = false
            }
        }
        .onChange(of: scenePhase) { phase in
            // App background-a gedib qayıdanda yenidən Face ID tələb et
            if phase == .background && settingsManager.faceIDEnabled {
                isUnlocked = false
            }
            if phase == .active && settingsManager.faceIDEnabled && authManager.isLoggedIn && !isUnlocked {
                authenticateBiometric()
            }
        }
    }

    // MARK: - Biometric Authentication
    private func authenticateBiometric() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        settingsManager.authenticateWithBiometrics { success, error in
            isAuthenticating = false
            if success {
                isUnlocked = true
            }
        }
    }
}

// MARK: - Biometric Lock Screen
struct BiometricLockView: View {
    @Binding var isAuthenticating: Bool
    let onAuthenticate: () -> Void
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App icon
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.accent.opacity(0.15))
                        .frame(width: 120, height: 120)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.Colors.accent)
                }

                VStack(spacing: 8) {
                    Text("CoreVia")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(loc.localized("biometric_unlock_desc") == "biometric_unlock_desc"
                         ? "Davam etmək üçün şəxsiyyətinizi təsdiqləyin"
                         : loc.localized("biometric_unlock_desc"))
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Unlock button
                Button {
                    onAuthenticate()
                } label: {
                    HStack(spacing: 12) {
                        if isAuthenticating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "faceid")
                                .font(.system(size: 22))
                            Text(loc.localized("biometric_unlock") == "biometric_unlock"
                                 ? "Kilidi aç"
                                 : loc.localized("biometric_unlock"))
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(16)
                }
                .disabled(isAuthenticating)
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {

    @Binding var isLoggedIn: Bool
    @State private var selectedTab: Int = 0
    @EnvironmentObject var workoutManager: WorkoutManager
    @ObservedObject private var profileManager = UserProfileManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    var isTrainer: Bool {
        profileManager.userProfile.userType == .trainer
    }

    init(isLoggedIn: Binding<Bool>) {
        _isLoggedIn = isLoggedIn

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground // Adaptiv

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel // Adaptiv
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel // Adaptiv
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.Colors.accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.Colors.accent)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        if isTrainer {
                            TrainerHomeView()
                                .navigationTitle("")
                        } else {
                            HomeView()
                                .navigationTitle("")
                        }
                    }
                case 1:
                    NavigationStack {
                        if isTrainer {
                            TrainingPlanView()
                                .navigationTitle("")
                        } else {
                            WorkoutView()
                                .navigationTitle("")
                        }
                    }
                case 2:
                    NavigationStack {
                        if isTrainer {
                            MealPlanView()
                                .navigationTitle("")
                        } else {
                            FoodView()
                                .navigationTitle("")
                        }
                    }
                case 3:
                    NavigationStack {
                        ConversationsView()
                            .navigationTitle("")
                    }
                case 4:
                    NavigationStack {
                        if isTrainer {
                            TrainerHubView()
                                .navigationTitle("")
                        } else {
                            ActivitiesView()
                                .navigationTitle("")
                        }
                    }
                case 5:
                    NavigationStack {
                        ProfileView(isLoggedIn: $isLoggedIn)
                            .navigationTitle(loc.localized("tab_profile"))
                    }
                default:
                    NavigationStack {
                        if isTrainer {
                            TrainerHomeView()
                                .navigationTitle("")
                        } else {
                            HomeView()
                                .navigationTitle("")
                        }
                    }
                }
            }

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, isTrainer: isTrainer)
                .zIndex(999) // Tab bar hər zaman yuxarıda olsun
        }
    }
}

// MARK: - Placeholder
struct PlaceholderView: View {
    let title: String
    let icon: String
    let color: Color
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(color)

                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(UIColor.label))

                Text(loc.localized("common_loading"))
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
    }
}

// #Preview { // iOS 17+ only
//     ContentView()
// }
