import Foundation
import SwiftUI

// MARK: - Auth Request/Response Models

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let userType: String

    enum CodingKeys: String, CodingKey {
        case name, email, password
        case userType = "user_type"
    }
}

struct UserResponse: Codable {
    let id: String
    let name: String
    let email: String
    let userType: String
    let profileImageUrl: String?
    let isActive: Bool
    let isPremium: Bool
    let createdAt: String
    let age: Int?
    let weight: Double?
    let height: Double?
    let goal: String?
    let trainerId: String?
    let specialization: String?
    let experience: Int?
    let rating: Double?
    let pricePerSession: Double?
    let bio: String?
    let verificationStatus: String?
    let instagramHandle: String?
    let verificationPhotoUrl: String?
    let verificationScore: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case userType = "user_type"
        case profileImageUrl = "profile_image_url"
        case isActive = "is_active"
        case isPremium = "is_premium"
        case createdAt = "created_at"
        case age, weight, height, goal
        case trainerId = "trainer_id"
        case specialization, experience, rating
        case pricePerSession = "price_per_session"
        case bio
        case verificationStatus = "verification_status"
        case instagramHandle = "instagram_handle"
        case verificationPhotoUrl = "verification_photo_url"
        case verificationScore = "verification_score"
    }
}

// MARK: - Auth Manager

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: UserResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // JWT Tokens (for direct API calls)
    var accessToken: String? {
        get { keychain.accessToken }
        set { keychain.accessToken = newValue }
    }

    var refreshToken: String? {
        get { keychain.refreshToken }
        set { keychain.refreshToken = newValue }
    }

    private let api = APIService.shared
    private let keychain = KeychainManager.shared

    private init() {
        // App açılanda token varsa login olub yoxla
        isLoggedIn = keychain.isLoggedIn
        if isLoggedIn {
            Task { await fetchCurrentUser() }
        }
    }

    // MARK: - Login

    @MainActor
    func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let response: AuthResponse = try await api.request(
                endpoint: "/api/v1/auth/login",
                method: "POST",
                body: LoginRequest(email: email, password: password),
                requiresAuth: false
            )

            keychain.accessToken = response.accessToken
            keychain.refreshToken = response.refreshToken
            isLoggedIn = true

            await fetchCurrentUser()

            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Gözlənilməz xəta: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    // MARK: - Register

    @MainActor
    func register(name: String, email: String, password: String, userType: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let _: UserResponse = try await api.request(
                endpoint: "/api/v1/auth/register",
                method: "POST",
                body: RegisterRequest(name: name, email: email, password: password, userType: userType),
                requiresAuth: false
            )

            // Qeydiyyat uğurlu - indi login et
            return await login(email: email, password: password)
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Gözlənilməz xəta: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    // MARK: - Fetch Current User

    @MainActor
    func fetchCurrentUser() async {
        do {
            let user: UserResponse = try await api.request(endpoint: "/api/v1/auth/me")
            currentUser = user

            // ProfileManager-i yenilə
            let profileType: UserProfileType = user.userType == "trainer" ? .trainer : .client
            let profile = UserProfile(
                name: user.name,
                email: user.email,
                userType: profileType,
                age: user.age,
                weight: user.weight,
                height: user.height,
                goal: user.goal,
                specialty: user.specialization,
                experience: user.experience,
                bio: user.bio,
                rating: user.rating
            )
            UserProfileManager.shared.userProfile = profile

            // Save userType to UserDefaults for premium access check
            UserDefaults.standard.set(user.userType, forKey: "userType")

            // Premium statusu yenilə
            SettingsManager.shared.isPremium = user.isPremium
        } catch {
            // Token keçərsizdirsə logout et
            if case APIError.unauthorized = error {
                logout()
            }
        }
    }

    // MARK: - Refresh Token Claims (premium deyisdikden sonra)

    @MainActor
    func refreshTokenClaims() async {
        do {
            let response: AuthResponse = try await api.request(
                endpoint: "/api/v1/auth/refresh-claims",
                method: "POST"
            )
            keychain.accessToken = response.accessToken
            keychain.refreshToken = response.refreshToken

            // User melumatlarini yenile (isPremium sync)
            await fetchCurrentUser()
        } catch {
            print("Token claims refresh ugursuz: \(error)")
        }
    }

    // MARK: - JWT Premium Check (optimistik)

    var isPremiumFromToken: Bool {
        guard let token = keychain.accessToken else { return false }
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return false }

        var base64 = String(segments[1])
        while base64.count % 4 != 0 { base64.append("=") }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let isPremium = json["is_premium"] as? Bool else {
            return false
        }
        return isPremium
    }

    // MARK: - Logout

    @MainActor
    func logout() {
        keychain.clearTokens()
        isLoggedIn = false
        currentUser = nil

        // Clear userType from UserDefaults
        UserDefaults.standard.removeObject(forKey: "userType")
    }
}
