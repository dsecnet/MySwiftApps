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

    // MARK: - Register
    func register(email: String, password: String, fullName: String, role: UserRole) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let body = RegisterRequest(
            email: email,
            password: password,
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
    func login(email: String, password: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let body = LoginRequest(email: email, password: password)
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
