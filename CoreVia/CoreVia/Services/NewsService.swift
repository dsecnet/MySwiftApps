import Foundation

class NewsService {
    static let shared = NewsService()
    private var baseURL: String { APIService.shared.baseURL }
    private let keychain = KeychainManager.shared

    private init() {}

    // MARK: - Get Fitness News
    func getFitnessNews(limit: Int = 10, forceRefresh: Bool = false) async throws -> NewsResponse {
        guard let token = keychain.accessToken else {
            throw NewsAPIError.unauthorized
        }

        guard var urlComponents = URLComponents(string: "\(baseURL)/news/") else {
            throw NewsAPIError.invalidURL
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "force_refresh", value: forceRefresh ? "true" : "false")
        ]

        guard let url = urlComponents.url else {
            throw NewsAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NewsAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NewsAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(NewsResponse.self, from: data)
    }

    // MARK: - Get News Categories
    func getNewsCategories() async throws -> NewsCategoriesResponse {
        guard let token = keychain.accessToken else {
            throw NewsAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/news/categories") else {
            throw NewsAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NewsAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NewsAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(NewsCategoriesResponse.self, from: data)
    }

    // MARK: - Refresh News Cache
    func refreshNewsCache() async throws {
        guard let token = keychain.accessToken else {
            throw NewsAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/news/refresh") else {
            throw NewsAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NewsAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NewsAPIError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Error
enum NewsAPIError: Error {
    case invalidURL
    case unauthorized
    case invalidResponse
    case serverError(Int)
}
