import Foundation

// MARK: - Agent Level
enum AgentLevel: Int, Codable, CaseIterable {
    case newbie = 1
    case active = 2
    case professional = 3
    case expert = 4
    case premium = 5

    var displayKey: String {
        switch self {
        case .newbie: return "new_agent"
        case .active: return "active_agent"
        case .professional: return "professional_agent"
        case .expert: return "expert_agent"
        case .premium: return "premium_agent"
        }
    }

    var stars: Int { rawValue }

    var badgeColor: String {
        switch self {
        case .newbie: return "94A3B8"
        case .active: return "3B82F6"
        case .professional: return "F59E0B"
        case .expert: return "8B5CF6"
        case .premium: return "EF4444"
        }
    }

    var badgeName: String {
        switch self {
        case .newbie: return "Bronze"
        case .active: return "Silver"
        case .professional: return "Gold"
        case .expert: return "Platinum"
        case .premium: return "Diamond"
        }
    }
}

// MARK: - Agent Model
struct Agent: Codable, Identifiable {
    let id: String
    let userId: String
    var companyName: String?
    var licenseNumber: String?
    var level: AgentLevel
    var rating: Double
    var totalReviews: Int
    var totalListings: Int
    var totalSales: Int
    var bio: String?
    var isPremium: Bool
    var premiumExpiresAt: Date?

    // Associated user info (joined)
    var user: User?

    var displayName: String {
        user?.fullName ?? companyName ?? "Agent"
    }

    var avatarUrl: String? {
        user?.avatarUrl
    }

    var ratingFormatted: String {
        String(format: "%.1f", rating)
    }

    var starsArray: [Bool] {
        (1...5).map { Double($0) <= rating }
    }

    enum CodingKeys: String, CodingKey {
        case id, level, rating, bio, user
        case userId = "user_id"
        case companyName = "company_name"
        case licenseNumber = "license_number"
        case totalReviews = "total_reviews"
        case totalListings = "total_listings"
        case totalSales = "total_sales"
        case isPremium = "is_premium"
        case premiumExpiresAt = "premium_expires_at"
    }
}

// MARK: - Agent Update Request
struct AgentUpdateRequest: Codable {
    var companyName: String?
    var licenseNumber: String?
    var bio: String?

    enum CodingKeys: String, CodingKey {
        case companyName = "company_name"
        case licenseNumber = "license_number"
        case bio
    }
}
