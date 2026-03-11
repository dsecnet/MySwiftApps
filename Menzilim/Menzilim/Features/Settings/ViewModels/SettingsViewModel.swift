import SwiftUI
import Combine

// MARK: - Settings ViewModel
@MainActor
class SettingsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isDarkMode: Bool = true
    @Published var selectedCurrency: Currency = .AZN
    @Published var notificationsEnabled: Bool = true
    @Published var isShowingLanguagePicker: Bool = false
    @Published var isShowingLogoutAlert: Bool = false
    @Published var isShowingProfileEdit: Bool = false

    // MARK: - Language
    @Published var currentLanguage: AppLanguage

    // MARK: - App Version
    let appVersion = "1.0.0"
    let buildNumber = "24"

    // MARK: - Current User (from AuthManager)
    var currentUser: User {
        AuthManager.shared.currentUser ?? User(
            id: "",
            email: "",
            fullName: "",
            avatarUrl: nil,
            role: .owner,
            isVerified: false,
            createdAt: nil,
            updatedAt: nil
        )
    }

    // MARK: - Init
    init() {
        self.currentLanguage = LocalizationManager.shared.currentLanguage
    }

    // MARK: - Actions
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        LocalizationManager.shared.setLanguage(language)
    }

    func toggleDarkMode() {
        isDarkMode.toggle()
    }

    func setCurrency(_ currency: Currency) {
        selectedCurrency = currency
    }

    func logout() {
        AuthManager.shared.logout()
    }

    func updateProfile(fullName: String, email: String) {
        Task {
            let request = ProfileUpdateRequest(fullName: fullName, email: email)
            try? await AuthManager.shared.updateProfile(request)
        }
    }
}
