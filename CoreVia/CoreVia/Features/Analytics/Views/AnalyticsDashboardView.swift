import SwiftUI
import Charts

/// Analytics Dashboard View with Charts
struct AnalyticsDashboardView: View {
    @StateObject private var viewModel = AnalyticsDashboardViewModel()
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    loadingView
                } else if let dashboard = viewModel.dashboard {
                    VStack(spacing: 24) {
                        // Current Week Summary
                        currentWeekCard(dashboard.currentWeek)

                        // Weight Trend Chart
                        if !dashboard.weightTrend.isEmpty {
                            weightTrendChart(dashboard.weightTrend)
                        }

                        // Workout Trend Chart
                        workoutTrendChart(dashboard.workoutTrend)

                        // Nutrition Trend Chart
                        nutritionTrendChart(dashboard.nutritionTrend)

                        // Summary Stats
                        summaryStatsGrid(dashboard)
                    }
                    .padding()
                } else {
                    emptyStateView
                }
            }
            .navigationTitle(loc.localized("analytics_title"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadDashboard()
            }
            .task {
                await viewModel.loadDashboard()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Current Week Card

    private func currentWeekCard(_ week: WeeklyStatsResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.localized("analytics_this_week"))
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 16) {
                StatCard(
                    title: loc.localized("analytics_workouts"),
                    value: "\(week.workoutsCompleted)",
                    icon: "figure.run"
                )

                StatCard(
                    title: loc.localized("analytics_minutes"),
                    value: "\(week.totalWorkoutMinutes)",
                    icon: "clock"
                )
            }

            HStack(spacing: 16) {
                StatCard(
                    title: loc.localized("analytics_calories_burned"),
                    value: "\(week.caloriesBurned)",
                    icon: "flame"
                )

                StatCard(
                    title: loc.localized("analytics_consistency"),
                    value: "\(week.workoutConsistencyPercent)%",
                    icon: "chart.line.uptrend.xyaxis"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    // MARK: - Weight Trend Chart

    private func weightTrendChart(_ trend: [ProgressTrend]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("analytics_weight_trend"))
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            Chart(trend) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Weight", item.value)
                )
                .foregroundStyle(Color("PrimaryColor"))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", item.date),
                    y: .value("Weight", item.value)
                )
                .foregroundStyle(Color("PrimaryColor"))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 200)
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    // MARK: - Workout Trend Chart

    private func workoutTrendChart(_ trend: [WorkoutTrend]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("analytics_workout_trend"))
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            Chart(trend) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Minutes", item.minutes)
                )
                .foregroundStyle(Color("PrimaryColor").gradient)
            }
            .frame(height: 200)
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    // MARK: - Nutrition Trend Chart

    private func nutritionTrendChart(_ trend: [NutritionTrend]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("analytics_nutrition_trend"))
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            Chart(trend) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Calories", item.calories)
                )
                .foregroundStyle(Color.orange)
                .interpolationMethod(.catmullRom)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 200)
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    // MARK: - Summary Stats Grid

    private func summaryStatsGrid(_ dashboard: AnalyticsDashboardResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("analytics_last_30_days"))
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                SummaryStatCard(
                    title: loc.localized("analytics_total_workouts"),
                    value: "\(dashboard.totalWorkouts30d)",
                    icon: "dumbbell"
                )

                SummaryStatCard(
                    title: loc.localized("analytics_total_minutes"),
                    value: "\(dashboard.totalMinutes30d)",
                    icon: "clock.fill"
                )

                SummaryStatCard(
                    title: loc.localized("analytics_calories_burned"),
                    value: "\(dashboard.totalCaloriesBurned30d)",
                    icon: "flame.fill"
                )

                SummaryStatCard(
                    title: loc.localized("analytics_workout_streak"),
                    value: "\(dashboard.workoutStreakDays)",
                    icon: "calendar"
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 70))
                .foregroundColor(.gray)

            Text(loc.localized("analytics_no_data"))
                .font(.title3)
                .fontWeight(.semibold)

            Text(loc.localized("analytics_no_data_desc"))
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 40, height: 40)
                .background(Color("PrimaryColor").opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Summary Stat Card

struct SummaryStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(Color("PrimaryColor"))

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    AnalyticsDashboardView()
}
