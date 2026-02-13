import SwiftUI

struct ContentView: View {

    @StateObject private var authManager = AuthManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @State private var showRegister: Bool = false
    @State private var onboardingCompleted: Bool = false
    @StateObject private var workoutManager = WorkoutManager.shared

    /// Trainer login olub amma hele verified deyilse → verifikasiya sehifesini goster
    private var needsTrainerVerification: Bool {
        guard let user = authManager.currentUser else { return false }
        return user.userType == "trainer" && user.verificationStatus != "verified"
    }

    /// Client onboarding tamamlanıb mı?
    private var needsOnboarding: Bool {
        guard let user = authManager.currentUser else { return false }
        return user.userType == "client" && !onboardingCompleted && !onboardingManager.isCompleted
    }

    var body: some View {
        Group {
            if authManager.isLoggedIn {
                if needsTrainerVerification {
                    TrainerVerificationView()
                } else if needsOnboarding {
                    OnboardingView(isCompleted: $onboardingCompleted)
                } else {
                    MainTabView(isLoggedIn: $authManager.isLoggedIn)
                        .environmentObject(workoutManager)
                }
            } else {
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
        .onChange(of: authManager.isLoggedIn) { loggedIn in
            if loggedIn {
                Task { await onboardingManager.checkStatus() }
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
                            TrainerContentView()
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
        }
        .ignoresSafeArea(.keyboard)
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
