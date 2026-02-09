//
//  DashboardView.swift
//  EmlakCRM
//
//  Main Dashboard Screen
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        headerSection

                        // Stats Cards
                        if let stats = viewModel.dashboardStats {
                            statsCardsSection(stats: stats)
                            revenueSection(stats: stats)
                            activitiesSection(stats: stats)
                            recentActivitiesSection
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.loadDashboard()
                }

                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Əmlak CRM")
                        .font(AppTheme.headline())
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                await viewModel.loadDashboard()
                            }
                        } label: {
                            Label("Yenilə", systemImage: "arrow.clockwise")
                        }

                        Button(role: .destructive) {
                            authVM.logout()
                        } label: {
                            Label("Çıxış", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(
                    colors: [AppTheme.primaryColor.opacity(0.6), AppTheme.primaryColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(authVM.currentUser?.name.prefix(1).uppercased() ?? "A")
                        .foregroundColor(.white)
                        .font(AppTheme.headline())
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Salam 👋")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)

                Text(authVM.currentUser?.name ?? "Agent")
                    .font(AppTheme.title())
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()
        }
    }

    private func statsCardsSection(stats: DashboardStats) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    icon: "house.fill",
                    value: "\(stats.totalProperties)",
                    label: "Əmlak",
                    color: AppTheme.primaryColor
                )

                StatCard(
                    icon: "person.2.fill",
                    value: "\(stats.totalClients)",
                    label: "Müştəri",
                    color: AppTheme.secondaryColor
                )
            }

            HStack(spacing: 12) {
                StatCard(
                    icon: "calendar.badge.clock",
                    value: "\(stats.upcomingActivities)",
                    label: "Görüşlər",
                    color: AppTheme.warningColor
                )

                StatCard(
                    icon: "briefcase.fill",
                    value: "\(stats.totalDeals)",
                    label: "Deal-lər",
                    color: Color(hex: "8B5CF6")
                )
            }
        }
    }

    private func revenueSection(stats: DashboardStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Revenue")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 0) {
                // Total Revenue
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Revenue")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)

                        Text("\(String(format: "%.0f", stats.totalRevenue)) ₼")
                            .font(AppTheme.title())
                            .foregroundColor(AppTheme.primaryColor)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Komissiya")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)

                        Text("\(String(format: "%.0f", stats.totalCommission)) ₼")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.secondaryColor)
                    }
                }
                .padding()

                Divider()

                // This Month
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bu Ay")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)

                        Text("\(String(format: "%.0f", stats.thisMonthRevenue)) ₼")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Spacer()

                    Text("+\(String(format: "%.0f", stats.thisMonthCommission)) ₼")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.secondaryColor)
                }
                .padding()
            }
            .cardStyle()
        }
    }

    private func activitiesSection(stats: DashboardStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aktivliklər")
                .font(AppTheme.headline())

            HStack(spacing: 12) {
                VStack(spacing: 8) {
                    Text("\(stats.todayActivities)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)
                    Text("Bu gün")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardStyle()

                VStack(spacing: 8) {
                    Text("\(stats.overdueActivities)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.errorColor)
                    Text("Gecikmiş")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardStyle()
            }
        }
    }

    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Aktivliklər")
                .font(AppTheme.headline())

            if viewModel.recentActivities.isEmpty {
                Text("Hələ aktivlik yoxdur")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cardStyle()
            } else {
                ForEach(viewModel.recentActivities.prefix(5)) { activity in
                    RecentActivityRow(activity: activity)
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                    )
                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(label)
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
}

// MARK: - Recent Activity Row

struct RecentActivityRow: View {
    let activity: RecentActivity

    private var icon: String {
        switch activity.type {
        case "property": return "house.fill"
        case "client": return "person.fill"
        case "deal": return "briefcase.fill"
        case "activity": return "calendar"
        default: return "circle.fill"
        }
    }

    private var iconColor: Color {
        switch activity.type {
        case "property": return AppTheme.primaryColor
        case "client": return AppTheme.secondaryColor
        case "deal": return Color(hex: "8B5CF6")
        case "activity": return AppTheme.warningColor
        default: return AppTheme.textSecondary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)

                Text(activity.description)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()

            Text(timeAgo(from: activity.createdAt))
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .cardStyle()
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if days > 0 {
            return "\(days)g"
        } else if hours > 0 {
            return "\(hours)s"
        } else if minutes > 0 {
            return "\(minutes)d"
        } else {
            return "İndi"
        }
    }
}

// MARK: - Dashboard ViewModel

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var dashboardStats: DashboardStats?
    @Published var recentActivities: [RecentActivity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func loadDashboard() async {
        isLoading = true

        do {
            let response = try await apiService.getDashboard()
            dashboardStats = response.stats
            recentActivities = response.recentActivities
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
