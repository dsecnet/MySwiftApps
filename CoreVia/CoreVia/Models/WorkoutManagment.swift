//
//  WorkoutManager.swift
//  CoreVia
//
//  Məşq data management - Backend API ilə
//

import Foundation
import SwiftUI

// MARK: - Backend request models
private struct WorkoutCreateRequest: Encodable {
    let title: String
    let category: String
    let duration: Int
    let caloriesBurned: Int?
    let notes: String?
    let date: Date?

    enum CodingKeys: String, CodingKey {
        case title, category, duration, notes, date
        case caloriesBurned = "calories_burned"
    }
}

private struct WorkoutUpdateRequest: Encodable {
    var title: String?
    var category: String?
    var duration: Int?
    var caloriesBurned: Int?
    var notes: String?
    var isCompleted: Bool?

    enum CodingKeys: String, CodingKey {
        case title, category, duration, notes
        case caloriesBurned = "calories_burned"
        case isCompleted = "is_completed"
    }
}

class WorkoutManager: ObservableObject {

    // MARK: - Published Properties
    @Published var workouts: [Workout] = []
    @Published var isLoading: Bool = false

    // MARK: - Singleton
    static let shared = WorkoutManager()

    private let api = APIService.shared

    // MARK: - Init
    init() {
        loadWorkouts()
    }

    // MARK: - CRUD Operations

    /// Məşq əlavə et
    func addWorkout(_ workout: Workout) {
        workouts.insert(workout, at: 0)

        Task {
            do {
                let created: Workout = try await api.request(
                    endpoint: "/api/v1/workouts/",
                    method: "POST",
                    body: WorkoutCreateRequest(
                        title: workout.title,
                        category: workout.category.rawValue,
                        duration: workout.duration,
                        caloriesBurned: workout.caloriesBurned,
                        notes: workout.notes,
                        date: workout.date
                    )
                )
                await MainActor.run {
                    if let index = self.workouts.firstIndex(where: { $0.id == workout.id }) {
                        self.workouts[index] = created
                    }
                }
            } catch {
                print("Workout create xətası: \(error)")
            }
        }
    }

    /// Məşqı yenilə
    func updateWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout

            Task {
                do {
                    let _: Workout = try await api.request(
                        endpoint: "/api/v1/workouts/\(workout.id)",
                        method: "PUT",
                        body: WorkoutUpdateRequest(
                            title: workout.title,
                            category: workout.category.rawValue,
                            duration: workout.duration,
                            caloriesBurned: workout.caloriesBurned,
                            notes: workout.notes,
                            isCompleted: workout.isCompleted
                        )
                    )
                } catch {
                    print("Workout update xətası: \(error)")
                }
            }
        }
    }

    /// Məşqı sil
    func deleteWorkout(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }

        Task {
            do {
                try await api.requestVoid(endpoint: "/api/v1/workouts/\(workout.id)")
            } catch {
                print("Workout delete xətası: \(error)")
            }
        }
    }

    /// Məşqı tamamla/tamamlama
    func toggleCompletion(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index].isCompleted.toggle()

            Task {
                do {
                    let _: Workout = try await api.request(
                        endpoint: "/api/v1/workouts/\(workout.id)/toggle",
                        method: "PATCH"
                    )
                } catch {
                    print("Workout toggle xətası: \(error)")
                }
            }
        }
    }

    // MARK: - Filters (Filterlər)

    var todayWorkouts: [Workout] {
        workouts.filter { $0.isToday }
    }

    var weekWorkouts: [Workout] {
        workouts.filter { $0.isThisWeek }
    }

    var completedWorkouts: [Workout] {
        workouts.filter { $0.isCompleted }
    }

    var pendingWorkouts: [Workout] {
        workouts.filter { !$0.isCompleted }
    }

    // MARK: - Statistics (Statistika)

    var todayTotalMinutes: Int {
        todayWorkouts.reduce(0) { $0 + $1.duration }
    }

    var todayTotalCalories: Int {
        todayWorkouts.compactMap { $0.caloriesBurned }.reduce(0, +)
    }

    var weekWorkoutCount: Int {
        weekWorkouts.count
    }

    var todayProgress: Double {
        let today = todayWorkouts
        guard !today.isEmpty else { return 0 }
        let completed = today.filter { $0.isCompleted }.count
        return Double(completed) / Double(today.count)
    }

    // MARK: - Backend Sync

    /// Backend-dən məşqları yüklə
    func loadWorkouts() {
        guard KeychainManager.shared.isLoggedIn else { return }

        isLoading = true
        Task {
            do {
                let fetched: [Workout] = try await api.request(endpoint: "/api/v1/workouts/")
                await MainActor.run {
                    self.workouts = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                print("Workouts yükləmə xətası: \(error)")
            }
        }
    }

    /// Bütün məşqları sil (Reset)
    func clearAllWorkouts() {
        workouts = []
    }
}
