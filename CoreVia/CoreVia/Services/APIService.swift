import Foundation
import UIKit

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(String)
    case serverError(Int, String)
    case networkError(String)
    case unauthorized
    case forbidden(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Yanlış URL"
        case .noData: return "Məlumat yoxdur"
        case .decodingError(let msg): return "Parse xətası: \(msg)"
        case .serverError(let code, let msg): return "Server xətası (\(code)): \(msg)"
        case .networkError(let msg): return "Şəbəkə xətası: \(msg)"
        case .unauthorized: return "Sessiya bitib. Yenidən giriş edin."
        case .forbidden(let msg): return msg
        }
    }
}

// MARK: - API Response models
struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

struct ErrorDetail: Codable {
    let detail: String?
}

// MARK: - API Service
class APIService {
    static let shared = APIService()

    // Backend URL - development və production üçün ayrı
    #if DEBUG
    let baseURL = "http://localhost:8000"  // Development
    #else
    let baseURL = "https://api.corevia.az"  // Production (HTTPS)
    #endif

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            // Backend ISO format: "2026-02-01T10:00:00.000000"
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd",
            ]
            for format in formats {
                let f = DateFormatter()
                f.dateFormat = format
                f.timeZone = TimeZone(identifier: "UTC")
                if let date = f.date(from: dateString) { return date }
            }
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Date format tanınmadı: \(dateString)"))
        }

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Generic Request

    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Auth header
        if requiresAuth {
            guard let token = KeychainManager.shared.accessToken else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Body
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await performRequest(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response")
        }

        // 401 - token expired, refresh et
        if httpResponse.statusCode == 401 && requiresAuth {
            let refreshed = await refreshTokenIfNeeded()
            if refreshed {
                // Yeni token ile tekrar dene
                var retryRequest = request
                retryRequest.setValue("Bearer \(KeychainManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                let (retryData, retryResponse) = try await performRequest(retryRequest)
                guard let retryHttp = retryResponse as? HTTPURLResponse else {
                    throw APIError.networkError("Invalid response")
                }
                return try handleResponse(data: retryData, statusCode: retryHttp.statusCode)
            } else {
                throw APIError.unauthorized
            }
        }

        return try handleResponse(data: data, statusCode: httpResponse.statusCode)
    }

    /// Response-siz request (DELETE kimi)
    func requestVoid(
        endpoint: String,
        method: String = "DELETE",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = KeychainManager.shared.accessToken else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await performRequest(request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response")
        }

        if httpResponse.statusCode == 401 && requiresAuth {
            let refreshed = await refreshTokenIfNeeded()
            if refreshed {
                var retryRequest = request
                retryRequest.setValue("Bearer \(KeychainManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                let (_, retryResponse) = try await performRequest(retryRequest)
                guard let retryHttp = retryResponse as? HTTPURLResponse, (200...299).contains(retryHttp.statusCode) else {
                    throw APIError.unauthorized
                }
                return
            }
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let detail = try? decoder.decode(ErrorDetail.self, from: data)
            throw APIError.serverError(httpResponse.statusCode, detail?.detail ?? "Xəta baş verdi")
        }
    }

    // MARK: - Multipart Upload (Image)

    func uploadImage(
        endpoint: String,
        imageData: Data,
        fieldName: String = "file",
        fileName: String = "image.jpg"
    ) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = KeychainManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await performRequest(request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let httpResponse = response as? HTTPURLResponse
            let detail = try? decoder.decode(ErrorDetail.self, from: data)
            throw APIError.serverError(httpResponse?.statusCode ?? 500, detail?.detail ?? "Upload uğursuz oldu")
        }
        return data
    }

    // MARK: - Multipart Upload (Image + Form Fields)

    func uploadImageWithFields(
        endpoint: String,
        imageData: Data,
        fields: [String: String],
        fieldName: String = "file",
        fileName: String = "photo.jpg"
    ) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = KeychainManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()

        // Form field-leri elave et
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Sekil elave et
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await performRequest(request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let detail = try? decoder.decode(ErrorDetail.self, from: data)
            if httpResponse.statusCode == 429 {
                throw APIError.serverError(429, detail?.detail ?? "Coxlu sorgu. Bir az gozleyin.")
            }
            throw APIError.serverError(httpResponse.statusCode, detail?.detail ?? "Upload ugursuz oldu")
        }
        return data
    }

    // MARK: - Private Helpers

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }

    private func handleResponse<T: Decodable>(data: Data, statusCode: Int) throws -> T {
        guard (200...299).contains(statusCode) else {
            let detail = try? decoder.decode(ErrorDetail.self, from: data)
            if statusCode == 403 {
                throw APIError.forbidden(detail?.detail ?? "İcazə yoxdur")
            }
            throw APIError.serverError(statusCode, detail?.detail ?? "Xəta baş verdi")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    // MARK: - Token Refresh

    private func refreshTokenIfNeeded() async -> Bool {
        guard let refreshToken = KeychainManager.shared.refreshToken else { return false }

        guard let url = URL(string: "\(baseURL)/api/v1/auth/refresh") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                KeychainManager.shared.clearTokens()
                return false
            }

            let authResponse = try decoder.decode(AuthResponse.self, from: data)
            KeychainManager.shared.accessToken = authResponse.accessToken
            KeychainManager.shared.refreshToken = authResponse.refreshToken
            return true
        } catch {
            KeychainManager.shared.clearTokens()
            return false
        }
    }
}
