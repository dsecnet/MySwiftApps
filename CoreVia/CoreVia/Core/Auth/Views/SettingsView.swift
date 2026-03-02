
import SwiftUI
import LocalAuthentication
import os.log

// MARK: - Notifications Settings View
struct NotificationsSettingsView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    @State private var showPermissionAlert = false
    private let loc = LocalizationManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                List {
                    Section {
                        Toggle(isOn: $settings.notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text(loc.localized("settings_notifications"))
                            }
                        }
                        .onChange(of: settings.notificationsEnabled) { newValue in
                            if newValue {
                                settings.requestNotificationPermission { granted in
                                    if !granted {
                                        showPermissionAlert = true
                                        settings.notificationsEnabled = false
                                    }
                                }
                            }
                        }
                    } header: {
                        Text(loc.localized("settings_general"))
                    }
                    
                    Section {
                        Toggle(isOn: $settings.workoutReminders) {
                            HStack {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text(loc.localized("settings_workout_reminders"))
                            }
                        }
                        .disabled(!settings.notificationsEnabled)
                        
                        Toggle(isOn: $settings.mealReminders) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text(loc.localized("settings_meal_reminders"))
                            }
                        }
                        .disabled(!settings.notificationsEnabled)
                        
                        Toggle(isOn: $settings.weeklyReports) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(AppTheme.Colors.accent)
                                Text(loc.localized("settings_weekly_report"))
                            }
                        }
                        .disabled(!settings.notificationsEnabled)
                    } header: {
                        Text(loc.localized("settings_reminders"))
                    } footer: {
                        Text(loc.localized("settings_reminder_desc"))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(loc.localized("settings_notifications"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_close")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .alert(loc.localized("settings_permission_required"), isPresented: $showPermissionAlert) {
                Button(loc.localized("settings_open_settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(loc.localized("common_cancel"), role: .cancel) { }
            } message: {
                Text(loc.localized("settings_permission_desc"))
            }
        }
    }
}

// MARK: - Security Settings View
struct SecuritySettingsView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    @State private var showPasswordSheet = false
    @State private var showRemovePasswordAlert = false
    private let loc = LocalizationManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                List {
                    Section {
                        Toggle(isOn: $settings.faceIDEnabled) {
                            HStack {
                                Image(systemName: "faceid")
                                    .foregroundColor(AppTheme.Colors.accent)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(settings.getBiometricType())
                                    Text(loc.localized("settings_quick_login"))
                                        .font(.caption)
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                }
                            }
                        }
                        .onChange(of: settings.faceIDEnabled) { newValue in
                            if newValue {
                                testBiometric()
                            }
                        }
                    } header: {
                        Text(loc.localized("settings_biometric"))
                    } footer: {
                        Text(loc.localized("settings_biometric_desc").replacingOccurrences(of: "%@", with: settings.getBiometricType()))
                    }
                    
                    Section {
                        if settings.hasAppPassword {
                            Button {
                                showPasswordSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "key.fill")
                                        .foregroundColor(AppTheme.Colors.accent)
                                    Text(loc.localized("settings_change_password"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                        .font(.caption)
                                }
                            }
                            
                            Button(role: .destructive) {
                                showRemovePasswordAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text(loc.localized("settings_remove_password"))
                                }
                            }
                        } else {
                            Button {
                                showPasswordSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(AppTheme.Colors.accent)
                                    Text(loc.localized("settings_set_password"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                        .font(.caption)
                                }
                            }
                        }
                    } header: {
                        Text(loc.localized("settings_password_section"))
                    } footer: {
                        Text(loc.localized("settings_4digit_desc"))
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(AppTheme.Colors.accent)
                            Text(loc.localized("settings_2fa"))
                            Spacer()
                            Text(loc.localized("settings_coming_soon"))
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    } header: {
                        Text(loc.localized("settings_extra_security"))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(loc.localized("settings_security"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_close")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .sheet(isPresented: $showPasswordSheet) {
                SetPasswordView()
            }
            .alert(loc.localized("settings_remove_password"), isPresented: $showRemovePasswordAlert) {
                Button(loc.localized("common_delete"), role: .destructive) {
                    settings.removePassword()
                }
                Button(loc.localized("common_cancel"), role: .cancel) { }
            } message: {
                Text(loc.localized("settings_remove_password_confirm"))
            }
        }
    }
    
    private func testBiometric() {
        settings.authenticateWithBiometrics { success, error in
            if !success {
                settings.faceIDEnabled = false
                AppLogger.auth.error("Biometric authentication failed: \(error ?? "Unknown error")")
            }
        }
    }
}

// MARK: - Set Password View
struct SetPasswordView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    private let loc = LocalizationManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.accent)
                        
                        Text(settings.hasAppPassword ? loc.localized("settings_change_password") : loc.localized("settings_set_password"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        
                        Text(loc.localized("settings_4digit"))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    
                    VStack(spacing: 20) {
                        PinCodeField(text: $password, title: loc.localized("common_password"))
                        PinCodeField(text: $confirmPassword, title: loc.localized("settings_password_repeat"))
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(AppTheme.Colors.error)
                            .font(.caption)
                    }
                    
                    Button {
                        savePassword()
                    } label: {
                        Text(loc.localized("common_save"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.accent)
                            .cornerRadius(12)
                    }
                    .disabled(password.count != 4 || confirmPassword.count != 4)
                    .opacity(password.count == 4 && confirmPassword.count == 4 ? 1.0 : 0.5)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_cancel")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
    }

    private func savePassword() {
        guard password.count == 4 else {
            showErrorMessage(loc.localized("settings_password_4digits"))
            return
        }

        guard password == confirmPassword else {
            showErrorMessage(loc.localized("settings_passwords_mismatch"))
            return
        }
        
        settings.setPassword(password)
        dismiss()
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showError = false
        }
    }
}

struct PinCodeField: View {
    @Binding var text: String
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 12) {
                ForEach(0..<4) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.Colors.secondaryBackground)
                            .frame(width: 60, height: 60)
                        
                        if text.count > index {
                            Circle()
                                .fill(AppTheme.Colors.accent)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
            .overlay(
                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .foregroundColor(.clear)
                    .accentColor(.clear)
                    .onChange(of: text) { newValue in
                        if newValue.count > 4 {
                            text = String(newValue.prefix(4))
                        }
                    }
            )
        }
    }
}

// MARK: - About View
struct AboutView: View {

    @Environment(\.dismiss) var dismiss
    private let loc = LocalizationManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.Colors.accent.opacity(0.3), AppTheme.Colors.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)

                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 20)
                            
                            VStack(spacing: 6) {
                                Text("CoreVia")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                
                                Text(loc.localized("about_slogan"))
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                
                                Text(loc.localized("about_version"))
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.tertiaryText)
                            }
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text(loc.localized("about_title"))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            Text(loc.localized("about_description"))
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(16)
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            Text(loc.localized("about_features"))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            AboutFeatureRow(icon: "figure.strengthtraining.traditional", title: loc.localized("about_workout_tracking"), color: AppTheme.Colors.accent)
                            AboutFeatureRow(icon: "fork.knife", title: loc.localized("about_food_tracking"), color: AppTheme.Colors.accent)
                            AboutFeatureRow(icon: "person.2.fill", title: loc.localized("about_teacher_system"), color: AppTheme.Colors.accent)
                            AboutFeatureRow(icon: "chart.bar.fill", title: loc.localized("about_statistics"), color: AppTheme.Colors.accent)
                            AboutFeatureRow(icon: "bell.fill", title: loc.localized("about_reminders"), color: AppTheme.Colors.accent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(16)
                        
                        // Links
                        VStack(spacing: 12) {
                            AboutLinkButton(icon: "globe", title: loc.localized("about_website"), url: "https://corevia.com")
                            AboutLinkButton(icon: "envelope.fill", title: loc.localized("about_contact"), url: "mailto:support@corevia.com")
                            AboutLinkButton(icon: "doc.text.fill", title: loc.localized("about_terms"), url: "https://corevia.com/terms")
                            AboutLinkButton(icon: "hand.raised.fill", title: loc.localized("about_privacy"), url: "https://corevia.com/privacy")
                        }
                        
                        // Copyright
                        VStack(spacing: 4) {
                            Text("© 2026 CoreVia")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                            
                            Text(loc.localized("about_made_with_love"))
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("about_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_close")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
    }
}

struct AboutFeatureRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)

            Text(title)
                .foregroundColor(AppTheme.Colors.primaryText)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.Colors.success)
        }
    }
}

struct AboutLinkButton: View {
    let icon: String
    let title: String
    let url: String
    
    var body: some View {
        Button {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.accent)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .font(.caption)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Delete Account Sheet
struct DeleteAccountSheet: View {
    @Binding var password: String
    @Binding var error: String?
    @Binding var isDeleting: Bool
    let onConfirm: () -> Void

    @Environment(\.dismiss) var dismiss
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Warning icon
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.error.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.Colors.error)
                        }

                        Text(loc.localized("delete_account_title"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(loc.localized("delete_account_confirm_desc"))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("delete_account_password"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        SecureField(loc.localized("delete_account_password_placeholder"), text: $password)
                            .padding()
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(error != nil ? AppTheme.Colors.error : AppTheme.Colors.separator, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)

                    // Error message
                    if let error = error {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                            Text(error)
                                .font(.system(size: 13))
                        }
                        .foregroundColor(AppTheme.Colors.error)
                        .padding(.horizontal)
                    }

                    // Delete button
                    Button {
                        onConfirm()
                    } label: {
                        HStack {
                            if isDeleting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "trash.fill")
                                Text(loc.localized("delete_account_confirm"))
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(password.count >= 6 ? AppTheme.Colors.error : AppTheme.Colors.separator)
                        .cornerRadius(12)
                    }
                    .disabled(password.count < 6 || isDeleting)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) {
                        password = ""
                        error = nil
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
    }
}

// #Preview("Notifications") { // iOS 17+ only
//     NotificationsSettingsView()
// }
//
// #Preview("Security") { // iOS 17+ only
//     SecuritySettingsView()
// }
//
// #Preview("About") { // iOS 17+ only
//     AboutView()
// }
//
