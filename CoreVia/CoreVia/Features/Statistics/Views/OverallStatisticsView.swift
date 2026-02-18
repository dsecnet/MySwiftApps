//
//  OverallStatisticsView.swift
//  CoreVia
//
//  FIX E: Comprehensive statistics view showing all activities
//

import SwiftUI

struct OverallStatisticsView: View {

    @StateObject private var foodManager = FoodManager.shared
    @StateObject private var workoutManager = WorkoutManager.shared
    @StateObject private var trainingPlanManager = TrainingPlanManager.shared
    @StateObject private var mealPlanManager = MealPlanManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Weekly Nutrition Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Həftəlik Qida")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        VStack(spacing: 12) {
                            // Total calories
                            OverallStatRow(
                                icon: "flame.fill",
                                label: "Ümumi Kalori",
                                value: "\(calculateWeeklyCalories())",
                                unit: "kcal",
                                color: .orange
                            )

                            // Average daily calories
                            OverallStatRow(
                                icon: "chart.line.uptrend.xyaxis",
                                label: "Orta Gündəlik",
                                value: "\(calculateWeeklyCalories() / 7)",
                                unit: "kcal/gün",
                                color: .blue
                            )

                            // Meal count
                            OverallStatRow(
                                icon: "fork.knife",
                                label: "Yemək Sayı",
                                value: "\(calculateWeeklyMealCount())",
                                unit: "yemək",
                                color: .green
                            )
                        }
                        .padding()
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(16)

                        // Macros breakdown
                        HStack(spacing: 12) {
                            WeeklyMacroCard(
                                label: "Protein",
                                value: calculateWeeklyProtein(),
                                color: .red
                            )

                            WeeklyMacroCard(
                                label: "Karbohidrat",
                                value: calculateWeeklyCarbs(),
                                color: .orange
                            )

                            WeeklyMacroCard(
                                label: "Yağ",
                                value: calculateWeeklyFats(),
                                color: .yellow
                            )
                        }
                    }

                    // MARK: - Weekly Workouts Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Həftəlik Məşqlər")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        VStack(spacing: 12) {
                            // Total workouts
                            OverallStatRow(
                                icon: "figure.run",
                                label: "Ümumi Məşqlər",
                                value: "\(workoutManager.weekWorkoutCount)",
                                unit: "məşq",
                                color: .blue
                            )

                            // Completed workouts
                            OverallStatRow(
                                icon: "checkmark.circle.fill",
                                label: "Tamamlananlar",
                                value: "\(workoutManager.completedWorkouts.count)",
                                unit: "məşq",
                                color: .green
                            )

                            // Total minutes
                            OverallStatRow(
                                icon: "clock.fill",
                                label: "Ümumi Vaxt",
                                value: "\(calculateWeeklyMinutes())",
                                unit: "dəqiqə",
                                color: .purple
                            )

                            // Calories burned
                            OverallStatRow(
                                icon: "flame.fill",
                                label: "Yandırılan Kalori",
                                value: "\(calculateWeeklyCaloriesBurned())",
                                unit: "kcal",
                                color: .orange
                            )
                        }
                        .padding()
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(16)
                    }

                    // MARK: - Completed Plans Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tamamlanmış Planlar")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        VStack(spacing: 12) {
                            OverallStatRow(
                                icon: "dumbbell.fill",
                                label: "Tamamlanmış Məşq Planları",
                                value: "\(trainingPlanManager.plans.filter { $0.isCompleted }.count)",
                                unit: "plan",
                                color: .blue
                            )

                            OverallStatRow(
                                icon: "fork.knife",
                                label: "Tamamlanmış Qida Planları",
                                value: "\(mealPlanManager.plans.filter { $0.isCompleted }.count)",
                                unit: "plan",
                                color: .green
                            )

                            OverallStatRow(
                                icon: "chart.bar.fill",
                                label: "Ümumi Assign Planlar",
                                value: "\(trainingPlanManager.plans.filter { $0.assignedStudentId != nil }.count + mealPlanManager.plans.filter { $0.assignedStudentId != nil }.count)",
                                unit: "plan",
                                color: .purple
                            )
                        }
                        .padding()
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(16)
                    }

                    // MARK: - Overall Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ümumi Məlumat")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        VStack(spacing: 12) {
                            // Active days
                            OverallStatRow(
                                icon: "calendar.badge.checkmark",
                                label: "Aktiv Günlər",
                                value: "\(calculateActiveDays())",
                                unit: "gün",
                                color: .green
                            )

                            // Completion rate
                            OverallStatRow(
                                icon: "percent",
                                label: "Tamamlanma Faizi",
                                value: "\(calculateCompletionRate())",
                                unit: "%",
                                color: .blue
                            )
                        }
                        .padding()
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Ümumi Statistika")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }
        }
    }

    // MARK: - Calculation Methods

    private func calculateWeeklyCalories() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return foodManager.foodEntries
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + $1.calories }
    }

    private func calculateWeeklyMealCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return foodManager.foodEntries
            .filter { $0.date >= weekStart }
            .count
    }

    private func calculateWeeklyProtein() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return foodManager.foodEntries
            .filter { $0.date >= weekStart }
            .reduce(0.0) { $0 + ($1.protein ?? 0.0) }
    }

    private func calculateWeeklyCarbs() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return foodManager.foodEntries
            .filter { $0.date >= weekStart }
            .reduce(0.0) { $0 + ($1.carbs ?? 0.0) }
    }

    private func calculateWeeklyFats() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return foodManager.foodEntries
            .filter { $0.date >= weekStart }
            .reduce(0.0) { $0 + ($1.fats ?? 0.0) }
    }

    private func calculateWeeklyMinutes() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return workoutManager.workouts
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + $1.duration }
    }

    private func calculateWeeklyCaloriesBurned() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return workoutManager.workouts
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + ($1.caloriesBurned ?? 0) }
    }

    private func calculateActiveDays() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        let foodDays = Set(foodManager.foodEntries
            .filter { $0.date >= weekStart }
            .map { calendar.startOfDay(for: $0.date) })

        let workoutDays = Set(workoutManager.workouts
            .filter { $0.date >= weekStart }
            .map { calendar.startOfDay(for: $0.date) })

        return foodDays.union(workoutDays).count
    }

    private func calculateCompletionRate() -> Int {
        let total = workoutManager.weekWorkoutCount
        let completed = workoutManager.completedWorkouts.count

        guard total > 0 else { return 0 }
        return Int((Double(completed) / Double(total)) * 100)
    }
}

// MARK: - Overall Stat Row Component (renamed to avoid conflict with UserProfileView)
struct OverallStatRow: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Weekly Macro Card Component (renamed to avoid conflict)
struct WeeklyMacroCard: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(String(format: "%.1f", value))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text("gram")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    OverallStatisticsView()
}
