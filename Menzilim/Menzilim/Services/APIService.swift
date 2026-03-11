import Foundation

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(String)
    case serverError(Int, String)
    case unauthorized
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError(let msg): return "Decoding error: \(msg)"
        case .serverError(let code, let msg): return "Server error \(code): \(msg)"
        case .unauthorized: return "Unauthorized"
        case .networkError(let msg): return "Network error: \(msg)"
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

// MARK: - API Service
class APIService {
    static let shared = APIService()

    // Change this to your actual backend URL
    private let baseURL = "http://localhost:8001/api/v1"

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso.date(from: dateStr) { return date }

            iso.formatOptions = [.withInternetDateTime]
            if let date = iso.date(from: dateStr) { return date }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: dateStr) { return date }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateStr)")
        }
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private init() {}

    // MARK: - Generic Request
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: (any Encodable)? = nil,
        queryParams: [String: String]? = nil,
        authenticated: Bool = true
    ) async throws -> T {
        // Build URL
        var urlString = "\(baseURL)\(endpoint)"
        if let params = queryParams {
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += "?\(queryString)"
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Auth header
        if authenticated, let token = KeychainManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Body
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Execute
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response")
        }

        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error.localizedDescription)
            }
        case 401:
            // Try to refresh token
            if authenticated {
                let refreshed = try await refreshToken()
                if refreshed {
                    return try await self.request(
                        endpoint: endpoint,
                        method: method,
                        body: body,
                        queryParams: queryParams,
                        authenticated: true
                    )
                }
            }
            throw APIError.unauthorized
        default:
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, errorMsg)
        }
    }

    // MARK: - Upload Image
    func uploadImage(imageData: Data, type: String = "listing") async throws -> String {
        let endpoint = "\(baseURL)/upload/image"
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = KeychainManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: .utf8)!)
        body.append(type.data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)

        struct UploadResponse: Codable {
            let url: String
        }
        let response = try decoder.decode(UploadResponse.self, from: data)
        return response.url
    }

    // MARK: - Refresh Token
    private func refreshToken() async throws -> Bool {
        guard let refreshToken = KeychainManager.shared.refreshToken else {
            return false
        }

        let body = TokenRefreshRequest(refreshToken: refreshToken)
        let endpoint = "\(baseURL)/auth/refresh"

        guard let url = URL(string: endpoint) else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            KeychainManager.shared.clearAll()
            return false
        }

        let tokenResponse = try decoder.decode(TokenRefreshResponse.self, from: data)
        KeychainManager.shared.accessToken = tokenResponse.accessToken
        return true
    }
}
