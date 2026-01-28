//
//  HomeView.swift
//  CoreVia
//
//  Ana səhifə - Adaptiv theme ilə
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var showAddWorkout: Bool = false
    @State private var showAddFood: Bool = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Salam 👋")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color(UIColor.label))
                        
                        Text("Bu gün hədəflərinə fokuslan!")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    
                    // MARK: - Stats (Real Data)
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Məşq",
                            value: "\(workoutManager.todayTotalMinutes) dəq",
                            icon: "flame.fill",
                            color: .red
                        )
                        
                        StatCard(
                            title: "Kalori",
                            value: "\(workoutManager.todayTotalCalories)",
                            icon: "bolt.fill",
                            color: .orange
                        )
                    }
                    
                    // MARK: - Daily Goal (Real Progress)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Günlük Hədəf")
                                .foregroundColor(Color(UIColor.label))
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(Int(workoutManager.todayProgress * 100))%")
                                .foregroundColor(.red)
                                .bold()
                        }
                        
                        ProgressView(value: workoutManager.todayProgress)
                            .tint(.red)
                        
                        HStack {
                            Text("\(workoutManager.todayWorkouts.filter { $0.isCompleted }.count)/\(workoutManager.todayWorkouts.count) məşq tamamlandı")
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
                                Text("Bugünkü Məşqlər")
                                    .foregroundColor(Color(UIColor.label))
                                    .font(.headline)
                                
                                Spacer()
                                
                                NavigationLink {
                                    WorkoutView()
                                } label: {
                                    Text("Hamısına bax")
                                        .font(.caption)
                                        .foregroundColor(.red)
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
                    Text("Tez Əməliyyatlar")
                        .foregroundColor(Color(UIColor.label))
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        QuickActionButton(
                            title: "Məşq Əlavə et",
                            icon: "plus.circle.fill"
                        ) {
                            showAddWorkout = true
                        }
                        
                        QuickActionButton(
                            title: "Qida Əlavə et",
                            icon: "fork.knife"
                        ) {
                            showAddFood = true
                        }
                    }
                    
                    // MARK: - Weekly Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bu Həftə")
                            .foregroundColor(Color(UIColor.label))
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            WeekStatItem(
                                icon: "figure.strengthtraining.traditional",
                                value: "\(workoutManager.weekWorkoutCount)",
                                label: "Məşq"
                            )
                            
                            WeekStatItem(
                                icon: "checkmark.circle.fill",
                                value: "\(workoutManager.completedWorkouts.count)",
                                label: "Tamamlandı"
                            )
                            
                            WeekStatItem(
                                icon: "clock.fill",
                                value: "\(workoutManager.weekWorkouts.reduce(0) { $0 + $1.duration })",
                                label: "Dəqiqə"
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAddWorkout) {
            AddWorkoutView()
        }
        .sheet(isPresented: $showAddFood) {
            AddFoodView()
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
            .background(Color.red.opacity(0.85))
            .cornerRadius(12)
        }
    }
}

struct CompactWorkoutCard: View {
    let workout: Workout
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workout.category.icon)
                .foregroundColor(.red)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.title)
                    .foregroundColor(Color(UIColor.label))
                    .font(.subheadline)
                    .bold()
                
                Text("\(workout.duration) dəq")
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .font(.caption)
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(workout.isCompleted ? .green : Color(UIColor.tertiaryLabel))
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
                .foregroundColor(.red)
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

#Preview {
    HomeView()
}
