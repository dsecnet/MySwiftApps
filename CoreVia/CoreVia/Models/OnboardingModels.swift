//
//  OnboardingModels.swift
//  CoreVia
//

import Foundation

// MARK: - Onboarding Option
struct OnboardingOption: Codable, Identifiable {
    var id: String { getValue("id") }
    let values: [String: String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        values = try container.decode([String: String].self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }

    func getValue(_ key: String) -> String {
        values[key] ?? ""
    }

    func localizedName(language: AppLanguage) -> String {
        switch language {
        case .az: return values["name_az"] ?? values["id"] ?? ""
        case .en: return values["name_en"] ?? values["id"] ?? ""
        case .ru: return values["name_ru"] ?? values["id"] ?? ""
        }
    }

    var icon: String {
        values["icon"] ?? "circle"
    }
}

// MARK: - Onboarding Options Response
struct OnboardingOptionsResponse: Codable {
    let goals: [[String: String]]
    let fitnessLevels: [[String: String]]
    let trainerTypes: [[String: String]]

    enum CodingKeys: String, CodingKey {
        case goals
        case fitnessLevels = "fitness_levels"
        case trainerTypes = "trainer_types"
    }
}

// MARK: - Onboarding Complete Request
struct OnboardingCompleteRequest: Codable {
    let fitnessGoal: String
    let fitnessLevel: String
    let preferredTrainerType: String?

    enum CodingKeys: String, CodingKey {
        case fitnessGoal = "fitness_goal"
        case fitnessLevel = "fitness_level"
        case preferredTrainerType = "preferred_trainer_type"
    }
}

// MARK: - Onboarding Status Response
struct OnboardingStatusResponse: Codable {
    let id: String
    let userId: String
    let fitnessGoal: String?
    let fitnessLevel: String?
    let preferredTrainerType: String?
    let isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case fitnessGoal = "fitness_goal"
        case fitnessLevel = "fitness_level"
        case preferredTrainerType = "preferred_trainer_type"
        case isCompleted = "is_completed"
    }
}

// MARK: - Onboarding Manager
class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()

    @Published var options: OnboardingOptionsResponse?
    @Published var isCompleted = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIService.shared
    private init() {}

    @MainActor
    func fetchOptions() async {
        isLoading = true
        do {
            let result: OnboardingOptionsResponse = try await api.request(
                endpoint: "/api/v1/onboarding/options",
                requiresAuth: false
            )
            options = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func checkStatus() async {
        do {
            let result: OnboardingStatusResponse? = try await api.request(
                endpoint: "/api/v1/onboarding/status"
            )
            isCompleted = result?.isCompleted ?? false
        } catch {
            isCompleted = false
        }
    }

    @MainActor
    func complete(goal: String, level: String, trainerType: String?) async -> Bool {
        errorMessage = nil
        do {
            let body = OnboardingCompleteRequest(
                fitnessGoal: goal,
                fitnessLevel: level,
                preferredTrainerType: trainerType
            )
            let _: OnboardingStatusResponse = try await api.request(
                endpoint: "/api/v1/onboarding/complete",
                method: "POST",
                body: body
            )
            isCompleted = true
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
