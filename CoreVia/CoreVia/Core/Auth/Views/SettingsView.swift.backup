
import SwiftUI
import LocalAuthentication

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
                        .onChange(of: settings.notificationsEnabled) { _, newValue in
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
                        .onChange(of: settings.faceIDEnabled) { _, newValue in
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
                print("Biometric authentication failed: \(error ?? "Unknown error")")
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
                    .onChange(of: text) { _, newValue in
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
                            
                            FeatureRow(icon: "figure.strengthtraining.traditional", title: loc.localized("about_workout_tracking"), color: AppTheme.Colors.accent)
                            FeatureRow(icon: "fork.knife", title: loc.localized("about_food_tracking"), color: AppTheme.Colors.accent)
                            FeatureRow(icon: "person.2.fill", title: loc.localized("about_teacher_system"), color: AppTheme.Colors.accent)
                            FeatureRow(icon: "chart.bar.fill", title: loc.localized("about_statistics"), color: AppTheme.Colors.accent)
                            FeatureRow(icon: "bell.fill", title: loc.localized("about_reminders"), color: AppTheme.Colors.accent)
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

struct FeatureRow: View {
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

// MARK: - Premium View (2 Section Design)
struct PremiumView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var animateGradient = false
    @State private var heroScale: CGFloat = 0.5
    @State private var heroOpacity: Double = 0
    @State private var selectedPlan: PremiumPlan = .monthly
    @State private var buttonPressed = false
    @State private var featuresAppeared = false
    @State private var isActivating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showCancelAlert = false
    @State private var isCancelling = false

    enum PremiumPlan {
        case monthly, yearly
    }

    struct PremiumFeature: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let description: String
        let color: Color
    }

    var features: [PremiumFeature] {
        [
            PremiumFeature(icon: "sparkles", title: loc.localized("premium_feat_ai_calorie"), description: loc.localized("premium_feat_ai_calorie_desc"), color: AppTheme.Colors.accent),
            PremiumFeature(icon: "camera.fill", title: loc.localized("premium_feat_food_photo"), description: loc.localized("premium_feat_food_photo_desc"), color: AppTheme.Colors.accent),
            PremiumFeature(icon: "location.fill", title: loc.localized("premium_feat_gps"), description: loc.localized("premium_feat_gps_desc"), color: AppTheme.Colors.accent),
            PremiumFeature(icon: "person.2.fill", title: loc.localized("premium_feat_teachers"), description: loc.localized("premium_feat_teachers_desc"), color: AppTheme.Colors.accent),
            PremiumFeature(icon: "chart.bar.fill", title: loc.localized("premium_feat_stats"), description: loc.localized("premium_feat_stats_desc"), color: AppTheme.Colors.accent),
            PremiumFeature(icon: "bell.badge.fill", title: loc.localized("premium_feat_notifications"), description: loc.localized("premium_feat_notifications_desc"), color: AppTheme.Colors.accent)
        ]
    }

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: animateGradient
                    ? [Color(red: 0.05, green: 0.02, blue: 0.15), AppTheme.Colors.premiumGradientStart.opacity(0.4), Color(red: 0.02, green: 0.05, blue: 0.12)]
                    : [Color(red: 0.02, green: 0.05, blue: 0.12), AppTheme.Colors.premiumGradientEnd.opacity(0.3), Color(red: 0.05, green: 0.02, blue: 0.15)],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Close button
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .padding(.top, 12)

                    // Hero icon
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppTheme.Colors.premiumGradientStart.opacity(0.5), AppTheme.Colors.premiumGradientEnd.opacity(0.2), Color.clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 90
                                )
                            )
                            .frame(width: 180, height: 180)
                            .blur(radius: 25)

                        ZStack {
                            Image(systemName: settings.isPremium ? "crown.fill" : "shield.fill")
                                .font(.system(size: 65))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: settings.isPremium ? [AppTheme.Colors.starFilled, AppTheme.Colors.accent] : [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                            if !settings.isPremium {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                    .offset(y: -2)
                            }
                        }
                        .scaleEffect(heroScale)
                        .opacity(heroOpacity)
                        .shadow(color: settings.isPremium ? AppTheme.Colors.starFilled.opacity(0.6) : AppTheme.Colors.premiumGradientStart.opacity(0.6), radius: 25, x: 0, y: 10)
                    }
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            heroScale = 1.0
                            heroOpacity = 1.0
                        }
                    }

                    // Title
                    VStack(spacing: 8) {
                        Text("CoreVia")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(6)

                        Text(loc.localized("premium_title"))
                            .font(.system(size: 38, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: settings.isPremium ? [AppTheme.Colors.starFilled, AppTheme.Colors.accent, AppTheme.Colors.starFilled] : [.white, AppTheme.Colors.premiumGradientStart.opacity(0.8), .white],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        if settings.isPremium {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(AppTheme.Colors.success)
                                Text(loc.localized("premium_active"))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.success)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.Colors.success.opacity(0.15))
                            .cornerRadius(20)
                        } else {
                            Text(loc.localized("premium_all_unlocked"))
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    // ═══════════════════════════════
                    // SECTION 1: Premium Xususiyyetler
                    // ═══════════════════════════════
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.starFilled)
                            Text(loc.localized("premium_features_title"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        VStack(spacing: 2) {
                            ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                                PremiumFeatureRow(feature: feature, isActive: settings.isPremium)
                                    .opacity(featuresAppeared ? 1 : 0)
                                    .offset(x: featuresAppeared ? 0 : -30)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.8)
                                            .delay(Double(index) * 0.08),
                                        value: featuresAppeared
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.06))
                    )
                    .onAppear {
                        featuresAppeared = true
                    }

                    // ═══════════════════════════════════
                    // SECTION 2: Abunəlik / Premium Status
                    // ═══════════════════════════════════
                    if settings.isPremium {
                        // Premium aktiv — status + ləğv et
                        premiumActiveSection
                    } else {
                        premiumSubscribeSection
                    }

                    // Error mesaji
                    if showError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppTheme.Colors.error)
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.error)
                        }
                        .padding()
                        .background(AppTheme.Colors.error.opacity(0.15))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .alert(loc.localized("premium_cancel_title"), isPresented: $showCancelAlert) {
            Button(loc.localized("premium_cancel_no"), role: .cancel) { }
            Button(loc.localized("premium_cancel_yes"), role: .destructive) {
                cancelPremium()
            }
        } message: {
            Text(loc.localized("premium_cancel_message"))
        }
    }

    // MARK: - Premium Active Section
    private var premiumActiveSection: some View {
        VStack(spacing: 16) {
            // Status kartı
            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.success.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.Colors.starFilled)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(loc.localized("premium_user"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(loc.localized("premium_all_active"))
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.success)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.Colors.success)
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Aktiv xususiyyetler
                VStack(spacing: 8) {
                    premiumStatusRow(icon: "sparkles", title: loc.localized("premium_status_ai"), active: true)
                    premiumStatusRow(icon: "location.fill", title: loc.localized("premium_status_gps"), active: true)
                    premiumStatusRow(icon: "person.2.fill", title: loc.localized("premium_status_teachers"), active: true)
                    premiumStatusRow(icon: "chart.bar.fill", title: loc.localized("premium_status_stats"), active: true)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.Colors.success.opacity(0.3), lineWidth: 1)
            )

            // Ləğv et düyməsi
            Button {
                showCancelAlert = true
            } label: {
                HStack(spacing: 8) {
                    if isCancelling {
                        ProgressView()
                            .tint(AppTheme.Colors.error)
                    } else {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 16))
                    }
                    Text(loc.localized("premium_cancel"))
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(AppTheme.Colors.error.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.Colors.error.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.error.opacity(0.2), lineWidth: 1)
                )
            }
            .disabled(isCancelling)
        }
    }

    private func premiumStatusRow(icon: String, title: String, active: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.Colors.success)
        }
    }

    // MARK: - Premium Subscribe Section
    private var premiumSubscribeSection: some View {
        VStack(spacing: 16) {
            // Qiymət kartları
            HStack(spacing: 12) {
                PremiumPricingCard(
                    title: loc.localized("premium_monthly"),
                    price: "9.99",
                    period: loc.localized("premium_month"),
                    isSelected: selectedPlan == .monthly,
                    isPopular: false
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPlan = .monthly
                    }
                }

                PremiumPricingCard(
                    title: loc.localized("premium_yearly"),
                    price: "79.99",
                    period: loc.localized("premium_year"),
                    isSelected: selectedPlan == .yearly,
                    isPopular: true,
                    savings: loc.localized("premium_save_33")
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPlan = .yearly
                    }
                }
            }

            // Aktivləşdir düyməsi
            Button {
                withAnimation(.spring(response: 0.2)) {
                    buttonPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.2)) {
                        buttonPressed = false
                    }
                }
                activatePremium()
            } label: {
                HStack(spacing: 10) {
                    if isActivating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                    }
                    Text(loc.localized("premium_go_premium"))
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: AppTheme.Colors.premiumGradientStart.opacity(0.6), radius: 15, x: 0, y: 8)
            }
            .scaleEffect(buttonPressed ? 0.95 : 1.0)
            .disabled(isActivating)

            // Şərtlər
            VStack(spacing: 6) {
                Text(loc.localized("premium_can_cancel"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))

                Text(loc.localized("premium_appstore_payment"))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
            }
            .multilineTextAlignment(.center)
        }
    }

    // MARK: - Actions

    private func activatePremium() {
        isActivating = true
        showError = false

        Task {
            do {
                // Backend-e premium aktivləşdir sorgusu
                try await APIService.shared.requestVoid(
                    endpoint: "/api/v1/premium/activate",
                    method: "POST"
                )
            } catch {
                await MainActor.run {
                    isActivating = false
                    showError = true
                    errorMessage = (error as? APIError)?.errorDescription ?? loc.localized("premium_error")
                }
                return
            }

            // Token-ləri yenilə (is_premium claim)
            await AuthManager.shared.refreshTokenClaims()

            await MainActor.run {
                settings.isPremium = true
                isActivating = false
            }
        }
    }

    private func cancelPremium() {
        isCancelling = true

        Task {
            do {
                try await APIService.shared.requestVoid(
                    endpoint: "/api/v1/premium/cancel",
                    method: "POST"
                )
            } catch {
                print("Premium cancel xetasi: \(error)")
            }

            // Token-ləri yenilə
            await AuthManager.shared.refreshTokenClaims()

            await MainActor.run {
                settings.isPremium = false
                // Müəllim abunəliyini də ləğv et
                TrainerManager.shared.assignedTrainer = nil
                isCancelling = false
            }
        }
    }
}

// MARK: - Premium Feature Row (vertical list)
struct PremiumFeatureRow: View {
    let feature: PremiumView.PremiumFeature
    var isActive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.2))
                    .frame(width: 42, height: 42)

                Image(systemName: feature.icon)
                    .font(.system(size: 18))
                    .foregroundColor(feature.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(feature.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(1)
            }

            Spacer()

            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.success)
            } else {
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Premium Pricing Card
struct PremiumPricingCard: View {
    let title: String
    let price: String
    let period: String
    let isSelected: Bool
    let isPopular: Bool
    var savings: String? = nil

    var body: some View {
        VStack(spacing: 10) {
            if isPopular {
                Text(LocalizationManager.shared.localized("premium_most_popular"))
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(6)
            }

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(LocalizationManager.shared.localized("premium_currency"))
                    .font(.system(size: 14, weight: .semibold))
                Text(price)
                    .font(.system(size: 30, weight: .black))
                Text("/\(period)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .foregroundColor(.white)

            if let savings = savings {
                Text(savings)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.Colors.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected
                        ? LinearGradient(colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [.white.opacity(0.15), .white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

#Preview("Notifications") {
    NotificationsSettingsView()
}

#Preview("Security") {
    SecuritySettingsView()
}

#Preview("About") {
    AboutView()
}

#Preview("Premium") {
    PremiumView()
}
