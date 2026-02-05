//
//  User.swift
//  Myfitness APP
//
//  Created by Vusal Dadashov on 27.01.26.
//

//
//  User.swift
//  FitnessApp
//
//  İstifadəçi data modeli
//

import Foundation

// MARK: - User Type (İstifadəçi növü)
// Enum - məhdud seçimlər üçün istifadə olunur

enum UserType: String, Codable {
    case client = "client"           // Müştəri
    case trainer = "trainer"         // Müəllim
    
    // Enum-dan string almaq üçün
    var displayName: String {
        switch self {
        case .client:
            return LocalizationManager.shared.localized("profile_type_client")
        case .trainer:
            return LocalizationManager.shared.localized("profile_type_trainer")
        }
    }
}

// MARK: - User Model
// Identifiable - SwiftUI list-lərdə istifadə üçün
// Codable - JSON-a çevirmək/JSON-dan oxumaq üçün

struct User: Identifiable, Codable {
    let id: String                    // Unikal ID
    var name: String                  // Ad
    var email: String                 // Email
    var userType: UserType            // Client və ya Trainer
    var profileImageURL: String?      // Profil şəkli (optional - olmaya da bilər)
    var createdAt: Date               // Yaradılma tarixi
    
    // MARK: - Trainer spesifik məlumatlar
    var specialization: String?       // İxtisas (məsələn: "Bodybuilding", "Yoga")
    var experience: Int?              // Təcrübə (il)
    var rating: Double?               // Reytinq (0-5)
    var pricePerSession: Double?      // Seansın qiyməti
    var bio: String?                  // Haqqında məlumat
    
    // MARK: - Client spesifik məlumatlar
    var age: Int?                     // Yaş
    var weight: Double?               // Çəki (kg)
    var height: Double?               // Boy (sm)
    var goal: String?                 // Məqsəd ("Arıqlamaq", "Əzələ toplamaq" və s.)
    var trainerId: String?            // Müəllim ID (əgər müəllimi varsa)
}

// MARK: - Mock Data (Test məlumatları)
// Development zamanı test etmək üçün fake data

extension User {
    static let mockClient = User(
        id: "1",
        name: "Əli Məmmədov",
        email: "ali@example.com",
        userType: .client,
        createdAt: Date(),
        age: 25,
        weight: 75.0,
        height: 180,
        goal: "Arıqlamaq"
    )
    
    static let mockTrainer = User(
        id: "2",
        name: "Leyla Həsənova",
        email: "leyla@example.com",
        userType: .trainer,
        createdAt: Date(),
        specialization: "Fitness və Bodybuilding",
        experience: 5,
        rating: 4.8,
        pricePerSession: 50.0,
        bio: "Professional fitness coach with 5 years experience"
    )
}

// MARK: - Niyə struct istifadə edirik?
// Struct-lar value type-dır, dəyişiklik edəndə yeni kopya yaradır
// Class-dan fərqli olaraq daha sürətli və thread-safe-dir
// SwiftUI struct-larla yaxşı işləyir

// MARK: - Identifiable nədir?
// SwiftUI-da ForEach və List-də istifadə etmək üçün lazımdır
// id property-si olmalıdır

// MARK: - Codable nədir?
// JSON ↔️ Swift object çevrilməsi üçün
// Backend-dən data alıb göndərəndə istifadə olunur
