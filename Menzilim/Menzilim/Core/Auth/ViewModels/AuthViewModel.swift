import SwiftUI
import Combine

// MARK: - Auth ViewModel
@MainActor
class AuthViewModel: ObservableObject {

    // MARK: - Published Properties

    // Login / Register fields
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""

    // Registration
    @Published var fullName: String = ""
    @Published var selectedRole: UserRole = .owner

    // State management
    @Published var isLoading: Bool = false
    @Published var error: String?

    // MARK: - Private
    private let authManager = AuthManager.shared

    // MARK: - Computed Properties

    /// Whether the email is valid
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    /// Whether the password is valid (min 6 chars)
    var isPasswordValid: Bool {
        return password.count >= 6
    }

    /// Whether passwords match
    var doPasswordsMatch: Bool {
        return password == confirmPassword && !confirmPassword.isEmpty
    }

    /// Whether the login form is valid
    var isLoginFormValid: Bool {
        return isEmailValid && isPasswordValid
    }

    /// Whether the registration form is valid
    var isRegisterFormValid: Bool {
        return !fullName.trimmingCharacters(in: .whitespaces).isEmpty
            && isEmailValid
            && isPasswordValid
            && doPasswordsMatch
    }

    // MARK: - Login

    func login() {
        guard isLoginFormValid else {
            error = "error".localized
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                try await authManager.login(
                    email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                    password: password
                )
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Register

    func register() {
        guard isRegisterFormValid else {
            error = "error".localized
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                try await authManager.register(
                    email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                    password: password,
                    fullName: fullName.trimmingCharacters(in: .whitespaces),
                    role: selectedRole
                )
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Reset

    func resetState() {
        error = nil
    }

    func resetToStart() {
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
        selectedRole = .owner
        isLoading = false
        error = nil
    }
}
