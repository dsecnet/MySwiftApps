
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
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(loc.localized("home_hello")) 👋")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color(UIColor.label))
                        
                        Text(loc.localized("home_focus"))
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
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(loc.localized("home_daily_goal"))
                                .foregroundColor(Color(UIColor.label))
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(Int(workoutManager.todayProgress * 100))%")
                                .foregroundColor(AppTheme.Colors.accent)
                                .bold()
                        }
                        
                        ProgressView(value: workoutManager.todayProgress)
                            .tint(AppTheme.Colors.accent)
                        
                        HStack {
                            Text("\(workoutManager.todayWorkouts.filter { $0.isCompleted }.count)/\(workoutManager.todayWorkouts.count) \(loc.localized("home_completed"))")
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .font(.caption)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                    
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
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickActionButton(
                            title: loc.localized("home_add_workout"),
                            icon: "plus.circle.fill"
                        ) {
                            showAddWorkout = true
                        }

                        QuickActionButton(
                            title: loc.localized("home_add_food"),
                            icon: "fork.knife"
                        ) {
                            showAddFood = true
                        }

                        // NEW FEATURES
                        NavigationLink(destination: SocialFeedView()) {
                            QuickActionButtonStyle(
                                title: loc.localized("social_title"),
                                icon: "person.3.fill"
                            )
                        }

                        NavigationLink(destination: MarketplaceView()) {
                            QuickActionButtonStyle(
                                title: loc.localized("marketplace_title"),
                                icon: "cart.fill"
                            )
                        }

                        NavigationLink(destination: LiveSessionListView()) {
                            QuickActionButtonStyle(
                                title: loc.localized("live_sessions_title"),
                                icon: "video.fill"
                            )
                        }

                        // FIX E: NEW - Overall Statistics Button
                        QuickActionButton(
                            title: "Ümumi Statistika",
                            icon: "chart.bar.doc.horizontal.fill"
                        ) {
                            showOverallStatistics = true
                        }
                    }
                    
                    // MARK: - Weekly Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.localized("home_this_week"))
                            .foregroundColor(Color(UIColor.label))
                            .font(.headline)
                        
                        HStack(spacing: 16) {
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
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                }
                .padding()
                // FIX 10: Add bottom padding for custom tab bar
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
}

// MARK: - Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(Color(UIColor.label))
            
            Text(title)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.accent.opacity(0.85))
            .cornerRadius(12)
        }
    }
}

struct QuickActionButtonStyle: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.accent.opacity(0.85))
        .cornerRadius(12)
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
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.accent)
                .font(.title3)
            
            Text(value)
                .foregroundColor(Color(UIColor.label))
                .font(.headline)
            
            Text(label)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
    }
}

// #Preview { // iOS 17+ only
//     HomeView()
// }
