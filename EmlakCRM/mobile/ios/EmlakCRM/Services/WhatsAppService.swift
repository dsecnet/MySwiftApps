import Foundation
import UIKit

class WhatsAppService {
    static let shared = WhatsAppService()
    private let baseURL = "http://localhost:8001"

    private init() {}

    // MARK: - Send Property to Client
    func sendPropertyToClient(
        propertyId: String,
        clientPhone: String,
        customMessage: String? = nil
    ) async throws -> WhatsAppResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw WhatsAppAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/whatsapp/send/property") else {
            throw WhatsAppAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "property_id": propertyId,
            "client_phone": clientPhone,
            "custom_message": customMessage as Any
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WhatsAppAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw WhatsAppAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(WhatsAppResponse.self, from: data)
    }

    // MARK: - Send Generic Message
    func sendMessage(phone: String, message: String) async throws -> WhatsAppResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw WhatsAppAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/whatsapp/send") else {
            throw WhatsAppAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "phone": phone,
            "message": message
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WhatsAppAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw WhatsAppAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(WhatsAppResponse.self, from: data)
    }

    // MARK: - Get Templates
    func getTemplates() async throws -> WhatsAppTemplatesResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw WhatsAppAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/whatsapp/templates") else {
            throw WhatsAppAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WhatsAppAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw WhatsAppAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(WhatsAppTemplatesResponse.self, from: data)
    }

    // MARK: - Open WhatsApp
    func openWhatsApp(url: String) {
        guard let whatsappURL = URL(string: url) else { return }

        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
        } else {
            // WhatsApp yüklənməyib
            print("WhatsApp is not installed")
        }
    }

    // MARK: - Quick Share Property
    static func quickShareProperty(
        title: String,
        price: Double,
        area: Double?,
        rooms: Int?,
        address: String,
        phone: String
    ) -> String {
        var message = "🏢 *\(title)*\n\n"
        message += "📍 *Ünvan:* \(address)\n"
        message += "💰 *Qiymət:* \(price.toCurrency())\n"

        if let area = area {
            message += "📏 *Sahə:* \(area.toArea())\n"
        }

        if let rooms = rooms {
            message += "🛏️ *Otaq:* \(rooms)\n"
        }

        // URL encode
        guard let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }

        // Remove + from phone and add country code if needed
        var cleanPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if !cleanPhone.hasPrefix("994") {
            if cleanPhone.hasPrefix("0") {
                cleanPhone = "994" + cleanPhone.dropFirst()
            } else {
                cleanPhone = "994" + cleanPhone
            }
        }

        return "https://wa.me/\(cleanPhone)?text=\(encoded)"
    }
}

// MARK: - Response Models
struct WhatsAppResponse: Codable {
    let success: Bool
    let whatsappLink: String
    let messageId: String?
    let phone: String
    let message: String
    let preview: String?
}

struct WhatsAppTemplatesResponse: Codable {
    let templates: [String: WhatsAppTemplate]
}

struct WhatsAppTemplate: Codable {
    let name: String
    let description: String
}

// MARK: - Helper Extension
extension String {
    func toWhatsAppURL() -> URL? {
        return URL(string: self)
    }
}

// MARK: - Error
enum WhatsAppAPIError: Error {
    case invalidURL
    case unauthorized
    case invalidResponse
    case serverError(Int)
}
