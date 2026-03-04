import Foundation
import UIKit
import CryptoKit
import os.log

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
        case .invalidURL: return "Yanlis URL"
        case .noData: return "Melumat yoxdur"
        case .decodingError(let msg): return "Parse xetasi: \(msg)"
        case .serverError(let code, let msg): return "Server xetasi (\(code)): \(msg)"
        case .networkError(let msg): return "Sebeke xetasi: \(msg)"
        case .unauthorized: return "Sessiya bitib. Yeniden giris edin."
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
class APIService: NSObject {
    static let shared = APIService()

    #if targetEnvironment(simulator)
    let baseURL = "http://localhost:8000"
    #elseif DEBUG
    let baseURL = "https://api.corevia.life"
    #else
    let baseURL = "https://api.corevia.life"
    #endif

    private var session: URLSession!
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // MARK: - SSL Public Key Pinning
    // SHA-256 hash of api.corevia.life server's public key.
    // Yenilemek ucun: openssl s_client -connect api.corevia.life:443 | \
    //   openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | \
    //   openssl dgst -sha256 -binary | base64
    // Birden cox hash saxlamaq sertifikat yenilemesinde kesinti olmamasi ucun tovsiye olunur.
    private let pinnedPublicKeyHashes: Set<String> = [
        // Cari sertifikat (2025)
        "REPLACE_WITH_REAL_SHA256_HASH_OF_API_COREVIA_LIFE_PUBKEY=",
        // Backup sertifikat (rotasiya ucun)
        "REPLACE_WITH_BACKUP_SHA256_HASH="
    ]

    private override init() {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
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
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                debugDescription: "Date format taninmadi: \(dateString)"))
        }
        decoder = dec

        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        encoder = enc

        super.init()

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")
        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems
        }
        guard let url = urlComponents?.url else {
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
                guard let newToken = KeychainManager.shared.accessToken, !newToken.isEmpty else {
                    throw APIError.unauthorized
                }
                var retryRequest = request
                retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
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
                guard let newToken = KeychainManager.shared.accessToken, !newToken.isEmpty else {
                    throw APIError.unauthorized
                }
                var retryRequest = request
                retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                let (_, retryResponse) = try await performRequest(retryRequest)
                guard let retryHttp = retryResponse as? HTTPURLResponse,
                      (200...299).contains(retryHttp.statusCode) else {
                    throw APIError.unauthorized
                }
                return
            }
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let detail = try? decoder.decode(ErrorDetail.self, from: data)
            throw APIError.serverError(httpResponse.statusCode, detail?.detail ?? "Xeta bas verdi")
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
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.appendString("\r\n--\(boundary)--\r\n")

        request.httpBody = body

        let (data, response) = try await performRequest(request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let failedResponse = response as? HTTPURLResponse
            let detail = try? decoder.decode(ErrorDetail.self, from: data)
            throw APIError.serverError(failedResponse?.statusCode ?? 500,
                                       detail?.detail ?? "Upload ugursuz oldu")
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
        for (key, value) in fields {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.appendString("\r\n--\(boundary)--\r\n")

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
            throw APIError.serverError(httpResponse.statusCode,
                                       detail?.detail ?? "Upload ugursuz oldu")
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
                throw APIError.forbidden(detail?.detail ?? "Icaze yoxdur")
            }
            throw APIError.serverError(statusCode, detail?.detail ?? "Xeta bas verdi")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            AppLogger.network.error("Decode xetasi: \(String(describing: type(of: decodingError)))")
            throw APIError.decodingError("\(decodingError)")
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

        let body = ["refresh_token": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                KeychainManager.shared.clearTokens()
                return false
            }

            let authResponse = try decoder.decode(AuthResponse.self, from: data)
            KeychainManager.shared.accessToken = authResponse.accessToken
            KeychainManager.shared.refreshToken = authResponse.refreshToken
            return true
        } catch {
            AppLogger.auth.error("Token refresh failed")
            KeychainManager.shared.clearTokens()
            return false
        }
    }
}

// MARK: - SSL Public Key Pinning (iOS-03 fix)
extension APIService: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let host = challenge.protectionSpace.host

        // Yalniz oz API domenimizi pin edirik
        guard host == "api.corevia.life" else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Standart SSL zencirini yoxla
        let policies = [SecPolicyCreateSSL(true, host as CFString)]
        SecTrustSetPolicies(serverTrust, policies as CFTypeRef)

        var cfError: CFError?
        let isTrusted = SecTrustEvaluateWithError(serverTrust, &cfError)
        guard isTrusted else {
            AppLogger.network.error("SSL trust evaluation failed for \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Public key pinning: server-in public key-inin SHA-256 hash-ini yoxla
        guard let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let leafCert = certificates.first,
              let publicKey = SecCertificateCopyKey(leafCert),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            AppLogger.network.error("Could not extract public key from server certificate")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // SHA-256 hash hesabla
        let keyHash = SHA256.hash(data: publicKeyData)
        let hashBase64 = Data(keyHash).base64EncodedString()

        if pinnedPublicKeyHashes.contains(hashBase64) {
            // Hash uygun gelir - baglanti icaze verilir
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            // Hash uygun gelmedi - potensial MITM hucumu
            AppLogger.network.error("SSL pinning failed: public key hash mismatch for \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

// MARK: - Data Helper Extension
private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
