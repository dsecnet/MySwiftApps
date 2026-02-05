//
//  TrainerHomeView.swift
//  CoreVia
//

import SwiftUI

struct TrainerHomeView: View {

    @StateObject private var dashboardManager = TrainerDashboardManager.shared
    @StateObject private var profileManager = UserProfileManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    statsCardsSection

                    if let stats = dashboardManager.stats {
                        if stats.students.isEmpty {
                            emptyStudentsSection
                        } else {
                            studentProgressSection(stats.students)
                            statsSummarySection(stats.statsSummary)
                        }
                    }

                    quickActionsSection
                }
                .padding()
            }

            if dashboardManager.isLoading && dashboardManager.stats == nil {
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
        .onAppear {
            Task { await dashboardManager.fetchStats() }
        }
        .refreshable {
            await dashboardManager.fetchStats()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent.opacity(0.3), AppTheme.Colors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                if let image = ProfileImageManager.shared.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                } else {
                    Text(String(profileManager.userProfile.name.prefix(1)).uppercased())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(loc.localized("trainer_hello")) 👋")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                Text(profileManager.userProfile.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            Spacer()

            Button {
                Task { await dashboardManager.fetchStats() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .padding(10)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Stats Cards (2x2 Grid)
    private var statsCardsSection: some View {
        let stats = dashboardManager.stats

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                DashboardStatCard(
                    icon: "person.2.fill",
                    value: "\(stats?.totalSubscribers ?? 0)",
                    label: loc.localized("dashboard_total_subscribers"),
                    color: AppTheme.Colors.accent
                )

                DashboardStatCard(
                    icon: "person.fill.checkmark",
                    value: "\(stats?.activeStudents ?? 0)",
                    label: loc.localized("dashboard_active_students"),
                    color: AppTheme.Colors.accent
                )
            }

            HStack(spacing: 12) {
                DashboardStatCard(
                    icon: "creditcard.fill",
                    value: "\(stats?.currency ?? "₼") \(String(format: "%.0f", stats?.monthlyEarnings ?? 0))",
                    label: loc.localized("dashboard_monthly_earnings"),
                    color: AppTheme.Colors.accent
                )

                DashboardStatCard(
                    icon: "doc.text.fill",
                    value: "\((stats?.totalTrainingPlans ?? 0) + (stats?.totalMealPlans ?? 0))",
                    label: loc.localized("dashboard_total_plans"),
                    color: AppTheme.Colors.accentDark
                )
            }
        }
    }

    // MARK: - Empty Students
    private var emptyStudentsSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 44))
                .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))

            Text(loc.localized("dashboard_no_students"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(loc.localized("dashboard_no_students_desc"))
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }

    // MARK: - Student Progress
    private func studentProgressSection(_ students: [DashboardStudentSummary]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loc.localized("dashboard_student_progress"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                Text("\(students.count) \(loc.localized("trainer_students").lowercased())")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            ForEach(students) { student in
                DashboardStudentRow(student: student)
            }
        }
    }

    // MARK: - Stats Summary
    private func statsSummarySection(_ summary: DashboardStatsSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(AppTheme.Colors.accent)
                Text(loc.localized("dashboard_stats_summary"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            VStack(spacing: 10) {
                SummaryRow(
                    icon: "figure.strengthtraining.traditional",
                    label: loc.localized("dashboard_avg_workouts"),
                    value: String(format: "%.1f", summary.avgStudentWorkoutsPerWeek),
                    color: AppTheme.Colors.accent
                )

                SummaryRow(
                    icon: "flame.fill",
                    label: loc.localized("dashboard_total_workouts"),
                    value: "\(summary.totalWorkoutsAllStudents)",
                    color: AppTheme.Colors.accent
                )

                SummaryRow(
                    icon: "scalemass.fill",
                    label: loc.localized("dashboard_avg_weight"),
                    value: summary.avgStudentWeight > 0 ? "\(String(format: "%.1f", summary.avgStudentWeight)) \(loc.localized("unit_kg"))" : "—",
                    color: AppTheme.Colors.accent
                )
            }
            .padding(14)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(14)
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("trainer_quick_actions"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 12) {
                DashboardQuickAction(
                    title: loc.localized("trainer_new_training"),
                    icon: "figure.strengthtraining.traditional",
                    color: AppTheme.Colors.accent
                )

                DashboardQuickAction(
                    title: loc.localized("trainer_new_meal"),
                    icon: "fork.knife",
                    color: AppTheme.Colors.accent
                )
            }
        }
    }
}

// MARK: - Dashboard Stat Card
struct DashboardStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(AppTheme.Colors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
        .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Dashboard Student Row
struct DashboardStudentRow: View {
    let student: DashboardStudentSummary
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [student.avatarColor.opacity(0.3), student.avatarColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                Text(student.initials)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(student.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                HStack(spacing: 8) {
                    if let weight = student.weight {
                        HStack(spacing: 3) {
                            Image(systemName: "scalemass")
                                .font(.system(size: 10))
                            Text("\(Int(weight)) \(loc.localized("unit_kg"))")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    if let goal = student.goal {
                        Text(goal)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(student.avatarColor.opacity(0.7))
                            .cornerRadius(6)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 3) {
                    Text("\(student.thisWeekWorkouts)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(student.thisWeekWorkouts > 0 ? AppTheme.Colors.success : AppTheme.Colors.secondaryText)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(student.thisWeekWorkouts > 0 ? AppTheme.Colors.accent : AppTheme.Colors.secondaryText.opacity(0.5))
                }

                Text(loc.localized("dashboard_this_week"))
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
        .padding(12)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(student.avatarColor.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Summary Row
struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
        }
    }
}

// MARK: - Dashboard Quick Action
struct DashboardQuickAction: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
        .shadow(color: color.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    TrainerHomeView()
}
