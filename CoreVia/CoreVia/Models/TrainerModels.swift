//
//  TrainerModels.swift
//  CoreVia
//
//  Backend TrainerListResponse schema-sına uyğun model
//

import Foundation
import SwiftUI

// MARK: - Trainer Response (API-dən gələn)
struct TrainerResponse: Codable, Identifiable, Hashable {
    static func == (lhs: TrainerResponse, rhs: TrainerResponse) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    let id: String
    let name: String
    let profileImageUrl: String?
    let specialization: String?
    let experience: Int?
    let rating: Double?
    let pricePerSession: Double?
    let bio: String?
    let verificationStatus: String
    let instagramHandle: String?

    enum CodingKeys: String, CodingKey {
        case id, name, specialization, experience, rating, bio
        case profileImageUrl = "profile_image_url"
        case pricePerSession = "price_per_session"
        case verificationStatus = "verification_status"
        case instagramHandle = "instagram_handle"
    }

    // Backend specialization → UI category
    var category: TrainerCategory {
        guard let spec = specialization?.lowercased() else { return .fitness }
        if spec.contains("yoga") { return .yoga }
        if spec.contains("cardio") { return .cardio }
        if spec.contains("nutrition") || spec.contains("qidalanma") { return .nutrition }
        if spec.contains("strength") || spec.contains("guc") { return .strength }
        return .fitness
    }

    var displayRating: String {
        guard let r = rating else { return "--" }
        return String(format: "%.1f", r)
    }

    var displayPrice: String {
        guard let p = pricePerSession else { return "--" }
        return String(format: "%.0f ₼", p)
    }

    var displayExperience: String {
        guard let e = experience else { return "--" }
        return "\(e) il"
    }
}

// MARK: - Trainer Category
enum TrainerCategory: String, CaseIterable {
    case fitness = "Fitness"
    case strength = "Guc"
    case cardio = "Kardio"
    case yoga = "Yoga"
    case nutrition = "Qidalanma"

    var icon: String {
        switch self {
        case .fitness: return "figure.strengthtraining.traditional"
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .yoga: return "figure.yoga"
        case .nutrition: return "leaf.fill"
        }
    }

    var color: SwiftUI.Color {
        switch self {
        case .fitness: return .red
        case .strength: return .orange
        case .cardio: return .pink
        case .yoga: return .purple
        case .nutrition: return .green
        }
    }
}
