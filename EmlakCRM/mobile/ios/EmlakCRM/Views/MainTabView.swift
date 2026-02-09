import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Ana Səhifə", systemImage: "house.fill")
                }
                .tag(0)

            PropertiesListView()
                .tabItem {
                    Label("Əmlaklar", systemImage: "building.2.fill")
                }
                .tag(1)

            ClientsListView()
                .tabItem {
                    Label("Müştərilər", systemImage: "person.2.fill")
                }
                .tag(2)

            Text("Fəaliyyətlər - Tezliklə")
                .font(AppTheme.title())
                .foregroundColor(AppTheme.textSecondary)
                .tabItem {
                    Label("Fəaliyyətlər", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(3)

            Text("Sövdələşmələr - Tezliklə")
                .font(AppTheme.title())
                .foregroundColor(AppTheme.textSecondary)
                .tabItem {
                    Label("Sövdələşmələr", systemImage: "dollarsign.circle.fill")
                }
                .tag(4)
        }
        .accentColor(AppTheme.primaryColor)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
