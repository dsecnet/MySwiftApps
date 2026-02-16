
import SwiftUI

struct WorkoutView: View {

    @StateObject private var manager = WorkoutManager.shared
    @State private var showAddWorkout: Bool = false
    @State private var showPremiumPrompt: Bool = false
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc.localized("workout_tracking"))
                            .font(.title)
                            .bold()
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(loc.localized("workout_subtitle"))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // FIX 11: NEW - Weekly Summary Statistics
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Həftəlik Xülasə")
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.primaryText)

                        HStack(spacing: 12) {
                            // Total workouts
                            VStack(spacing: 4) {
                                Text("\(manager.weekWorkoutCount)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text("Məşqlər")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(12)

                            // Completed workouts
                            VStack(spacing: 4) {
                                Text("\(manager.completedWorkouts.count)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.green)
                                Text("Tamamlandı")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(12)
                        }

                        HStack(spacing: 12) {
                            // Total minutes
                            VStack(spacing: 4) {
                                Text("\(calculateWeeklyMinutes())")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text("Dəqiqə")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(12)

                            // Total calories
                            VStack(spacing: 4) {
                                Text("\(calculateWeeklyCalories())")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.orange)
                                Text("Kalori")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(16)

                    // MARK: - Daily Goal Progress
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(loc.localized("workout_today_goal"))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .font(.headline)

                            Spacer()

                            Text("\(Int(manager.todayProgress * 100))%")
                                .foregroundColor(AppTheme.Colors.accent)
                                .font(.headline)
                        }

                        ProgressView(value: manager.todayProgress)
                            .tint(AppTheme.Colors.accent)

                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text("\(manager.todayTotalCalories) kcal")
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .font(.caption)

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text("\(manager.todayTotalMinutes) \(loc.localized("common_min"))")
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .font(.caption)
                        }
                    }
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(14)
                    
                    // MARK: - Today's Workouts
                    if !manager.todayWorkouts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(loc.localized("workout_today"))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .font(.headline)
                            
                            ForEach(manager.todayWorkouts) { workout in
                                WorkoutCard(workout: workout) {
                                    manager.toggleCompletion(workout)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Upcoming/Past Workouts
                    if !manager.pendingWorkouts.filter({ !$0.isToday }).isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(loc.localized("workout_future"))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .font(.headline)
                            
                            ForEach(manager.pendingWorkouts.filter { !$0.isToday }.prefix(3)) { workout in
                                WorkoutCard(workout: workout) {
                                    manager.toggleCompletion(workout)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Empty State
                    if manager.workouts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.Colors.tertiaryText)

                            Text(loc.localized("workout_no_workouts"))
                                .font(.headline)
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            Text(loc.localized("workout_add_first"))
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }

                    // MARK: - GPS Tracking Button (Premium)
                    if settingsManager.isPremium {
                        NavigationLink {
                            LiveTrackingView()
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("GPS ilə Qaçış/Gəzinti")
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.green.opacity(0.3), radius: 8)
                        }
                        .padding(.top, 10)
                    } else {
                        Button {
                            showPremiumPrompt = true
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("GPS Tracking (Premium)")
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [Color.gray, Color.gray.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                        }
                        .padding(.top, 10)
                    }

                    // MARK: - Add Workout Button
                    Button {
                        showAddWorkout = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(loc.localized("workout_new"))
                                .bold()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 8)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showAddWorkout) {
            AddWorkoutView()
        }
        .sheet(isPresented: $showPremiumPrompt) {
            PremiumView()
        }
    }

    // FIX 11: NEW - Helper functions for weekly statistics
    private func calculateWeeklyMinutes() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return manager.workouts
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + $1.duration }
    }

    private func calculateWeeklyCalories() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        return manager.workouts
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + ($1.caloriesBurned ?? 0) } 
    }
}

// MARK: - Workout Card Component
struct WorkoutCard: View {
    let workout: Workout
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: workout.category.icon)
                    .font(.title3)
                    .foregroundColor(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .bold()

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text("\(workout.duration) \(LocalizationManager.shared.localized("common_min"))")
                    }
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .font(.caption)

                    if let calories = workout.caloriesBurned {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                            Text("\(calories) kcal")
                        }
                        .foregroundColor(AppTheme.Colors.accent)
                        .font(.caption)
                    }
                }

                if !workout.isToday {
                    Text(workout.relativeDate)
                        .font(.caption2)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(workout.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.tertiaryText)
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
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
