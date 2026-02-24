//
//  DailySurveyService.swift
//  CoreVia
//
//  Gundelik survey API servisi
//  Backend endpointleri: /api/v1/survey/daily, /daily/today, /daily/history, /questions
//

import Foundation

class DailySurveyService {
    static let shared = DailySurveyService()
    private init() {}

    /// Gundelik survey-i gonder
    func submitSurvey(_ request: DailySurveyRequest) async throws -> DailySurveyResponse {
        return try await APIService.shared.request(
            endpoint: "/api/v1/survey/daily",
            method: "POST",
            body: request
        )
    }

    /// Bugunku survey statusunu yoxla
    func getTodayStatus() async throws -> TodaySurveyStatus {
        return try await APIService.shared.request(
            endpoint: "/api/v1/survey/daily/today",
            method: "GET"
        )
    }

    /// Survey suallarini al (lokalize edilmis)
    func getQuestions(lang: String = "az") async throws -> SurveyQuestionsResponse {
        return try await APIService.shared.request(
            endpoint: "/api/v1/survey/questions",
            method: "GET",
            queryItems: [URLQueryItem(name: "lang", value: lang)]
        )
    }

    /// Son N gunluk survey tarixcesi
    func getHistory(days: Int = 30) async throws -> SurveyHistoryResponse {
        return try await APIService.shared.request(
            endpoint: "/api/v1/survey/daily/history",
            method: "GET",
            queryItems: [URLQueryItem(name: "days", value: String(days))]
        )
    }
}

// MARK: - History Response
struct SurveyHistoryResponse: Codable {
    let count: Int
    let surveys: [DailySurveyResponse]
}
