//
//  UserProfile.swift
//  CoreVia
//

import Foundation

class UserProfileManager: ObservableObject {

    static let shared = UserProfileManager()

    @Published var userProfile: UserProfile

    private let clientProfileKey = "client_profile_data"
    private let trainerProfileKey = "trainer_profile_data"

    init() {
        // Default olaraq client profili yüklə
        if let data = UserDefaults.standard.data(forKey: "client_profile_data"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
        } else {
            self.userProfile = UserProfileManager.defaultClientProfile
        }
    }

    // MARK: - Default Profillər
    static let defaultClientProfile = UserProfile(
        name: "Tələbə İstifadəçi",
        email: "student@corevia.com",
        userType: .client,
        age: 25,
        weight: 75,
        height: 180,
        goal: "Arıqlamaq"
    )

    static let defaultTrainerProfile = UserProfile(
        name: "Müəllim İstifadəçi",
        email: "teacher@corevia.com",
        userType: .trainer,
        specialty: "Fitness & Bodybuilding",
        experience: 5,
        bio: "Peşəkar fitness müəllimi",
        rating: 4.8,
        students: 12
    )

    // MARK: - Profil saxlama (cari userType-a görə düzgün key-ə yazır)
    func saveProfile(_ profile: UserProfile) {
        self.userProfile = profile

        let key = profile.userType == .client ? clientProfileKey : trainerProfileKey

        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // MARK: - Hesab tipinə görə profili yüklə
    func updateUserType(_ type: UserProfileType) {
        loadProfileForType(type)
    }

    func loadProfileForType(_ type: UserProfileType) {
        let key = type == .client ? clientProfileKey : trainerProfileKey

        if let data = UserDefaults.standard.data(forKey: key),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
        } else {
            // İlk dəfə giriş - default profil yarat və saxla
            let defaultProfile = type == .client ? UserProfileManager.defaultClientProfile : UserProfileManager.defaultTrainerProfile
            saveProfile(defaultProfile)
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
}

enum UserProfileType: String, Codable {
    case client = "Müştəri"
    case trainer = "Müəllim"

    var localizedName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .client: return loc.localized("login_student")
        case .trainer: return loc.localized("login_teacher")
        }
    }
}
