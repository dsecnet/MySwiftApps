//
//  DailySurveyModels.swift
//  CoreVia
//
//  Gundelik survey data modelleri
//  Backend: POST /api/v1/survey/daily
//

import Foundation

// MARK: - Request

struct DailySurveyRequest: Encodable {
    let energyLevel: Int        // 1-5
    let sleepHours: Double      // 0-24
    let sleepQuality: Int       // 1-5
    let stressLevel: Int        // 1-5
    let muscleSoreness: Int     // 1-5
    let mood: Int               // 1-5
    let waterGlasses: Int       // 0-30
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case energyLevel = "energy_level"
        case sleepHours = "sleep_hours"
        case sleepQuality = "sleep_quality"
        case stressLevel = "stress_level"
        case muscleSoreness = "muscle_soreness"
        case mood
        case waterGlasses = "water_glasses"
        case notes
    }
}

// MARK: - Response

struct DailySurveyResponse: Codable, Identifiable {
    let id: String
    let date: String
    let energyLevel: Int
    let sleepHours: Double
    let sleepQuality: Int
    let stressLevel: Int
    let muscleSoreness: Int
    let mood: Int
    let waterGlasses: Int
    let notes: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, date, notes, mood
        case energyLevel = "energy_level"
        case sleepHours = "sleep_hours"
        case sleepQuality = "sleep_quality"
        case stressLevel = "stress_level"
        case muscleSoreness = "muscle_soreness"
        case waterGlasses = "water_glasses"
        case createdAt = "created_at"
    }
}

// MARK: - Today Status

struct TodaySurveyStatus: Codable {
    let completed: Bool
    let survey: DailySurveyResponse?
}

// MARK: - Questions

struct SurveyQuestion: Codable, Identifiable {
    var id: String { key }
    let key: String
    let title: String
    let description: String
    let type: String    // "slider" or "number"
    let minValue: Int
    let maxValue: Int
    let emojiLabels: [String]?

    enum CodingKeys: String, CodingKey {
        case key, title, description, type
        case minValue = "min_value"
        case maxValue = "max_value"
        case emojiLabels = "emoji_labels"
    }
}

struct SurveyQuestionsResponse: Codable {
    let questions: [SurveyQuestion]
    let alreadyCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case questions
        case alreadyCompleted = "already_completed"
    }
}
