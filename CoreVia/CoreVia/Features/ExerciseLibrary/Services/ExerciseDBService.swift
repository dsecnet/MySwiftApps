//
//  ExerciseDBService.swift
//  CoreVia
//
//  Free exercise database (GitHub) — pulsuz, limitsiz, 873+ mesq
//

import Foundation
import os.log

@MainActor
class ExerciseDBService {
    static let shared = ExerciseDBService()

    // MARK: - Configuration
    private let dataURL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"

    // MARK: - In-Memory Cache
    private var allExercises: [Exercise]?
    private var muscleCache: [String: [Exercise]] = [:]

    private init() {}

    // MARK: - Load All Exercises (bir defe yukle, cache-le)
    private func loadAllExercises() async throws -> [Exercise] {
        // Cache yoxla
        if let cached = allExercises {
            return cached
        }

        guard let url = URL(string: dataURL) else {
            throw ExerciseDBError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ExerciseDBError.invalidResponse
        }

        let exercises = try JSONDecoder().decode([Exercise].self, from: data)

        // Cache-e yaz
        allExercises = exercises

        AppLogger.network.info("Loaded \(exercises.count) exercises from GitHub")

        return exercises
    }

    // MARK: - Fetch Exercises by Muscle Group
    func fetchExercises(muscle: MuscleGroup) async throws -> [Exercise] {
        let cacheKey = muscle.rawValue

        // Muscle cache yoxla
        if let cached = muscleCache[cacheKey] {
            return cached
        }

        let allExercises = try await loadAllExercises()

        let filtered = allExercises.filter { exercise in
            exercise.primaryMuscles.contains { $0.lowercased() == muscle.rawValue.lowercased() }
        }

        // Cache-e yaz
        muscleCache[cacheKey] = filtered

        return filtered
    }

    // MARK: - Search Exercises by Name
    func searchExercises(name: String) async throws -> [Exercise] {
        let allExercises = try await loadAllExercises()

        return allExercises.filter {
            $0.name.localizedCaseInsensitiveContains(name)
        }
    }

    // MARK: - Clear Cache
    func clearCache() {
        allExercises = nil
        muscleCache.removeAll()
    }
}

// MARK: - Errors
enum ExerciseDBError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Yanlış URL"
        case .invalidResponse:
            return "Server cavab vermədi"
        case .apiError(let code):
            return "API xətası: \(code)"
        }
    }
}
