import SwiftUI

struct ContentView: View {

    @State private var isLoggedIn: Bool = false
    @State private var showRegister: Bool = false
    @StateObject private var workoutManager = WorkoutManager.shared

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
                    .environmentObject(workoutManager)
            } else {
                if showRegister {
                    RegisterView(showRegister: $showRegister)
                } else {
                    LoginView(
                        isLoggedIn: $isLoggedIn,
                        showRegister: $showRegister
                    )
                }
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {

    @Binding var isLoggedIn: Bool
    @State private var selectedTab: Int = 0
    @EnvironmentObject var workoutManager: WorkoutManager

    init(isLoggedIn: Binding<Bool>) {
        _isLoggedIn = isLoggedIn

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground // Adaptiv

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel // Adaptiv
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel // Adaptiv
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = .red
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.red
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: - Home
            NavigationStack {
                HomeView()
                    .navigationTitle("")
            }
            .tabItem {
                Label("Əsas", systemImage: "house.fill")
            }
            .tag(0)

            // MARK: - Workout
            NavigationStack {
                WorkoutView()
                    .navigationTitle("")
            }
            .tabItem {
                Label("Məşq", systemImage: "figure.strengthtraining.traditional")
            }
            .tag(1)

            // MARK: - Food
            NavigationStack {
                FoodView()
                    .navigationTitle("")
            }
            .tabItem {
                Label("Qida", systemImage: "fork.knife")
            }
            .tag(2)

            // MARK: - Teachers
            NavigationStack {
                TeachersView()
                    .navigationTitle("")
            }
            .tabItem {
                Label("Müəllimlər", systemImage: "person.2.fill")
            }
            .tag(3)

            // MARK: - Profile
            NavigationStack {
                ProfileView(isLoggedIn: $isLoggedIn)
                    .navigationTitle("Profil")
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
            .tag(4)
        }
    }
}

// MARK: - Placeholder
struct PlaceholderView: View {
    let title: String
    let icon: String
    let color: Color

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

                Text("Tezliklə...")
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
    }
}

#Preview {
    ContentView()
}
