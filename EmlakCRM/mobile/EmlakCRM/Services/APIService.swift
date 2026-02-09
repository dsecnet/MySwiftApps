//
//  APIService.swift
//  EmlakCRM
//
//  API Service Layer
//

import Foundation

class APIService {
    static let shared = APIService()

    // Base URL - dəyişdirmək lazım olacaq
    private let baseURL = "http://localhost:8001/api/v1"

    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "access_token") }
    }

    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refresh_token") }
        set { UserDefaults.standard.set(newValue, forKey: "refresh_token") }
    }

    // MARK: - Generic Request

    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            // Try to refresh token
            try await refreshAccessToken()
            // Retry request
            return try await self.request(endpoint: endpoint, method: method, body: body)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Auth

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await request(endpoint: "/auth/login", method: "POST", body: body)

        accessToken = response.accessToken
        refreshToken = response.refreshToken

        return response
    }

    func register(name: String, email: String, phone: String, password: String) async throws -> AuthResponse {
        let body = RegisterRequest(name: name, email: email, phone: phone, password: password)
        let response: AuthResponse = try await request(endpoint: "/auth/register", method: "POST", body: body)

        accessToken = response.accessToken
        refreshToken = response.refreshToken

        return response
    }

    func getCurrentUser() async throws -> User {
        return try await request(endpoint: "/auth/me")
    }

    private func refreshAccessToken() async throws {
        guard let refresh = refreshToken else {
            throw APIError.unauthorized
        }

        let body = ["refresh_token": refresh]
        let response: AuthResponse = try await request(endpoint: "/auth/refresh", method: "POST", body: body)
        accessToken = response.accessToken
    }

    func logout() {
        accessToken = nil
        refreshToken = nil
    }

    // MARK: - Dashboard

    func getDashboard() async throws -> DashboardResponse {
        return try await request(endpoint: "/dashboard/")
    }

    // MARK: - Properties

    func getProperties(page: Int = 1, limit: Int = 20) async throws -> PropertyListResponse {
        return try await request(endpoint: "/properties/?page=\(page)&limit=\(limit)")
    }

    func createProperty(_ property: PropertyCreate) async throws -> Property {
        return try await request(endpoint: "/properties/", method: "POST", body: property)
    }

    func getPropertyStats() async throws -> PropertyStatsResponse {
        return try await request(endpoint: "/properties/stats/summary")
    }

    // MARK: - Clients

    func getClients(page: Int = 1, limit: Int = 20) async throws -> ClientListResponse {
        return try await request(endpoint: "/clients/?page=\(page)&limit=\(limit)")
    }

    func createClient(_ client: ClientCreate) async throws -> Client {
        return try await request(endpoint: "/clients/", method: "POST", body: client)
    }

    func getClientStats() async throws -> ClientStatsResponse {
        return try await request(endpoint: "/clients/stats/summary")
    }

    // MARK: - Activities

    func getUpcomingActivities(limit: Int = 10) async throws -> ActivityListResponse {
        return try await request(endpoint: "/activities/upcoming?limit=\(limit)")
    }

    func getTodayActivities() async throws -> ActivityListResponse {
        return try await request(endpoint: "/activities/today")
    }

    func createActivity(_ activity: ActivityCreate) async throws -> Activity {
        return try await request(endpoint: "/activities/", method: "POST", body: activity)
    }

    // MARK: - Deals

    func getDealsWithDetails(limit: Int = 20) async throws -> [DealWithDetails] {
        return try await request(endpoint: "/deals/with-details?limit=\(limit)")
    }

    func createDeal(_ deal: DealCreate) async throws -> Deal {
        return try await request(endpoint: "/deals/", method: "POST", body: deal)
    }

    func getDealStats() async throws -> DealStatsResponse {
        return try await request(endpoint: "/deals/stats/summary")
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized - please login again"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
