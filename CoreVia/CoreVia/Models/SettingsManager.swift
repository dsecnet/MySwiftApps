

import Foundation
import LocalAuthentication
import SwiftUI
import CryptoKit
import os.log

class SettingsManager: ObservableObject {
    
    static let shared = SettingsManager()
    
    // MARK: - Published Properties
    @Published var notificationsEnabled: Bool {
        didSet { saveSettings() }
    }
    
    @Published var workoutReminders: Bool {
        didSet { saveSettings() }
    }
    
    @Published var mealReminders: Bool {
        didSet { saveSettings() }
    }
    
    @Published var weeklyReports: Bool {
        didSet { saveSettings() }
    }
    
    @Published var faceIDEnabled: Bool {
        didSet { saveSettings() }
    }
    
    @Published var hasAppPassword: Bool {
        didSet { saveSettings() }
    }
    
    @Published var isPremium: Bool {
        didSet { saveSettings() }
    }

    // Computed property: Trainers automatically have premium access
    var hasPremiumAccess: Bool {
        // Check if user is trainer (from Keychain - BUG-C06 fix)
        if KeychainManager.shared.userType == "trainer" {
            return true
        }
        // Otherwise check premium status
        return isPremium
    }

    private let settingsKey = "app_settings"
    private let passwordKey = "app_password"
    
    init() {
        // Load saved settings
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.notificationsEnabled = settings.notificationsEnabled
            self.workoutReminders = settings.workoutReminders
            self.mealReminders = settings.mealReminders
            self.weeklyReports = settings.weeklyReports
            self.faceIDEnabled = settings.faceIDEnabled
            self.hasAppPassword = settings.hasAppPassword
            self.isPremium = settings.isPremium
        } else {
            // Default values
            self.notificationsEnabled = true
            self.workoutReminders = true
            self.mealReminders = true
            self.weeklyReports = false
            self.faceIDEnabled = false
            self.hasAppPassword = false
            self.isPremium = false
        }
    }
    
    // MARK: - Save Settings
    private func saveSettings() {
        let settings = AppSettings(
            notificationsEnabled: notificationsEnabled,
            workoutReminders: workoutReminders,
            mealReminders: mealReminders,
            weeklyReports: weeklyReports,
            faceIDEnabled: faceIDEnabled,
            hasAppPassword: hasAppPassword,
            isPremium: isPremium
        )
        
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    // MARK: - Password Management
    func setPassword(_ password: String) {
        // Hash the PIN before storing in Keychain
        let hashedPin = hashPin(password)
        KeychainManager.shared.save(key: "app_pin_hash", value: hashedPin)
        hasAppPassword = true
        saveSettings()
        AppLogger.general.debug("Shifre teyin edildi")
    }

    func removePassword() {
        KeychainManager.shared.delete(key: "app_pin_hash")
        UserDefaults.standard.removeObject(forKey: "app_password") // cleanup old
        hasAppPassword = false
        saveSettings()
    }

    func verifyPassword(_ password: String) -> Bool {
        // BUG-C09 fix: Auto-migrate legacy plaintext password from UserDefaults at startup
        migrateLegacyPasswordIfNeeded()

        guard let savedHash = KeychainManager.shared.load(key: "app_pin_hash") else {
            return false
        }
        return hashPin(password) == savedHash
    }

    /// Legacy plaintext password-u Keychain-ə miqrasiya et və sil (BUG-C09)
    private func migrateLegacyPasswordIfNeeded() {
        if let oldPassword = UserDefaults.standard.string(forKey: "app_password") {
            let hashedPin = hashPin(oldPassword)
            KeychainManager.shared.save(key: "app_pin_hash", value: hashedPin)
            UserDefaults.standard.removeObject(forKey: "app_password")
        }
    }

    private func hashPin(_ pin: String) -> String {
        let data = Data(pin.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Face ID / Touch ID
    func authenticateWithBiometrics(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let message = error?.localizedDescription ?? "Biometric authentication not available"
            completion(false, message)
            return
        }
        
        let reason = LocalizationManager.shared.localized("biometric_reason")
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    let message = error?.localizedDescription ?? "Authentication failed"
                    completion(false, message)
                }
            }
        }
    }
    
    func getBiometricType() -> String {
        let loc = LocalizationManager.shared
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return loc.localized("biometric_unavailable")
        }

        switch context.biometryType {
        case .faceID:
            return loc.localized("biometric_faceid")
        case .touchID:
            return loc.localized("biometric_touchid")
        case .opticID:
            return loc.localized("biometric_opticid")
        case .none:
            return loc.localized("biometric_unavailable")
        @unknown default:
            return loc.localized("biometric_generic")
        }
    }
    
    // MARK: - Request Notification Permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}

// MARK: - App Settings Model
struct AppSettings: Codable {
    var notificationsEnabled: Bool
    var workoutReminders: Bool
    var mealReminders: Bool
    var weeklyReports: Bool
    var faceIDEnabled: Bool
    var hasAppPassword: Bool
    var isPremium: Bool
}
