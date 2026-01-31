//
//  TrainerHomeView.swift
//  CoreVia
//
//  Müəllim dashboard - tələbələr, plan statistikası, tez əməliyyatlar
//

import SwiftUI

struct TrainerHomeView: View {

    @StateObject private var trainingPlanManager = TrainingPlanManager.shared
    @StateObject private var mealPlanManager = MealPlanManager.shared
    @StateObject private var profileManager = UserProfileManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(loc.localized("trainer_hello")) 👋")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color(UIColor.label))

                        Text(profileManager.userProfile.name)
                            .font(.title2)
                            .foregroundColor(.red)
                            .bold()

                        Text(loc.localized("trainer_dashboard_subtitle"))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: - Stats Cards
                    HStack(spacing: 12) {
                        TrainerStatCard(
                            icon: "figure.strengthtraining.traditional",
                            value: "\(trainingPlanManager.totalPlans)",
                            label: loc.localized("trainer_training_plans"),
                            color: .red
                        )

                        TrainerStatCard(
                            icon: "fork.knife",
                            value: "\(mealPlanManager.totalPlans)",
                            label: loc.localized("trainer_meal_plans"),
                            color: .orange
                        )
                    }

                    HStack(spacing: 12) {
                        TrainerStatCard(
                            icon: "person.2.fill",
                            value: "\(DemoStudent.demoStudents.count)",
                            label: loc.localized("trainer_students"),
                            color: .blue
                        )

                        TrainerStatCard(
                            icon: "chart.bar.fill",
                            value: "\(trainingPlanManager.totalPlans + mealPlanManager.totalPlans)",
                            label: loc.localized("trainer_total_plans"),
                            color: .green
                        )
                    }

                    // MARK: - Students List
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.localized("trainer_my_students"))
                            .foregroundColor(Color(UIColor.label))
                            .font(.headline)

                        ForEach(DemoStudent.demoStudents) { student in
                            StudentCard(student: student)
                        }
                    }

                    // MARK: - Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.localized("trainer_quick_actions"))
                            .foregroundColor(Color(UIColor.label))
                            .font(.headline)

                        HStack(spacing: 12) {
                            TrainerQuickAction(
                                title: loc.localized("trainer_new_training"),
                                icon: "plus.circle.fill",
                                color: .red
                            )

                            TrainerQuickAction(
                                title: loc.localized("trainer_new_meal"),
                                icon: "plus.circle.fill",
                                color: .orange
                            )
                        }
                    }

                    // MARK: - Recent Plans
                    if !trainingPlanManager.plans.isEmpty || !mealPlanManager.plans.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(loc.localized("trainer_recent_plans"))
                                .foregroundColor(Color(UIColor.label))
                                .font(.headline)

                            ForEach(trainingPlanManager.plans.prefix(3)) { plan in
                                RecentPlanRow(
                                    title: plan.title,
                                    type: plan.planType.localizedName,
                                    student: plan.assignedStudentName ?? "-",
                                    icon: "figure.strengthtraining.traditional",
                                    color: plan.planType.color
                                )
                            }

                            ForEach(mealPlanManager.plans.prefix(3)) { plan in
                                RecentPlanRow(
                                    title: plan.title,
                                    type: plan.planType.localizedName,
                                    student: plan.assignedStudentName ?? "-",
                                    icon: "fork.knife",
                                    color: plan.planType.color
                                )
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Student Card
struct StudentCard: View {
    let student: DemoStudent

    var body: some View {
        HStack(spacing: 14) {
            Text(student.avatarEmoji)
                .font(.system(size: 36))

            VStack(alignment: .leading, spacing: 4) {
                Text(student.name)
                    .font(.body)
                    .bold()
                    .foregroundColor(Color(UIColor.label))

                Text(student.goal)
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(student.progressPercent)%")
                    .font(.headline)
                    .bold()
                    .foregroundColor(student.progressColor)

                ProgressView(value: student.progress)
                    .tint(student.progressColor)
                    .frame(width: 60)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
}

// MARK: - Trainer Quick Action (fərqli adla - HomeView-dakı QuickActionButton ilə toqquşmasın)
struct TrainerQuickAction: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(Color(UIColor.label))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
}

// MARK: - Recent Plan Row
struct RecentPlanRow: View {
    let title: String
    let type: String
    let student: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(Color(UIColor.label))
                    .lineLimit(1)

                Text("\(type) • \(student)")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
}
