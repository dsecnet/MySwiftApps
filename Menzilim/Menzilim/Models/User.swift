import Foundation

// MARK: - User Role
enum UserRole: String, Codable, CaseIterable {
    case owner
    case agent
    case user
    case admin

    var displayKey: String {
        switch self {
        case .owner: return "role_owner"
        case .agent: return "role_agent"
        case .user: return "role_owner"
        case .admin: return "Admin"
        }
    }
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    var email: String
    var fullName: String
    var avatarUrl: String?
    var role: UserRole
    var isVerified: Bool
    var createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, email, role
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case isVerified = "is_verified"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Auth Models
struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let fullName: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case email, password, role
        case fullName = "full_name"
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct TokenRefreshRequest: Codable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct TokenRefreshResponse: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - Profile Update
struct ProfileUpdateRequest: Codable {
    var fullName: String?
    var email: String?
    var avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case email
        case avatarUrl = "avatar_url"
    }
}
