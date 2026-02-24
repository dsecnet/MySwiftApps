
import SwiftUI

struct HomeView: View {
    
    @StateObject private var workoutManager = WorkoutManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showAddWorkout: Bool = false
    @State private var showAddFood: Bool = false

    // FIX E: NEW - Overall statistics sheet
    @State private var showOverallStatistics: Bool = false

    // AI ML Recommendation — backend-den gelen tovsiye
    @State private var backendRecommendation: AIRecommendation?
    @State private var isLoadingAIRec = false

    // Daily Survey
    @State private var showDailySurvey = false
    @State private var isSurveyCompleted = false

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
                    
                    // MARK: - Daily Survey Prompt
                    if !isSurveyCompleted {
                        Button(action: { showDailySurvey = true }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: "list.clipboard.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.blue)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(loc.localized("daily_survey_prompt"))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                    Text(loc.localized("daily_survey_prompt_desc"))
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.tertiaryText)
                            }
                            .padding(12)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.05), Color.blue.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(AppTheme.CornerRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
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
                            title: loc.localized("home_statistics"),
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
        // Daily Survey sheet
        .sheet(isPresented: $showDailySurvey) {
            DailySurveyView()
                .onDisappear {
                    checkSurveyStatus()
                }
        }
        .onAppear {
            checkSurveyStatus()
        }
    }

    // MARK: - Survey Status Check
    private func checkSurveyStatus() {
        Task {
            do {
                let status = try await DailySurveyService.shared.getTodayStatus()
                await MainActor.run {
                    isSurveyCompleted = status.completed
                }
            } catch {
                // Xeta olsa prompt gosterilsin
                print("Survey status xetasi: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - AI Recommendation Card (Backend ML + lokal fallback)
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

                if isLoadingAIRec {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                }
            }

            // Backend ML tovsiyesi varsa onu goster, yoxsa lokal fallback
            let recommendation = currentRecommendation()

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
        .onAppear {
            loadBackendRecommendation()
        }
    }

    private struct HomeAIRec {
        let title: String
        let description: String
        let icon: String
        let color: Color
        let category: String
    }

    /// Backend ML tovsiyesini yukle
    private func loadBackendRecommendation() {
        guard backendRecommendation == nil, !isLoadingAIRec else { return }
        isLoadingAIRec = true
        Task {
            do {
                let response = try await AIRecommendationService.shared.getRecommendations()
                await MainActor.run {
                    self.backendRecommendation = response.recommendations.first
                    self.isLoadingAIRec = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingAIRec = false
                    // Backend cavab vermese lokal fallback isleyecek
                    print("AI Rec backend xetasi: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Backend ML varsa onu, yoxsa lokal fallback
    private func currentRecommendation() -> HomeAIRec {
        if let rec = backendRecommendation {
            return HomeAIRec(
                title: rec.title,
                description: rec.description,
                icon: rec.iconName ?? typeToIcon(rec.type),
                color: typeToColor(rec.type),
                category: typeToCategory(rec.type)
            )
        }
        return generateLocalFallback()
    }

    private func typeToIcon(_ type: String) -> String {
        switch type {
        case "workout": return "figure.run"
        case "meal": return "fork.knife"
        case "hydration": return "drop.fill"
        case "sleep": return "moon.fill"
        case "rest": return "leaf.fill"
        default: return "sparkles"
        }
    }

    private func typeToColor(_ type: String) -> Color {
        switch type {
        case "workout": return AppTheme.Colors.accent
        case "meal": return .orange
        case "hydration": return .blue
        case "sleep": return .purple
        case "rest": return AppTheme.Colors.success
        default: return AppTheme.Colors.accent
        }
    }

    private func typeToCategory(_ type: String) -> String {
        switch type {
        case "workout": return loc.localized("task_type_workout")
        case "meal": return loc.localized("task_type_nutrition")
        case "hydration": return loc.localized("ai_rec_hydration")
        case "sleep": return loc.localized("ai_rec_sleep")
        case "rest": return loc.localized("ai_rec_rest")
        default: return type.capitalized
        }
    }

    /// Lokal fallback — backend cavab vermese (movcut meantiq qorunur)
    private func generateLocalFallback() -> HomeAIRec {
        let todayWorkouts = workoutManager.todayWorkouts.count
        let _ = workoutManager.todayWorkouts.filter { $0.isCompleted }.count
        let progress = workoutManager.todayProgress
        let foodCalories = FoodManager.shared.todayTotalCalories

        if todayWorkouts == 0 {
            return HomeAIRec(
                title: loc.localized("ai_rec_no_workout_title"),
                description: loc.localized("ai_rec_no_workout_desc"),
                icon: "figure.walk",
                color: AppTheme.Colors.accent,
                category: loc.localized("task_type_workout")
            )
        } else if progress >= 1.0 {
            return HomeAIRec(
                title: loc.localized("ai_rec_goal_done_title"),
                description: loc.localized("ai_rec_goal_done_desc"),
                icon: "trophy.fill",
                color: AppTheme.Colors.success,
                category: loc.localized("ai_rec_motivation")
            )
        } else if foodCalories < 500 {
            return HomeAIRec(
                title: loc.localized("ai_rec_eat_more_title"),
                description: loc.localized("ai_rec_eat_more_desc"),
                icon: "fork.knife",
                color: .orange,
                category: loc.localized("task_type_nutrition")
            )
        } else {
            return HomeAIRec(
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
