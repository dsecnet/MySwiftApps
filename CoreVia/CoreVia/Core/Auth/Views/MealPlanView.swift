//
//  MealPlanView.swift
//  CoreVia
//
//  Qida planları siyahısı
//

import SwiftUI

struct MealPlanView: View {

    @StateObject private var manager = MealPlanManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showAddPlan: Bool = false
    @State private var selectedFilter: PlanType? = nil

    var filteredPlans: [MealPlan] {
        if let filter = selectedFilter {
            return manager.plansForType(filter)
        }
        return manager.plans
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc.localized("trainer_meal_plans"))
                            .font(.title)
                            .bold()
                            .foregroundColor(Color(UIColor.label))

                        Text(loc.localized("trainer_meal_subtitle"))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: - Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(
                                title: loc.localized("common_all"),
                                isSelected: selectedFilter == nil,
                                color: AppTheme.Colors.accent
                            ) {
                                selectedFilter = nil
                            }

                            ForEach(PlanType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.localizedName,
                                    isSelected: selectedFilter == type,
                                    color: type.color
                                ) {
                                    selectedFilter = type
                                }
                            }
                        }
                    }

                    // MARK: - Stats
                    HStack(spacing: 12) {
                        MiniStatCard(
                            value: "\(manager.totalPlans)",
                            label: loc.localized("trainer_total_plans"),
                            color: AppTheme.Colors.accent
                        )

                        MiniStatCard(
                            value: "\(manager.plansForType(.weightLoss).count)",
                            label: loc.localized("plan_type_weight_loss"),
                            color: AppTheme.Colors.accent
                        )

                        MiniStatCard(
                            value: "\(manager.plansForType(.weightGain).count)",
                            label: loc.localized("plan_type_weight_gain"),
                            color: AppTheme.Colors.accent
                        )
                    }

                    // MARK: - Plans List
                    if filteredPlans.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 50))
                                .foregroundColor(Color(UIColor.tertiaryLabel))

                            Text(loc.localized("trainer_no_meal_plans"))
                                .font(.headline)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            Text(loc.localized("trainer_add_first_meal_plan"))
                                .font(.caption)
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(filteredPlans) { plan in
                            MealPlanCard(plan: plan) {
                                manager.deletePlan(plan)
                            }
                        }
                    }
                }
                .padding()
            }

            // MARK: - FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAddPlan = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.Colors.accent)
                            .clipShape(Circle())
                            .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showAddPlan) {
            AddMealPlanView()
        }
    }
}

// MARK: - Meal Plan Card
struct MealPlanCard: View {
    let plan: MealPlan
    let onDelete: () -> Void
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: plan.planType.icon)
                    .foregroundColor(plan.planType.color)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title)
                        .font(.headline)
                        .foregroundColor(Color(UIColor.label))

                    Text(plan.planType.localizedName)
                        .font(.caption)
                        .foregroundColor(plan.planType.color)
                }

                Spacer()

                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label(loc.localized("common_delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(8)
                }
            }

            // Calorie target
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.accent)

                Text("\(plan.dailyCalorieTarget) \(loc.localized("common_kcal")) / \(loc.localized("trainer_daily"))")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }

            if let student = plan.assignedStudentName {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.accent)

                    Text(student)
                        .font(.caption)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }

            if !plan.meals.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.success)

                    Text("\(plan.meals.count) \(loc.localized("trainer_meals_count"))")
                        .font(.caption)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }

            // Completion status
            if plan.assignedStudentId != nil {
                HStack(spacing: 6) {
                    if plan.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.success)
                        Text(loc.localized("plan_completed"))
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.success)
                    } else {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(loc.localized("plan_status_pending"))
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }

            HStack {
                Text(plan.formattedDate)
                    .font(.caption2)
                    .foregroundColor(Color(UIColor.tertiaryLabel))

                Spacer()

                if let notes = plan.notes, !notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.caption2)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
}
