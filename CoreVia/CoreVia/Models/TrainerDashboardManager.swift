//
//  TrainerDashboardManager.swift
//  CoreVia
//
//  Trainer Dashboard — real API data ilə statistikalar
//

import Foundation
import SwiftUI

// MARK: - Models

struct TrainerDashboardStats: Codable {
    let totalSubscribers: Int
    let activeStudents: Int
    let monthlyEarnings: Double
    let currency: String
    let totalTrainingPlans: Int
    let totalMealPlans: Int
    let students: [DashboardStudentSummary]
    let statsSummary: DashboardStatsSummary

    enum CodingKeys: String, CodingKey {
        case totalSubscribers = "total_subscribers"
        case activeStudents = "active_students"
        case monthlyEarnings = "monthly_earnings"
        case currency
        case totalTrainingPlans = "total_training_plans"
        case totalMealPlans = "total_meal_plans"
        case students
        case statsSummary = "stats_summary"
    }
}

struct DashboardStudentSummary: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let weight: Double?
    let height: Double?
    let goal: String?
    let age: Int?
    let profileImageUrl: String?
    let trainingPlansCount: Int
    let mealPlansCount: Int
    let totalWorkouts: Int
    let thisWeekWorkouts: Int
    let totalCaloriesLogged: Int

    enum CodingKeys: String, CodingKey {
        case id, name, email, weight, height, goal, age
        case profileImageUrl = "profile_image_url"
        case trainingPlansCount = "training_plans_count"
        case mealPlansCount = "meal_plans_count"
        case totalWorkouts = "total_workouts"
        case thisWeekWorkouts = "this_week_workouts"
        case totalCaloriesLogged = "total_calories_logged"
    }

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var avatarColor: Color {
        let index = abs(name.hashValue) % AppTheme.Colors.avatarPalette.count
        return AppTheme.Colors.avatarPalette[index]
    }
}

struct DashboardStatsSummary: Codable {
    let avgStudentWorkoutsPerWeek: Double
    let totalWorkoutsAllStudents: Int
    let avgStudentWeight: Double

    enum CodingKeys: String, CodingKey {
        case avgStudentWorkoutsPerWeek = "avg_student_workouts_per_week"
        case totalWorkoutsAllStudents = "total_workouts_all_students"
        case avgStudentWeight = "avg_student_weight"
    }
}

// MARK: - Manager

class TrainerDashboardManager: ObservableObject {
    static let shared = TrainerDashboardManager()

    @Published var stats: TrainerDashboardStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchStats() async {
        await MainActor.run { isLoading = true; errorMessage = nil }

        do {
            let data: TrainerDashboardStats = try await APIService.shared.request(
                endpoint: "/api/v1/trainer/stats",
                method: "GET"
            )
            await MainActor.run {
                self.stats = data
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            }
        }
    }
}
