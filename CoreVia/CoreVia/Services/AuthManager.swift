import Foundation
import SwiftUI
import os.log

// MARK: - Auth Request/Response Models

struct LoginRequest: Encodable {
    let email: String
    let password: String
    let user_type: String
}

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let user_type: String
    let otp_code: String
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

struct DeleteAccountBody: Encodable {
    let password: String
}

// MARK: - OTP Response
struct OTPResponse: Codable {
    let success: Bool
    let message: String
    let code: String?
}

// MARK: - Auth Manager

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: UserResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

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
        isLoggedIn = keychain.isLoggedIn
        if isLoggedIn {
            Task { await fetchCurrentUser() }
        }
    }

    // MARK: - Login Step 1: Email + Password → OTP gonder
    // Backend /login OTPResponse qaytarir (2FA aktiv).
    // LoginView bu metodu cagirip OTP screeni gostermeli.
    @MainActor
    func requestLoginOTP(email: String, password: String, userType: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let _: OTPResponse = try await api.request(
                endpoint: "/api/v1/auth/login",
                method: "POST",
                body: LoginRequest(email: email, password: password, user_type: userType),
                requiresAuth: false
            )
            isLoading = false
            return true
        } catch let error as APIError {
            // SECURITY: Log only error type, never log email/password
            AppLogger.auth.error("Login step1 failed: \(error.errorDescription ?? "unknown")")
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            AppLogger.auth.error("Login step1 unexpected error")
            errorMessage = "Gozlenilmez xeta"
            isLoading = false
            return false
        }
    }

    // MARK: - Login Step 2: OTP verify → JWT token al
    @MainActor
    func verifyLoginOTP(email: String, otpCode: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        struct VerifyBody: Encodable {
            let email: String
            let otp_code: String
        }

        do {
            let response: AuthResponse = try await api.request(
                endpoint: "/api/v1/auth/login-verify",
                method: "POST",
                body: VerifyBody(email: email, otp_code: otpCode),
                requiresAuth: false
            )

            keychain.accessToken = response.accessToken
            keychain.refreshToken = response.refreshToken
            isLoggedIn = true

            await fetchCurrentUser()

            isLoading = false
            return true
        } catch let error as APIError {
            AppLogger.auth.error("Login step2 OTP verify failed")
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            AppLogger.auth.error("Login step2 unexpected error")
            errorMessage = "Gozlenilmez xeta"
            isLoading = false
            return false
        }
    }

    // MARK: - Register (OTP verify ile)
    // otpCode: client ucun teleb olunur.
    // Trainer ucun backend OTP olmadan qebul edir (backend-de duzeldilecek).
    // Qeydiyyatdan sonra auto-login EDILMIR — 2FA teleb olundugu ucun.
    @MainActor
    func register(name: String, email: String, password: String, userType: String, otpCode: String = "") async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let _: UserResponse = try await api.request(
                endpoint: "/api/v1/auth/register",
                method: "POST",
                body: RegisterRequest(name: name, email: email, password: password,
                                     user_type: userType, otp_code: otpCode),
                requiresAuth: false
            )
            // Qeydiyyat ugurlu. Auto-login yoxdur — 2FA ucun user ozü login olmali.
            isLoading = false
            return true
        } catch let error as APIError {
            AppLogger.auth.error("Register failed")
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            AppLogger.auth.error("Register unexpected error")
            errorMessage = "Gozlenilmez xeta"
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

            keychain.userType = user.userType
            keychain.userId = user.id

            SettingsManager.shared.isPremium = user.isPremium
        } catch {
            // SECURITY: Log only error type, never log user details
            AppLogger.auth.error("fetchCurrentUser failed")
            if case APIError.unauthorized = error {
                logout()
            }
        }
    }

    // MARK: - Refresh Token Claims
    @MainActor
    func refreshTokenClaims() async {
        do {
            let response: AuthResponse = try await api.request(
                endpoint: "/api/v1/auth/refresh-claims",
                method: "POST"
            )
            keychain.accessToken = response.accessToken
            keychain.refreshToken = response.refreshToken
            await fetchCurrentUser()
        } catch {
            AppLogger.auth.error("Token claims refresh failed")
        }
    }

    // MARK: - Premium Status (Guvenilib)
    // Hemise bu deyeri istifade et. Backend-den gelir, manipulyasiya mumkun deyil.
    var isPremium: Bool {
        currentUser?.isPremium ?? false
    }

    // MARK: - JWT Premium Hint (ETIBARSIZ - yalniz UI skeleton ucun)
    // XEBERDARLIK: JWT imzasi client-side yoxlanila bilmez.
    // Istifadeci payload-i deyisdire biler. He bir vaxt premium kilidin acmaq ucun
    // bu deyere guvenmе — hemise isPremium istifade et.
    @available(*, deprecated, message: "Premium qerarlar ucun isPremium istifade et")
    var isPremiumFromToken: Bool {
        guard let token = keychain.accessToken else { return false }
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return false }
        var base64 = String(segments[1])
        while base64.count % 4 != 0 { base64.append("=") }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let val = json["is_premium"] as? Bool else { return false }
        return val
    }

    // MARK: - Delete Account
    @MainActor
    func deleteAccount(password: String) async -> (success: Bool, error: String?) {
        do {
            try await api.requestVoid(
                endpoint: "/api/v1/auth/delete-account",
                method: "DELETE",
                body: DeleteAccountBody(password: password)
            )
            logout()
            return (true, nil)
        } catch let error as APIError {
            AppLogger.auth.error("Delete account failed")
            return (false, error.errorDescription)
        } catch {
            AppLogger.auth.error("Delete account unexpected error")
            return (false, error.localizedDescription)
        }
    }

    // MARK: - Logout
    @MainActor
    func logout() {
        keychain.clearTokens()
        isLoggedIn = false
        currentUser = nil
        UserProfileManager.shared.userProfile = UserProfileManager.defaultClientProfile
        SettingsManager.shared.isPremium = false
        TrainingPlanManager.shared.clearAllPlans()
        MealPlanManager.shared.clearAllPlans()
        OnboardingManager.shared.resetOnLogout()
    }
}
