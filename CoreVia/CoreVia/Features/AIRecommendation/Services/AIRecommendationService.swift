//
//  AIRecommendationService.swift
//  CoreVia
//
//  Backend ML tovsiye sistemi servisi
//  Backend oz Python ML-i ile isleyir (XGBoost, scikit-learn, Prophet)
//  Xarici AI API yoxdur — tam lokal backend ML
//

import Foundation

// MARK: - Response Models

struct AIRecommendationResponse: Codable {
    let recommendations: [AIRecommendation]
    let weeklyScore: Int?
    let summary: String?
    let weeklyComparison: WeeklyComparison?
    let timeBasedTip: AIRecommendation?
    let warnings: [String]?
    let nutritionTips: [String]?
    let workoutTips: [String]?

    // Legacy uygunluq
    let generatedAt: Date?
    let userProfile: RecommendationUserProfile?

    enum CodingKeys: String, CodingKey {
        case recommendations
        case weeklyScore = "weekly_score"
        case summary
        case weeklyComparison = "weekly_comparison"
        case timeBasedTip = "time_based_tip"
        case warnings
        case nutritionTips = "nutrition_tips"
        case workoutTips = "workout_tips"
        case generatedAt = "generated_at"
        case userProfile = "user_profile"
    }
}

struct WeeklyComparison: Codable {
    let workoutChange: Int
    let calorieChange: Int
    let proteinAvg: Double

    enum CodingKeys: String, CodingKey {
        case workoutChange = "workout_change"
        case calorieChange = "calorie_change"
        case proteinAvg = "protein_avg"
    }
}

struct AIRecommendation: Identifiable, Codable {
    var id: String
    let type: String  // workout, meal, hydration, sleep, rest
    let title: String
    let description: String
    let priority: Int  // 1=high, 2=medium, 3=low
    let iconName: String?
    let actionUrl: String?
    let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id, type, title, description, priority, metadata
        case iconName = "icon_name"
        case actionUrl = "action_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Backend id gondermeyebiler — auto-generate
        self.id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        self.type = try container.decode(String.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.priority = try container.decode(Int.self, forKey: .priority)
        self.iconName = try? container.decodeIfPresent(String.self, forKey: .iconName)
        self.actionUrl = try? container.decodeIfPresent(String.self, forKey: .actionUrl)
        self.metadata = try? container.decodeIfPresent([String: String].self, forKey: .metadata)
    }
}

struct RecommendationUserProfile: Codable {
    let fitnessLevel: String?
    let goal: String?
    let weeklyWorkouts: Int?
    let avgCalories: Double?

    enum CodingKeys: String, CodingKey {
        case fitnessLevel = "fitness_level"
        case goal
        case weeklyWorkouts = "weekly_workouts"
        case avgCalories = "avg_calories"
    }
}

// MARK: - Service

class AIRecommendationService {
    static let shared = AIRecommendationService()
    private init() {}

    /// Gunluk ML tovsiyelerini al
    func getRecommendations() async throws -> AIRecommendationResponse {
        return try await APIService.shared.request(
            endpoint: "/api/v1/ai/recommendations",
            method: "GET"
        )
    }

    /// Spesifik tip ucun tovsiyeler
    func getRecommendations(type: String) async throws -> AIRecommendationResponse {
        return try await APIService.shared.request(
            endpoint: "/api/v1/ai/recommendations",
            method: "GET",
            queryItems: [URLQueryItem(name: "type", value: type)]
        )
    }
}
