import Foundation
import Combine

// MARK: - Auth State
enum AuthState {
    case unknown
    case unauthenticated
    case authenticated(User)
}

// MARK: - Auth Manager
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var authState: AuthState = .unknown
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared
    private let keychain = KeychainManager.shared

    private init() {
        checkAuthStatus()
    }

    // MARK: - Check Auth Status
    func checkAuthStatus() {
        if keychain.accessToken != nil {
            Task {
                await fetchCurrentUser()
            }
        } else {
            authState = .unauthenticated
        }
    }

    // MARK: - Send OTP
    func sendOTP(phone: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let body = OTPRequest(phone: phone)
        let _: [String: String] = try await api.request(
            endpoint: "/auth/send-otp",
            method: .POST,
            body: body,
            authenticated: false
        )
    }

    // MARK: - Verify OTP
    func verifyOTP(phone: String, code: String) async throws -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let body = OTPVerifyRequest(phone: phone, code: code)

        struct VerifyResponse: Codable {
            let verified: Bool
            let isNewUser: Bool

            enum CodingKeys: String, CodingKey {
                case verified
                case isNewUser = "is_new_user"
            }
        }

        let response: VerifyResponse = try await api.request(
            endpoint: "/auth/verify-otp",
            method: .POST,
            body: body,
            authenticated: false
        )

        return response.isNewUser
    }

    // MARK: - Register
    func register(phone: String, code: String, fullName: String, role: UserRole) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let body = RegisterRequest(
            phone: phone,
            code: code,
            fullName: fullName,
            role: role.rawValue
        )

        let response: AuthResponse = try await api.request(
            endpoint: "/auth/register",
            method: .POST,
            body: body,
            authenticated: false
        )

        handleAuthResponse(response)
    }

    // MARK: - Login
    func login(phone: String, code: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let body = LoginRequest(phone: phone, code: code)
        let response: AuthResponse = try await api.request(
            endpoint: "/auth/login",
            method: .POST,
            body: body,
            authenticated: false
        )

        handleAuthResponse(response)
    }

    // MARK: - Fetch Current User
    func fetchCurrentUser() async {
        do {
            let user: User = try await api.request(endpoint: "/users/me")
            currentUser = user
            authState = .authenticated(user)
        } catch {
            keychain.clearAll()
            authState = .unauthenticated
        }
    }

    // MARK: - Update Profile
    func updateProfile(_ request: ProfileUpdateRequest) async throws {
        isLoading = true
        defer { isLoading = false }

        let user: User = try await api.request(
            endpoint: "/users/me",
            method: .PUT,
            body: request
        )
        currentUser = user
        authState = .authenticated(user)
    }

    // MARK: - Logout
    func logout() {
        keychain.clearAll()
        currentUser = nil
        authState = .unauthenticated
    }

    // MARK: - Helper
    private func handleAuthResponse(_ response: AuthResponse) {
        keychain.accessToken = response.accessToken
        keychain.refreshToken = response.refreshToken
        keychain.userId = response.user.id
        currentUser = response.user
        authState = .authenticated(response.user)
    }
}
