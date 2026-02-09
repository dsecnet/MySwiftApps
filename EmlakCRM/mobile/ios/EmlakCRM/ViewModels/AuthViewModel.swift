import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        isAuthenticated = UserDefaults.standard.string(forKey: "accessToken") != nil
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIService.shared.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register(email: String, password: String, fullName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await APIService.shared.register(email: email, password: password, fullName: fullName)
            // After registration, login automatically
            await login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() {
        APIService.shared.logout()
        currentUser = nil
        isAuthenticated = false
    }
}
