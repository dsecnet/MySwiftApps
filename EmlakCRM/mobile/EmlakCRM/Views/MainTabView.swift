//
//  MainTabView.swift
//  EmlakCRM
//
//  Main Tab Navigation
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
            DashboardView()
                .tabItem {
                    Label("Ana Səhifə", systemImage: "house.fill")
                }
                .tag(0)

            // Properties
            PropertiesListView()
                .tabItem {
                    Label("Əmlaklar", systemImage: "building.2.fill")
                }
                .tag(1)

            // Clients
            ClientsListView()
                .tabItem {
                    Label("Müştərilər", systemImage: "person.2.fill")
                }
                .tag(2)

            // Activities (Coming Soon)
            ComingSoonView(title: "Aktivliklər", icon: "calendar")
                .tabItem {
                    Label("Aktivliklər", systemImage: "calendar")
                }
                .tag(3)

            // Deals (Coming Soon)
            ComingSoonView(title: "Deal-lər", icon: "briefcase")
                .tabItem {
                    Label("Deal-lər", systemImage: "briefcase.fill")
                }
                .tag(4)
        }
        .accentColor(AppTheme.primaryColor)
    }
}

// MARK: - Coming Soon View

struct ComingSoonView: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: icon)
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.primaryColor.opacity(0.3))

                    VStack(spacing: 12) {
                        Text("Tezliklə...")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Bu bölmə hazırlanır və tezliklə əlavə olunacaq")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(AppTheme.primaryColor.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
