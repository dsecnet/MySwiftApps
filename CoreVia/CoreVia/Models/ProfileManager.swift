//
//  UserProfile.swift
//  CoreVia
//

import Foundation

class UserProfileManager: ObservableObject {
    
    static let shared = UserProfileManager()
    
    @Published var userProfile: UserProfile
    
    private let profileKey = "user_profile_data"
    
    init() {
        // Load from UserDefaults or create default
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
        } else {
            // Default client profile
            self.userProfile = UserProfile(
                name: "Vusal Dadaşov",
                email: "vusal@example.com",
                userType: .client,
                age: 25,
                weight: 75,
                height: 180,
                goal: "Arıqlamaq"
            )
        }
    }
    
    func saveProfile(_ profile: UserProfile) {
        self.userProfile = profile
        
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
            print("✅ Profil saxlanıldı")
        }
    }
    
    func updateUserType(_ type: UserProfileType) {
        userProfile.userType = type
        saveProfile(userProfile)
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
}
