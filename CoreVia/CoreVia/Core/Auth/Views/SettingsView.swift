
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
                                    .foregroundColor(.red)
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
                                    .foregroundColor(.orange)
                                Text(loc.localized("settings_workout_reminders"))
                            }
                        }
                        .disabled(!settings.notificationsEnabled)
                        
                        Toggle(isOn: $settings.mealReminders) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.green)
                                Text(loc.localized("settings_meal_reminders"))
                            }
                        }
                        .disabled(!settings.notificationsEnabled)
                        
                        Toggle(isOn: $settings.weeklyReports) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.blue)
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
                    .foregroundColor(.red)
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
                                    .foregroundColor(.blue)
                                
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
                                        .foregroundColor(.orange)
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
                                        .foregroundColor(.green)
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
                                .foregroundColor(.purple)
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
                    .foregroundColor(.red)
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
                            .foregroundColor(.blue)
                        
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
                            .foregroundColor(.red)
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
                            .background(Color.blue)
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
                    .foregroundColor(.red)
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
                                .fill(Color.blue)
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
                        
                        // App Icon & Version
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.red.opacity(0.3), Color.red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Color.red.opacity(0.3), radius: 20)
                            
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
                            
                            FeatureRow(icon: "figure.strengthtraining.traditional", title: loc.localized("about_workout_tracking"), color: .red)
                            FeatureRow(icon: "fork.knife", title: loc.localized("about_food_tracking"), color: .green)
                            FeatureRow(icon: "person.2.fill", title: loc.localized("about_teacher_system"), color: .purple)
                            FeatureRow(icon: "chart.bar.fill", title: loc.localized("about_statistics"), color: .blue)
                            FeatureRow(icon: "bell.fill", title: loc.localized("about_reminders"), color: .orange)
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
                            
                            Text("Made with ❤️ in Azerbaijan")
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
                    .foregroundColor(.red)
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
                .foregroundColor(.green)
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
                    .foregroundColor(.red)
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

// MARK: - Premium View (Modern Paywall)
struct PremiumView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    @State private var animateGradient = false
    @State private var heroScale: CGFloat = 0.5
    @State private var heroOpacity: Double = 0
    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var buttonPressed = false
    @State private var featuresAppeared = false
    private let loc = LocalizationManager.shared

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
            PremiumFeature(icon: "sparkles", title: "AI Kalori Analizi", description: "Sekil cekin, kalori avtomatik hesablansin", color: .pink),
            PremiumFeature(icon: "camera.fill", title: "Sekil ile qida analizi", description: "AI ile qida tanimasi ve besin deyerleri", color: .red),
            PremiumFeature(icon: "chart.bar.fill", title: "Detalli statistika", description: "Heftelik ve ayliq inkisaf hesabatlari", color: .blue),
            PremiumFeature(icon: "cloud.fill", title: "Bulud yedekleme", description: "Butun melumatlar avtomatik saxlanilir", color: .cyan),
            PremiumFeature(icon: "person.2.fill", title: "Muellim sistemi", description: "Professional muellimlere qosulun", color: .purple),
            PremiumFeature(icon: "bell.badge.fill", title: "Agilli bildirisler", description: "Yemek ve idman xatirlatmalari", color: .orange)
        ]
    }

    var body: some View {
        ZStack {
            // Animated gradient background - indigo/teal
            LinearGradient(
                colors: animateGradient
                    ? [Color(red: 0.05, green: 0.02, blue: 0.15), Color.indigo.opacity(0.4), Color(red: 0.02, green: 0.05, blue: 0.12)]
                    : [Color(red: 0.02, green: 0.05, blue: 0.12), Color.teal.opacity(0.3), Color(red: 0.05, green: 0.02, blue: 0.15)],
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
                        // Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.indigo.opacity(0.5), Color.teal.opacity(0.2), Color.clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 90
                                )
                            )
                            .frame(width: 180, height: 180)
                            .blur(radius: 25)

                        // Shield + sparkles
                        ZStack {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 65))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.indigo, .purple],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                            Image(systemName: "sparkles")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .offset(y: -2)
                        }
                        .scaleEffect(heroScale)
                        .opacity(heroOpacity)
                        .shadow(color: .indigo.opacity(0.6), radius: 25, x: 0, y: 10)
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

                        Text("PREMIUM")
                            .font(.system(size: 38, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .indigo.opacity(0.8), .white],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Butun imkanlari acin, limitler olmadan")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    // Feature list - vertical
                    VStack(spacing: 2) {
                        ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                            PremiumFeatureRow(feature: feature)
                                .opacity(featuresAppeared ? 1 : 0)
                                .offset(x: featuresAppeared ? 0 : -30)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.08),
                                    value: featuresAppeared
                                )
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

                    // Free trial badge
                    HStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.teal)
                        Text("7 gun pulsuz sinaq")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.teal)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.teal.opacity(0.15))
                    .cornerRadius(20)

                    // Pricing plans
                    HStack(spacing: 12) {
                        // Monthly
                        PremiumPricingCard(
                            title: "Ayliq",
                            price: "9.99",
                            period: "ay",
                            isSelected: selectedPlan == .monthly,
                            isPopular: false
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlan = .monthly
                            }
                        }

                        // Yearly
                        PremiumPricingCard(
                            title: "Illik",
                            price: "79.99",
                            period: "il",
                            isSelected: selectedPlan == .yearly,
                            isPopular: true,
                            savings: "33% qenaet"
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlan = .yearly
                            }
                        }
                    }

                    // Subscribe button
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
                        VStack(spacing: 4) {
                            HStack(spacing: 10) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18))
                                Text("Pulsuz sinaga basla")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)

                            Text("7 gun pulsuz, sonra \(selectedPlan == .yearly ? "₼79.99/il" : "₼9.99/ay")")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.indigo, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .indigo.opacity(0.6), radius: 15, x: 0, y: 8)
                    }
                    .scaleEffect(buttonPressed ? 0.95 : 1.0)

                    // Terms
                    VStack(spacing: 6) {
                        Text("Istediyiniz vaxt legv edin")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))

                        Text("Odenis App Store hesabiniz uzerinden alinir")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func activatePremium() {
        settings.isPremium = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}

// MARK: - Premium Feature Row (vertical list)
struct PremiumFeatureRow: View {
    let feature: PremiumView.PremiumFeature

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

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.indigo, .teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
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
                Text("EN POPULYAR")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: [.indigo, .purple],
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
                Text("₼")
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
                    .foregroundColor(.teal)
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
                        ? LinearGradient(colors: [.indigo, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
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
