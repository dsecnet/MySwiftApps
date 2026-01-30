

import Foundation
import LocalAuthentication
import SwiftUI

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
        UserDefaults.standard.set(password, forKey: passwordKey)
        hasAppPassword = true
        print("✅ Şifrə təyin edildi")
    }
    
    func removePassword() {
        UserDefaults.standard.removeObject(forKey: passwordKey)
        hasAppPassword = false
        print("🗑️ Şifrə silindi")
    }
    
    func verifyPassword(_ password: String) -> Bool {
        guard let savedPassword = UserDefaults.standard.string(forKey: passwordKey) else {
            return false
        }
        return password == savedPassword
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
        
        let reason = "CoreVia tətbiqinə daxil olmaq üçün"
        
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
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Mövcud deyil"
        }
        
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "Mövcud deyil"
        @unknown default:
            return "Biometrik"
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
