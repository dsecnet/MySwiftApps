import Foundation

class APIService {
    static let shared = APIService()

    private let baseURL = "http://localhost:8001/api/v1"
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private init() {}

    // MARK: - Generic Request
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            // Try to refresh token
            try await refreshToken()
            // Retry the request
            return try await self.request(endpoint: endpoint, method: method, body: body, requiresAuth: requiresAuth)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Auth
    func login(email: String, password: String) async throws -> AuthResponse {
        let loginData = "grant_type=&username=\(email)&password=\(password)&scope=&client_id=&client_secret="

        guard let url = URL(string: baseURL + "/auth/login") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = loginData.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidCredentials
        }

        let authResponse = try decoder.decode(AuthResponse.self, from: data)

        // Save tokens
        UserDefaults.standard.set(authResponse.accessToken, forKey: "accessToken")
        UserDefaults.standard.set(authResponse.refreshToken, forKey: "refreshToken")

        return authResponse
    }

    func register(email: String, password: String, fullName: String) async throws -> User {
        let body = RegisterRequest(email: email, password: password, fullName: fullName)
        return try await request(endpoint: "/auth/register", method: "POST", body: body, requiresAuth: false)
    }

    func refreshToken() async throws {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            throw APIError.noRefreshToken
        }

        let response: AuthResponse = try await request(
            endpoint: "/auth/refresh",
            method: "POST",
            body: ["refresh_token": refreshToken],
            requiresAuth: false
        )

        UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
        UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
    }

    // MARK: - Properties
    func getProperties(page: Int = 1, size: Int = 20) async throws -> PaginatedResponse<Property> {
        return try await request(endpoint: "/properties?page=\(page)&size=\(size)")
    }

    func getProperty(id: String) async throws -> Property {
        return try await request(endpoint: "/properties/\(id)")
    }

    func createProperty(_ property: PropertyCreate) async throws -> Property {
        return try await request(endpoint: "/properties", method: "POST", body: property)
    }

    func updateProperty(id: String, _ property: PropertyCreate) async throws -> Property {
        return try await request(endpoint: "/properties/\(id)", method: "PUT", body: property)
    }

    func deleteProperty(id: String) async throws {
        let _: EmptyResponse = try await request(endpoint: "/properties/\(id)", method: "DELETE")
    }

    // MARK: - Clients
    func getClients(page: Int = 1, size: Int = 20) async throws -> PaginatedResponse<Client> {
        return try await request(endpoint: "/clients?page=\(page)&size=\(size)")
    }

    func getClient(id: String) async throws -> Client {
        return try await request(endpoint: "/clients/\(id)")
    }

    func createClient(_ client: ClientCreate) async throws -> Client {
        return try await request(endpoint: "/clients", method: "POST", body: client)
    }

    func updateClient(id: String, _ client: ClientCreate) async throws -> Client {
        return try await request(endpoint: "/clients/\(id)", method: "PUT", body: client)
    }

    func deleteClient(id: String) async throws {
        let _: EmptyResponse = try await request(endpoint: "/clients/\(id)", method: "DELETE")
    }

    // MARK: - Activities
    func getActivities(page: Int = 1, size: Int = 20) async throws -> PaginatedResponse<Activity> {
        return try await request(endpoint: "/activities?page=\(page)&size=\(size)")
    }

    func getActivity(id: String) async throws -> Activity {
        return try await request(endpoint: "/activities/\(id)")
    }

    func createActivity(_ activity: ActivityCreate) async throws -> Activity {
        return try await request(endpoint: "/activities", method: "POST", body: activity)
    }

    func updateActivity(id: String, _ activity: ActivityCreate) async throws -> Activity {
        return try await request(endpoint: "/activities/\(id)", method: "PUT", body: activity)
    }

    func deleteActivity(id: String) async throws {
        let _: EmptyResponse = try await request(endpoint: "/activities/\(id)", method: "DELETE")
    }

    func completeActivity(id: String) async throws -> Activity {
        return try await request(endpoint: "/activities/\(id)/complete", method: "POST")
    }

    // MARK: - Deals
    func getDeals(page: Int = 1, size: Int = 20) async throws -> PaginatedResponse<Deal> {
        return try await request(endpoint: "/deals?page=\(page)&size=\(size)")
    }

    func getDeal(id: String) async throws -> Deal {
        return try await request(endpoint: "/deals/\(id)")
    }

    func createDeal(_ deal: DealCreate) async throws -> Deal {
        return try await request(endpoint: "/deals", method: "POST", body: deal)
    }

    func updateDeal(id: String, _ deal: DealCreate) async throws -> Deal {
        return try await request(endpoint: "/deals/\(id)", method: "PUT", body: deal)
    }

    func deleteDeal(id: String) async throws {
        let _: EmptyResponse = try await request(endpoint: "/deals/\(id)", method: "DELETE")
    }

    // MARK: - Dashboard
    func getDashboardStats() async throws -> DashboardStats {
        return try await request(endpoint: "/dashboard/stats")
    }
}

// MARK: - Errors
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidCredentials
    case noRefreshToken
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Yanlış URL"
        case .invalidResponse:
            return "Cavab alına bilmədi"
        case .invalidCredentials:
            return "Email və ya şifrə yanlışdır"
        case .noRefreshToken:
            return "Refresh token yoxdur"
        case .httpError(let code):
            return "HTTP xətası: \(code)"
        }
    }
}

// MARK: - Empty Response
private struct EmptyResponse: Codable {}
