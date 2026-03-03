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
            createListingPlaceholder
        }
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            NavigationStack {
                homeContentPlaceholder
            }
        case .search:
            NavigationStack {
                searchContentPlaceholder
            }
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

    // MARK: - Home Content Placeholder
    private var homeContentPlaceholder: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("app_name".localized)
                            .font(AppTheme.Fonts.heading1())
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("Ev axtarışını asanlaşdırırıq")
                            .font(AppTheme.Fonts.caption())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    Spacer()

                    NavigationLink {
                        NotificationsView()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            if notificationsViewModel.unreadCount > 0 {
                                Circle()
                                    .fill(AppTheme.Colors.error)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)

                // Search bar placeholder
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    Text("search".localized)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    Spacer()
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(AppTheme.Colors.accent)
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Placeholder content
                VStack(spacing: AppTheme.Spacing.lg) {
                    Text("featured_listings".localized)
                        .font(AppTheme.Fonts.heading3())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppTheme.Spacing.lg)

                    Text("Elanlar yüklənir...")
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.xxxl)
                }
            }
        }
        .background(AppTheme.Colors.background)
        .navigationBarHidden(true)
    }

    // MARK: - Search Content Placeholder
    private var searchContentPlaceholder: some View {
        VStack {
            Text("search".localized)
                .font(AppTheme.Fonts.heading2())
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }

    // MARK: - Create Listing Placeholder
    private var createListingPlaceholder: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                Image(systemName: "plus.rectangle.on.rectangle")
                    .font(.system(size: 64))
                    .foregroundColor(AppTheme.Colors.accent)

                Text("post_property".localized)
                    .font(AppTheme.Fonts.heading2())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Yeni elan yerləşdirmək üçün bütün məlumatları doldurun")
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xxxl)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.background)
            .navigationTitle("post_property".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingCreateListing = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
