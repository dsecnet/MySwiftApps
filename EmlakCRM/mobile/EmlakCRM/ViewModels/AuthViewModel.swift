//
//  AuthViewModel.swift
//  EmlakCRM
//
//  Authentication ViewModel
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        // Check if token exists
        if UserDefaults.standard.string(forKey: "access_token") != nil {
            Task {
                do {
                    currentUser = try await apiService.getCurrentUser()
                    isAuthenticated = true
                } catch {
                    // Token invalid, logout
                    logout()
                }
            }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.login(email: email, password: password)
            currentUser = try await apiService.getCurrentUser()
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func register(name: String, email: String, phone: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.register(
                name: name,
                email: email,
                phone: phone,
                password: password
            )
            currentUser = try await apiService.getCurrentUser()
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func logout() {
        apiService.logout()
        isAuthenticated = false
        currentUser = nil
    }
}
