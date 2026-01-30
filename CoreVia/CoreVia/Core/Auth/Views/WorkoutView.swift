
import SwiftUI

struct WorkoutView: View {
    
    @StateObject private var manager = WorkoutManager.shared
    @State private var showAddWorkout: Bool = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Məşq Tracking")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color(UIColor.label))
                        
                        Text("Bugünkü məşqlər və statistikalar")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: - Daily Goal Progress
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Bugünkü Hədəf")
                                .foregroundColor(Color(UIColor.label))
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(Int(manager.todayProgress * 100))%")
                                .foregroundColor(.red)
                                .font(.headline)
                        }
                        
                        ProgressView(value: manager.todayProgress)
                            .tint(.red)
                        
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("\(manager.todayTotalCalories) kcal")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            .font(.caption)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                Text("\(manager.todayTotalMinutes) dəq")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                    
                    // MARK: - Today's Workouts
                    if !manager.todayWorkouts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bugünkü Məşqlər")
                                .foregroundColor(Color(UIColor.label))
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
                            Text("Gələcək Məşqlər")
                                .foregroundColor(Color(UIColor.label))
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
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                            
                            Text("Hələ məşq yoxdur")
                                .font(.headline)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            
                            Text("İlk məşqınızı əlavə edin")
                                .font(.caption)
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                    
                    // MARK: - Add Workout Button
                    Button {
                        showAddWorkout = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Yeni Məşq Əlavə et")
                                .bold()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: .red.opacity(0.3), radius: 8)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAddWorkout) {
            AddWorkoutView()
        }
    }
}

// MARK: - Workout Card Component
struct WorkoutCard: View {
    let workout: Workout
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon & Category Color
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: workout.category.icon)
                    .font(.title3)
                    .foregroundColor(categoryColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .foregroundColor(Color(UIColor.label))
                    .bold()
                
                HStack(spacing: 12) {
                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text("\(workout.duration) dəq")
                    }
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .font(.caption)
                    
                    // Calories
                    if let calories = workout.caloriesBurned {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                            Text("\(calories) kcal")
                        }
                        .foregroundColor(.orange)
                        .font(.caption)
                    }
                }
                
                // Date (if not today)
                if !workout.isToday {
                    Text(workout.relativeDate)
                        .font(.caption2)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            
            Spacer()
            
            // Completion Button
            Button(action: onToggle) {
                Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(workout.isCompleted ? .green : Color(UIColor.tertiaryLabel))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(workout.isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    private var categoryColor: Color {
        switch workout.category {
        case .strength: return .red
        case .cardio: return .orange
        case .flexibility: return .purple
        case .endurance: return .blue
        }
    }
}

#Preview {
    WorkoutView()
}
