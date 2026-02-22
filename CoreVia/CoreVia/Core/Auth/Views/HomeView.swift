
import SwiftUI

struct HomeView: View {
    
    @StateObject private var workoutManager = WorkoutManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showAddWorkout: Bool = false
    @State private var showAddFood: Bool = false

    // FIX E: NEW - Overall statistics sheet
    @State private var showOverallStatistics: Bool = false

    var body: some View {
        ZStack {
            // FIX 10: Remove ignoresSafeArea to prevent overlap
            Color(UIColor.systemBackground)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(loc.localized("home_hello")) 👋")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(UIColor.label))

                        Text(loc.localized("home_focus"))
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    
                    // MARK: - Stats (Real Data)
                    HStack(spacing: 12) {
                        StatCard(
                            title: loc.localized("home_workout"),
                            value: "\(workoutManager.todayTotalMinutes) \(loc.localized("common_min"))",
                            icon: "flame.fill",
                            color: AppTheme.Colors.accent
                        )
                        
                        StatCard(
                            title: loc.localized("home_calories"),
                            value: "\(workoutManager.todayTotalCalories)",
                            icon: "bolt.fill",
                            color: AppTheme.Colors.accent
                        )
                    }
                    
                    // MARK: - Daily Goal (Real Progress)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(loc.localized("home_daily_goal"))
                                .foregroundColor(Color(UIColor.label))
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Spacer()

                            Text("\(Int(workoutManager.todayProgress * 100))%")
                                .foregroundColor(AppTheme.Colors.accent)
                                .font(.subheadline)
                                .bold()
                        }

                        ProgressView(value: workoutManager.todayProgress)
                            .tint(AppTheme.Colors.accent)

                        Text("\(workoutManager.todayWorkouts.filter { $0.isCompleted }.count)/\(workoutManager.todayWorkouts.count) \(loc.localized("home_completed"))")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .font(.caption2)
                    }
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // MARK: - Today's Workouts Preview
                    if !workoutManager.todayWorkouts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(loc.localized("home_today_workouts"))
                                    .foregroundColor(Color(UIColor.label))
                                    .font(.headline)
                                
                                Spacer()
                                
                                NavigationLink {
                                    WorkoutView()
                                } label: {
                                    Text(loc.localized("home_see_all"))
                                        .font(.caption)
                                        .foregroundColor(AppTheme.Colors.accent)
                                }
                            }
                            
                            ForEach(workoutManager.todayWorkouts.prefix(2)) { workout in
                                CompactWorkoutCard(workout: workout) {
                                    workoutManager.toggleCompletion(workout)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Quick Actions
                    Text(loc.localized("home_quick_actions"))
                        .foregroundColor(Color(UIColor.label))
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        CompactQuickAction(
                            title: loc.localized("home_add_workout"),
                            icon: "plus.circle.fill"
                        ) {
                            showAddWorkout = true
                        }

                        CompactQuickAction(
                            title: loc.localized("home_add_food"),
                            icon: "fork.knife"
                        ) {
                            showAddFood = true
                        }

                        NavigationLink(destination: SocialFeedView()) {
                            CompactQuickActionLabel(
                                title: loc.localized("social_title"),
                                icon: "person.3.fill"
                            )
                        }

                        NavigationLink(destination: MarketplaceView()) {
                            CompactQuickActionLabel(
                                title: loc.localized("marketplace_title"),
                                icon: "cart.fill"
                            )
                        }

                        NavigationLink(destination: LiveSessionListView()) {
                            CompactQuickActionLabel(
                                title: loc.localized("live_sessions_title"),
                                icon: "video.fill"
                            )
                        }

                        CompactQuickAction(
                            title: "Statistika",
                            icon: "chart.bar.fill"
                        ) {
                            showOverallStatistics = true
                        }
                    }
                    
                    // MARK: - AI Tövsiyə Kartı
                    aiRecommendationCard

                    // MARK: - Weekly Stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("home_this_week"))
                            .foregroundColor(Color(UIColor.label))
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        HStack(spacing: 12) {
                            WeekStatItem(
                                icon: "figure.strengthtraining.traditional",
                                value: "\(workoutManager.weekWorkoutCount)",
                                label: loc.localized("home_workout")
                            )

                            WeekStatItem(
                                icon: "checkmark.circle.fill",
                                value: "\(workoutManager.completedWorkouts.count)",
                                label: loc.localized("home_completed")
                            )

                            WeekStatItem(
                                icon: "clock.fill",
                                value: "\(workoutManager.weekWorkouts.reduce(0) { $0 + $1.duration })",
                                label: loc.localized("home_minutes")
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
        }
        // FIX 10: Add safe area inset for proper spacing
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
        .sheet(isPresented: $showAddWorkout) {
            AddWorkoutView()
        }
        .sheet(isPresented: $showAddFood) {
            AddFoodView()
        }
        // FIX E: NEW - Overall Statistics sheet
        .sheet(isPresented: $showOverallStatistics) {
            OverallStatisticsView()
        }
    }

    // MARK: - AI Recommendation Card
    private var aiRecommendationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18))
                    .foregroundColor(.purple)

                Text(loc.localized("home_ai_recommendation"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(UIColor.label))

                Spacer()

                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
            }

            // Dynamic recommendation based on data
            let recommendation = generateRecommendation()

            Text(recommendation.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(UIColor.label))

            Text(recommendation.description)
                .font(.system(size: 13))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .lineLimit(3)

            HStack(spacing: 8) {
                Image(systemName: recommendation.icon)
                    .font(.system(size: 12))
                    .foregroundColor(recommendation.color)

                Text(recommendation.category)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(recommendation.color)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(recommendation.color.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.05), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }

    private struct AIRecommendation {
        let title: String
        let description: String
        let icon: String
        let color: Color
        let category: String
    }

    private func generateRecommendation() -> AIRecommendation {
        let todayWorkouts = workoutManager.todayWorkouts.count
        let _ = workoutManager.todayWorkouts.filter { $0.isCompleted }.count
        let progress = workoutManager.todayProgress
        let foodCalories = FoodManager.shared.todayTotalCalories

        if todayWorkouts == 0 {
            return AIRecommendation(
                title: loc.localized("ai_rec_no_workout_title"),
                description: loc.localized("ai_rec_no_workout_desc"),
                icon: "figure.walk",
                color: AppTheme.Colors.accent,
                category: loc.localized("task_type_workout")
            )
        } else if progress >= 1.0 {
            return AIRecommendation(
                title: loc.localized("ai_rec_goal_done_title"),
                description: loc.localized("ai_rec_goal_done_desc"),
                icon: "trophy.fill",
                color: AppTheme.Colors.success,
                category: loc.localized("ai_rec_motivation")
            )
        } else if foodCalories < 500 {
            return AIRecommendation(
                title: loc.localized("ai_rec_eat_more_title"),
                description: loc.localized("ai_rec_eat_more_desc"),
                icon: "fork.knife",
                color: .orange,
                category: loc.localized("task_type_nutrition")
            )
        } else {
            return AIRecommendation(
                title: loc.localized("ai_rec_keep_going_title"),
                description: loc.localized("ai_rec_keep_going_desc"),
                icon: "flame.fill",
                color: AppTheme.Colors.accent,
                category: loc.localized("ai_rec_motivation")
            )
        }
    }
}

// MARK: - Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
                Text(title)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .font(.system(size: 10))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Compact Quick Action (Button)
struct CompactQuickAction: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CompactQuickActionLabel(title: title, icon: icon)
        }
    }
}

// MARK: - Compact Quick Action Label (for NavigationLink)
struct CompactQuickActionLabel: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(AppTheme.Colors.accent.opacity(0.85))
        .cornerRadius(10)
    }
}

// Legacy - keep for backward compatibility
struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        CompactQuickAction(title: title, icon: icon, action: action)
    }
}

struct QuickActionButtonStyle: View {
    let title: String
    let icon: String

    var body: some View {
        CompactQuickActionLabel(title: title, icon: icon)
    }
}

struct CompactWorkoutCard: View {
    let workout: Workout
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workout.category.icon)
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.title)
                    .foregroundColor(Color(UIColor.label))
                    .font(.subheadline)
                    .bold()
                
                Text("\(workout.duration) \(LocalizationManager.shared.localized("common_min"))")
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .font(.caption)
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(workout.isCompleted ? AppTheme.Colors.success : Color(UIColor.tertiaryLabel))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct WeekStatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.accent)
                .font(.system(size: 16))

            Text(value)
                .foregroundColor(Color(UIColor.label))
                .font(.system(size: 16, weight: .bold))

            Text(label)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .font(.system(size: 10))
        }
        .frame(maxWidth: .infinity)
    }
}

// #Preview { // iOS 17+ only
//     HomeView()
// }
