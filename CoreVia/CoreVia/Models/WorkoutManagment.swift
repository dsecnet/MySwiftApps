//
//  WorkoutManager.swift
//  CoreVia
//
//  Məşq data management - UserDefaults ilə
//

import Foundation
import SwiftUI

class WorkoutManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var workouts: [Workout] = []
    @Published var isLoading: Bool = false
    
    // MARK: - UserDefaults Key
    private let workoutsKey = "saved_workouts"
    
    // MARK: - Singleton
    static let shared = WorkoutManager()
    
    // MARK: - Init
    init() {
        loadWorkouts()
    }
    
    // MARK: - CRUD Operations
    
    /// Məşq əlavə et
    func addWorkout(_ workout: Workout) {
        workouts.insert(workout, at: 0) // Əvvələ əlavə et
        saveWorkouts()
    }
    
    /// Məşqı yenilə
    func updateWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveWorkouts()
        }
    }
    
    /// Məşqı sil
    func deleteWorkout(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts()
    }
    
    /// Məşqı tamamla/tamamlama
    func toggleCompletion(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index].isCompleted.toggle()
            saveWorkouts()
        }
    }
    
    // MARK: - Filters (Filterlər)
    
    /// Bugünkü məşqlər
    var todayWorkouts: [Workout] {
        workouts.filter { $0.isToday }
    }
    
    /// Bu həftəki məşqlər
    var weekWorkouts: [Workout] {
        workouts.filter { $0.isThisWeek }
    }
    
    /// Tamamlanmış məşqlər
    var completedWorkouts: [Workout] {
        workouts.filter { $0.isCompleted }
    }
    
    /// Gözləyən məşqlər
    var pendingWorkouts: [Workout] {
        workouts.filter { !$0.isCompleted }
    }
    
    // MARK: - Statistics (Statistika)
    
    /// Bugünkü ümumi dəqiqə
    var todayTotalMinutes: Int {
        todayWorkouts.reduce(0) { $0 + $1.duration }
    }
    
    /// Bugünkü kalori
    var todayTotalCalories: Int {
        todayWorkouts.compactMap { $0.caloriesBurned }.reduce(0, +)
    }
    
    /// Bu həftəki məşq sayı
    var weekWorkoutCount: Int {
        weekWorkouts.count
    }
    
    /// Bugünkü tamamlanma faizi
    var todayProgress: Double {
        let today = todayWorkouts
        guard !today.isEmpty else { return 0 }
        let completed = today.filter { $0.isCompleted }.count
        return Double(completed) / Double(today.count)
    }
    
    // MARK: - Persistence (Saxlama)
    
    /// Məşqları saxla
    private func saveWorkouts() {
        do {
            let encoded = try JSONEncoder().encode(workouts)
            UserDefaults.standard.set(encoded, forKey: workoutsKey)
            print("✅ Məşqlər saxlanıldı: \(workouts.count) ədəd")
        } catch {
            print("❌ Məşqları saxlaya bilmədi: \(error)")
        }
    }
    
    /// Məşqları yüklə
    private func loadWorkouts() {
        guard let data = UserDefaults.standard.data(forKey: workoutsKey) else {
            print("ℹ️ Heç bir saxlanılmış məşq yoxdur")
            // Demo data yüklə
            workouts = Workout.mockWorkouts
            return
        }
        
        do {
            workouts = try JSONDecoder().decode([Workout].self, from: data)
            print("✅ Məşqlər yükləndi: \(workouts.count) ədəd")
        } catch {
            print("❌ Məşqları yükləyə bilmədi: \(error)")
            workouts = []
        }
    }
    
    /// Bütün məşqları sil (Reset)
    func clearAllWorkouts() {
        workouts = []
        UserDefaults.standard.removeObject(forKey: workoutsKey)
        print("🗑️ Bütün məşqlər silindi")
    }
}
