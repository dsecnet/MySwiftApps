//
//  UserProfile.swift
//  CoreVia
//
//  Profil data management - Backend API ilə
//

import Foundation
import os.log

// MARK: - Profile Update Request
private struct ProfileUpdateRequest: Encodable {
    var name: String?
    var age: Int?
    var weight: Double?
    var height: Double?
    var goal: String?
    var specialization: String?
    var experience: Int?
    var bio: String?
    var pricePerSession: Double?

    enum CodingKeys: String, CodingKey {
        case name, age, weight, height, goal, specialization, experience, bio
        case pricePerSession = "price_per_session"
    }
}

class UserProfileManager: ObservableObject {

    static let shared = UserProfileManager()

    @Published var userProfile: UserProfile

    private let api = APIService.shared

    init() {
        self.userProfile = UserProfileManager.defaultClientProfile
    }

    // MARK: - Default Profillər
    static var defaultClientProfile: UserProfile {
        let loc = LocalizationManager.shared
        return UserProfile(
            name: loc.localized("default_student_name"),
            email: "student@corevia.com",
            userType: .client,
            age: 25,
            weight: 75,
            height: 180,
            goal: loc.localized("edit_goal_lose")
        )
    }

    static var defaultTrainerProfile: UserProfile {
        let loc = LocalizationManager.shared
        return UserProfile(
            name: loc.localized("default_trainer_name"),
            email: "teacher@corevia.com",
            userType: .trainer,
            specialty: "Fitness & Bodybuilding",
            experience: 5,
            bio: loc.localized("default_trainer_bio"),
            rating: 4.8,
            students: 12
        )
    }

    // MARK: - Backend-ə profil yenilə
    func saveProfile(_ profile: UserProfile) {
        self.userProfile = profile

        guard KeychainManager.shared.isLoggedIn else { return }

        Task {
            do {
                let request = ProfileUpdateRequest(
                    name: profile.name,
                    age: profile.age,
                    weight: profile.weight,
                    height: profile.height,
                    goal: profile.goal,
                    specialization: profile.specialty,
                    experience: profile.experience,
                    bio: profile.bio,
                    pricePerSession: profile.pricePerSession
                )
                let _: UserResponse = try await api.request(
                    endpoint: "/api/v1/users/profile",
                    method: "PUT",
                    body: request
                )
            } catch {
                AppLogger.network.error("Profile update xetasi: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Hesab tipinə görə profili yüklə
    func updateUserType(_ type: UserProfileType) {
        loadProfileForType(type)
    }

    func loadProfileForType(_ type: UserProfileType) {
        guard KeychainManager.shared.isLoggedIn else {
            let defaultProfile = type == .client ? UserProfileManager.defaultClientProfile : UserProfileManager.defaultTrainerProfile
            self.userProfile = defaultProfile
            return
        }

        // Backend-dən profili yenidən yüklə
        Task {
            await AuthManager.shared.fetchCurrentUser()
        }
    }
}

// MARK: - User Profile Model
struct UserProfile: Codable {
    var name: String
    var email: String
    var userType: UserProfileType

    // Client specific
    var age: Int?
    var weight: Double?
    var height: Double?
    var goal: String?

    // Trainer specific
    var specialty: String?
    var experience: Int?
    var bio: String?
    var rating: Double?
    var students: Int?
    var pricePerSession: Double?
}

enum UserProfileType: String, Codable {
    case client = "client"
    case trainer = "trainer"

    var localizedName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .client: return loc.localized("login_student")
        case .trainer: return loc.localized("login_teacher")
        }
    }
}
