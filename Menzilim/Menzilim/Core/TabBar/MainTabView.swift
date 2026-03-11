import SwiftUI

// MARK: - Tab Item
enum MainTab: Int, CaseIterable {
    case home = 0
    case search = 1
    case create = 2
    case notifications = 3
    case profile = 4

    var titleKey: String {
        switch self {
        case .home: return "tab_home"
        case .search: return "tab_search"
        case .create: return "tab_create"
        case .notifications: return "tab_notifications"
        case .profile: return "tab_profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .create: return "plus.circle.fill"
        case .notifications: return "bell.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var isShowingCreateListing: Bool = false
    @StateObject private var notificationsViewModel = NotificationsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Tab Content
            tabContent
                .padding(.bottom, 70)

            // MARK: - Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $isShowingCreateListing) {
            CreateListingView()
        }
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .search:
            SearchView()
        case .create:
            // Handled via sheet
            Color.clear
        case .notifications:
            NotificationsView()
        case .profile:
            SettingsView()
        }
    }

    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                if tab == .create {
                    // Center elevated "+" button
                    createButton
                } else {
                    tabButton(tab)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.top, AppTheme.Spacing.md)
        .padding(.bottom, safeAreaBottomPadding)
        .background(
            AppTheme.Colors.tabBarBackground
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: -5)
        )
    }

    // MARK: - Tab Button
    private func tabButton(_ tab: MainTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.xs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 22))
                        .foregroundColor(
                            selectedTab == tab
                                ? AppTheme.Colors.tabBarActive
                                : AppTheme.Colors.tabBarInactive
                        )

                    // Notification badge
                    if tab == .notifications && notificationsViewModel.unreadCount > 0 {
                        notificationBadge
                    }
                }

                Text(tab.titleKey.localized)
                    .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(
                        selectedTab == tab
                            ? AppTheme.Colors.tabBarActive
                            : AppTheme.Colors.tabBarInactive
                    )
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Create Button (Elevated Center)
    private var createButton: some View {
        Button {
            isShowingCreateListing = true
        } label: {
            ZStack {
                // Glow
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.2))
                    .frame(width: 64, height: 64)

                // Button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent, Color(hex: "0099CC")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .offset(y: -16)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Notification Badge
    private var notificationBadge: some View {
        Text("\(min(notificationsViewModel.unreadCount, 99))")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(.white)
            .frame(minWidth: 16, minHeight: 16)
            .background(AppTheme.Colors.error)
            .clipShape(Circle())
            .offset(x: 8, y: -4)
    }

    // MARK: - Safe Area Bottom Padding
    private var safeAreaBottomPadding: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? 20 : 12
    }

}

// MARK: - Preview
#Preview {
    MainTabView()
}
