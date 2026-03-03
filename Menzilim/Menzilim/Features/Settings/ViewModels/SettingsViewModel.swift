import SwiftUI
import Combine

// MARK: - Settings ViewModel
@MainActor
class SettingsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var currentUser: User
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

    // MARK: - Init
    init() {
        self.currentUser = User(
            id: "user_001",
            phone: "+994 50 123 45 67",
            email: "elvin.mammadov@gmail.com",
            fullName: "Elvin Məmmədov",
            avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
            role: .user,
            isVerified: true,
            createdAt: nil,
            updatedAt: nil
        )
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
        // Handle logout logic
    }

    func updateProfile(fullName: String, email: String?) {
        currentUser = User(
            id: currentUser.id,
            phone: currentUser.phone,
            email: email,
            fullName: fullName,
            avatarUrl: currentUser.avatarUrl,
            role: currentUser.role,
            isVerified: currentUser.isVerified,
            createdAt: currentUser.createdAt,
            updatedAt: Date()
        )
    }
}
