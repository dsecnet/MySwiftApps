
import SwiftUI

struct WorkoutView: View {

    @StateObject private var manager = WorkoutManager.shared
    @State private var showAddWorkout: Bool = false
    @State private var showPremiumPrompt: Bool = false
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var settingsManager = SettingsManager.shared

    @State private var showLiveTracking: Bool = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {

                        // MARK: - Header (kompakt)
                        Text(loc.localized("workout_tracking"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // MARK: - Weekly Summary (1 sira, 4 mini stat)
                        weeklySummaryCompact

                        // MARK: - Daily Goal (kompakt)
                        dailyGoalCompact

                        // MARK: - Exercise Library Button
                        exerciseLibraryButton

                        // MARK: - Today's Workouts (kompakt kartlar)
                        if !manager.todayWorkouts.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(loc.localized("workout_today"))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .font(.system(size: 15, weight: .semibold))

                                ForEach(manager.todayWorkouts) { workout in
                                    WorkoutMiniCard(workout: workout) {
                                        manager.toggleCompletion(workout)
                                    }
                                }
                            }
                        }

                        // MARK: - Empty State (kompakt)
                        if manager.workouts.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.Colors.tertiaryText)

                                Text(loc.localized("workout_no_workouts"))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                Text(loc.localized("workout_add_first"))
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.tertiaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                }

                // MARK: - Fixed Bottom Bar
                gpsTrackingBar
            }
        }
        .sheet(isPresented: $showAddWorkout) {
            AddWorkoutView()
        }
        .sheet(isPresented: $showPremiumPrompt) {
            PremiumView()
        }
        .sheet(isPresented: $showLiveTracking) {
            NavigationStack {
                LiveTrackingView()
            }
        }
    }

    // MARK: - Weekly Summary (Kompakt — 1 sira, 4 stat)
    private var weeklySummaryCompact: some View {
        HStack(spacing: 6) {
            MiniStatItem(value: "\(manager.weekWorkoutCount)", label: "Məşq", icon: "figure.strengthtraining.traditional", color: AppTheme.Colors.accent)
            MiniStatItem(value: "\(manager.completedWorkouts.count)", label: "Bitdi", icon: "checkmark.circle.fill", color: .green)
            MiniStatItem(value: "\(calculateWeeklyMinutes())", label: "Dəq", icon: "clock.fill", color: AppTheme.Colors.accent)
            MiniStatItem(value: "\(calculateWeeklyCalories())", label: "Kcal", icon: "flame.fill", color: .orange)
        }
        .padding(10)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }

    // MARK: - Daily Goal (Kompakt)
    private var dailyGoalCompact: some View {
        VStack(spacing: 6) {
            HStack {
                Text(loc.localized("workout_today_goal"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.Colors.accent)
                        Text("\(manager.todayTotalCalories)")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.Colors.accent)
                        Text("\(manager.todayTotalMinutes)\(loc.localized("common_min"))")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    Text("\(Int(manager.todayProgress * 100))%")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }

            ProgressView(value: manager.todayProgress)
                .tint(AppTheme.Colors.accent)
        }
        .padding(10)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }

    // MARK: - Exercise Library Button
    private var exerciseLibraryButton: some View {
        NavigationLink(destination: ExerciseLibraryView()) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.accent.opacity(0.15))
                        .frame(width: 38, height: 38)
                    Image(systemName: "book.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Məşq Kitabxanası")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text("870+ məşq təlimatı ilə")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.Colors.tertiaryText)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(10)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }

    // MARK: - Fixed Bottom Bar (GPS + Add Workout)
    private var gpsTrackingBar: some View {
        VStack(spacing: 6) {
            if settingsManager.isPremium {
                Button {
                    showLiveTracking = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 13))
                        Text("GPS ilə Qaçış/Gəzinti")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(LinearGradient(colors: [Color.green, Color.green.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                }
            } else {
                Button {
                    showPremiumPrompt = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                        Text("GPS Tracking (Premium)")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(LinearGradient(colors: [Color.gray, Color.gray.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                }
            }

            Button {
                showAddWorkout = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 13))
                    Text(loc.localized("workout_new"))
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(LinearGradient(colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 80)
        .background(
            AppTheme.Colors.background
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -4)
        )
    }

    // MARK: - Weekly Stat Helpers
    private func calculateWeeklyMinutes() -> Int {
        let now = Date()
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        return manager.workouts
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + $1.duration }
    }

    private func calculateWeeklyCalories() -> Int {
        let now = Date()
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        return manager.workouts
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + ($1.caloriesBurned ?? 0) }
    }
}

// MARK: - Mini Stat Item (Hefteki xulase ucun)
private struct MiniStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Compact Workout Card
struct WorkoutMiniCard: View {
    let workout: Workout
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: workout.category.icon)
                    .font(.system(size: 14))
                    .foregroundColor(categoryColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                        Text("\(workout.duration) \(LocalizationManager.shared.localized("common_min"))")
                    }
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .font(.system(size: 11))

                    if let cal = workout.caloriesBurned {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 9))
                            Text("\(cal) kcal")
                        }
                        .foregroundColor(AppTheme.Colors.accent)
                        .font(.system(size: 11))
                    }
                }
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(workout.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.tertiaryText)
            }
        }
        .padding(10)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(workout.isCompleted ? AppTheme.Colors.success.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    private var categoryColor: Color {
        switch workout.category {
        case .strength: return AppTheme.Colors.accent
        case .cardio: return AppTheme.Colors.accentDark
        case .flexibility: return AppTheme.Colors.accent
        case .endurance: return AppTheme.Colors.accentDark
        }
    }
}

// #Preview { // iOS 17+ only
//     WorkoutView()
// }
