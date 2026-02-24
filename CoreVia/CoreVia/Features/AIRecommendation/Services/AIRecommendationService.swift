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
    let generatedAt: Date
    let userProfile: RecommendationUserProfile?

    enum CodingKeys: String, CodingKey {
        case recommendations
        case generatedAt = "generated_at"
        case userProfile = "user_profile"
    }
}

struct AIRecommendation: Identifiable, Codable {
    let id: String
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
