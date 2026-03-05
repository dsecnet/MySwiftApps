//
//  ExerciseLibraryViewModel.swift
//  CoreVia
//
//  Mesq kitabxanasi ucun state management
//

import Foundation
import os.log

@MainActor
class ExerciseLibraryViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var exercises: [Exercise] = []
    @Published var selectedMuscle: MuscleGroup = .chest {
        didSet {
            if oldValue != selectedMuscle {
                Task { await loadExercises() }
            }
        }
    }
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var errorMessage: String?

    // MARK: - Filtered Exercises
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(searchText) ||
            exercise.primaryMusclesText.localizedCaseInsensitiveContains(searchText) ||
            exercise.equipmentText.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Init
    init() {
        Task { await loadExercises() }
    }

    // MARK: - Load Exercises
    func loadExercises() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await ExerciseDBService.shared.fetchExercises(muscle: selectedMuscle)
            exercises = result
        } catch {
            AppLogger.network.error("Exercise yuklenme xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Refresh
    func refresh() async {
        ExerciseDBService.shared.clearCache()
        await loadExercises()
    }
}
