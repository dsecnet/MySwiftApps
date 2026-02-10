import Foundation

class MortgageService {
    static let shared = MortgageService()
    private let baseURL = "http://localhost:8001"

    private init() {}

    // MARK: - Calculate Mortgage
    func calculateMortgage(
        propertyPrice: Double,
        downPaymentPercent: Double,
        termYears: Int,
        bankKey: String? = nil,
        customRate: Double? = nil,
        currency: String = "AZN"
    ) async throws -> MortgageResult {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MortgageAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/mortgage/calculate") else {
            throw MortgageAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "property_price": propertyPrice,
            "down_payment_percent": downPaymentPercent,
            "term_years": termYears,
            "bank_key": bankKey as Any,
            "custom_rate": customRate as Any,
            "currency": currency
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MortgageAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MortgageAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(MortgageResult.self, from: data)
    }

    // MARK: - Compare Banks
    func compareBanks(
        propertyPrice: Double,
        downPaymentPercent: Double,
        termYears: Int,
        currency: String = "AZN"
    ) async throws -> BankComparisonResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MortgageAPIError.unauthorized
        }

        let urlString = "\(baseURL)/mortgage/compare?property_price=\(propertyPrice)&down_payment_percent=\(downPaymentPercent)&term_years=\(termYears)&currency=\(currency)"

        guard let url = URL(string: urlString) else {
            throw MortgageAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MortgageAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MortgageAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(BankComparisonResponse.self, from: data)
    }

    // MARK: - Get All Banks
    func getAllBanks() async throws -> BanksResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MortgageAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/mortgage/banks") else {
            throw MortgageAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MortgageAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MortgageAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(BanksResponse.self, from: data)
    }

    // MARK: - Get Payment Schedule
    func getPaymentSchedule(
        loanAmount: Double,
        annualRate: Double,
        termYears: Int
    ) async throws -> PaymentScheduleResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MortgageAPIError.unauthorized
        }

        let urlString = "\(baseURL)/mortgage/schedule?loan_amount=\(loanAmount)&annual_rate=\(annualRate)&term_years=\(termYears)"

        guard let url = URL(string: urlString) else {
            throw MortgageAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MortgageAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MortgageAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(PaymentScheduleResponse.self, from: data)
    }

    // MARK: - Calculate Affordability
    func calculateAffordability(
        monthlyIncome: Double,
        monthlyExpenses: Double,
        maxPaymentRatio: Double = 40.0
    ) async throws -> AffordabilityResult {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MortgageAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/mortgage/affordability") else {
            throw MortgageAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "monthly_income": monthlyIncome,
            "monthly_expenses": monthlyExpenses,
            "max_payment_ratio": maxPaymentRatio
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MortgageAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MortgageAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(AffordabilityResult.self, from: data)
    }
}

// MARK: - Error
enum MortgageAPIError: Error {
    case invalidURL
    case unauthorized
    case invalidResponse
    case serverError(Int)
}
