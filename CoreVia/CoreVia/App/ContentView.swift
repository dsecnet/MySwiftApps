import SwiftUI

struct ContentView: View {

    @State private var isLoggedIn: Bool = false
    @State private var showRegister: Bool = false

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
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

    init(isLoggedIn: Binding<Bool>) {
        _isLoggedIn = isLoggedIn

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black

        appearance.stackedLayoutAppearance.normal.iconColor =
            UIColor.white.withAlphaComponent(0.7)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
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
                    .navigationTitle("Ana")
            }
            .tabItem {
                Label("Əsas", systemImage: "house.fill")
            }
            .tag(0)

            // MARK: - Workout
            NavigationStack {
                PlaceholderView(
                    title: "Məşq Tracking",
                    icon: "figure.strengthtraining.traditional",
                    color: .red
                )
                .navigationTitle("Məşq")
            }
            .tabItem {
                Label("Məşq", systemImage: "figure.strengthtraining.traditional")
            }
            .tag(1)

            // MARK: - Food (UPDATED)
            NavigationStack {
                FoodView()
                    .navigationTitle("Qida")
            }
            .tabItem {
                Label("Qida", systemImage: "fork.knife")
            }
            .tag(2)

            // MARK: - Trainers
            NavigationStack {
                PlaceholderView(
                    title: "Müəllimlər",
                    icon: "person.2.fill",
                    color: .purple
                )
                .navigationTitle("Müəllimlər")
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
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(color)

                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Text("Tezliklə...")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ContentView()
}
