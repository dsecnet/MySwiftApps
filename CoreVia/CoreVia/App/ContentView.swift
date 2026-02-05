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
        .onChange(of: authManager.isLoggedIn) { _, loggedIn in
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
        TabView(selection: $selectedTab) {

            // MARK: - Tab 0: Home / Trainer Dashboard
            NavigationStack {
                if isTrainer {
                    TrainerHomeView()
                        .navigationTitle("")
                } else {
                    HomeView()
                        .navigationTitle("")
                }
            }
            .tabItem {
                Label(loc.localized("tab_home"), systemImage: "house.fill")
            }
            .tag(0)

            // MARK: - Tab 1: Workout / Training Plans
            NavigationStack {
                if isTrainer {
                    TrainingPlanView()
                        .navigationTitle("")
                } else {
                    WorkoutView()
                        .navigationTitle("")
                }
            }
            .tabItem {
                Label(
                    isTrainer ? loc.localized("tab_plans") : loc.localized("tab_workout"),
                    systemImage: "figure.strengthtraining.traditional"
                )
            }
            .tag(1)

            // MARK: - Tab 2: Food / Meal Plans
            NavigationStack {
                if isTrainer {
                    MealPlanView()
                        .navigationTitle("")
                } else {
                    FoodView()
                        .navigationTitle("")
                }
            }
            .tabItem {
                Label(
                    isTrainer ? loc.localized("tab_meal_plans") : loc.localized("tab_food"),
                    systemImage: "fork.knife"
                )
            }
            .tag(2)

            // MARK: - Tab 3: Chat (both trainer & client)
            NavigationStack {
                ConversationsView()
                    .navigationTitle("")
            }
            .tabItem {
                Label(loc.localized("chat_title"), systemImage: "bubble.left.and.bubble.right")
            }
            .tag(3)

            // MARK: - Tab 4: Activities (client) / Content (trainer)
            if !isTrainer {
                NavigationStack {
                    ActivitiesView()
                        .navigationTitle("")
                }
                .tabItem {
                    Label(loc.localized("activities_title"), systemImage: "figure.run")
                }
                .tag(4)
            }

            if isTrainer {
                NavigationStack {
                    TrainerContentView()
                        .navigationTitle("")
                }
                .tabItem {
                    Label(loc.localized("content_title"), systemImage: "doc.richtext")
                }
                .tag(4)
            }

            // MARK: - Tab 5: Profile
            NavigationStack {
                ProfileView(isLoggedIn: $isLoggedIn)
                    .navigationTitle(loc.localized("tab_profile"))
            }
            .tabItem {
                Label(loc.localized("tab_profile"), systemImage: "person.fill")
            }
            .tag(5)
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

#Preview {
    ContentView()
}
