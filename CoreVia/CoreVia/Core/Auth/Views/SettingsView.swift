
import SwiftUI
import LocalAuthentication

// MARK: - Notifications Settings View
struct NotificationsSettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    @State private var showPermissionAlert = false
    
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
                                Text("Bildirişlər")
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
                        Text("Ümumi")
                    }
                    
                    Section {
                        Toggle(isOn: $settings.workoutReminders) {
                            HStack {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundColor(.orange)
                                Text("Məşq xatırlatmaları")
                            }
                        }
                        .disabled(!settings.notificationsEnabled)
                        
                        Toggle(isOn: $settings.mealReminders) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.green)
                                Text("Qida xatırlatmaları")
                            }
                        }
                        .disabled(!settings.notificationsEnabled)
                        
                        Toggle(isOn: $settings.weeklyReports) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.blue)
                                Text("Həftəlik hesabat")
                            }
                        }
                        .disabled(!settings.notificationsEnabled)
                    } header: {
                        Text("Xatırlatmalar")
                    } footer: {
                        Text("Məşq və qida qeydləriniz üçün xatırlatmalar alın")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Bildirişlər")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bağla") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("İcazə Tələb Olunur", isPresented: $showPermissionAlert) {
                Button("Tənzimləmələr") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Ləğv et", role: .cancel) { }
            } message: {
                Text("Bildirişlər üçün icazə verin. Tənzimləmələrdən CoreVia tətbiqinə icazə verin.")
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
                                    Text("Tez giriş üçün")
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
                        Text("Biometrik")
                    } footer: {
                        Text("Tətbiqə \(settings.getBiometricType()) ilə daxil olun")
                    }
                    
                    Section {
                        if settings.hasAppPassword {
                            Button {
                                showPasswordSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "key.fill")
                                        .foregroundColor(.orange)
                                    Text("Şifrəni Dəyiş")
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
                                    Text("Şifrəni Sil")
                                }
                            }
                        } else {
                            Button {
                                showPasswordSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.green)
                                    Text("Şifrə Təyin Et")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                        .font(.caption)
                                }
                            }
                        }
                    } header: {
                        Text("Şifrə")
                    } footer: {
                        Text("Tətbiq üçün 4 rəqəmli şifrə təyin edin")
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.purple)
                            Text("İki faktorlu autentifikasiya")
                            Spacer()
                            Text("Tezliklə")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    } header: {
                        Text("Əlavə Təhlükəsizlik")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Təhlükəsizlik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bağla") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showPasswordSheet) {
                SetPasswordView()
            }
            .alert("Şifrəni Sil", isPresented: $showRemovePasswordAlert) {
                Button("Sil", role: .destructive) {
                    settings.removePassword()
                }
                Button("Ləğv et", role: .cancel) { }
            } message: {
                Text("Tətbiq şifrəsini silmək istədiyinizə əminsiniz?")
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(settings.hasAppPassword ? "Şifrəni Dəyiş" : "Şifrə Təyin Et")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        
                        Text("4 rəqəmli şifrə daxil edin")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    
                    VStack(spacing: 20) {
                        PinCodeField(text: $password, title: "Şifrə")
                        PinCodeField(text: $confirmPassword, title: "Şifrə təkrarı")
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button {
                        savePassword()
                    } label: {
                        Text("Saxla")
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
                    Button("Ləğv et") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func savePassword() {
        guard password.count == 4 else {
            showErrorMessage("Şifrə 4 rəqəm olmalıdır")
            return
        }
        
        guard password == confirmPassword else {
            showErrorMessage("Şifrələr uyğun gəlmir")
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
                                
                                Text("Gücə Gedən Yol")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                
                                Text("Versiya 1.0.0")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.tertiaryText)
                            }
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Haqqında")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            Text("CoreVia fitness və qidalanma tracking tətbiqidir. Məşq və qida qeydlərinizi asanlıqla izləyin, hədəflərinizə çatın və sağlam həyat tərzini dəstəkləyin.")
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
                            Text("Xüsusiyyətlər")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            FeatureRow(icon: "figure.strengthtraining.traditional", title: "Məşq Tracking", color: .red)
                            FeatureRow(icon: "fork.knife", title: "Qida Tracking", color: .green)
                            FeatureRow(icon: "person.2.fill", title: "Müəllim Sistemi", color: .purple)
                            FeatureRow(icon: "chart.bar.fill", title: "Statistika", color: .blue)
                            FeatureRow(icon: "bell.fill", title: "Xatırlatmalar", color: .orange)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(16)
                        
                        // Links
                        VStack(spacing: 12) {
                            AboutLinkButton(icon: "globe", title: "Veb Sayt", url: "https://corevia.com")
                            AboutLinkButton(icon: "envelope.fill", title: "Əlaqə", url: "mailto:support@corevia.com")
                            AboutLinkButton(icon: "doc.text.fill", title: "İstifadə Şərtləri", url: "https://corevia.com/terms")
                            AboutLinkButton(icon: "hand.raised.fill", title: "Məxfilik Siyasəti", url: "https://corevia.com/privacy")
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
            .navigationTitle("Haqqında")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bağla") {
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

// MARK: - Premium View (Spotify-style Paywall)
struct PremiumView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    @State private var animateGradient = false
    @State private var crownScale: CGFloat = 0.5
    @State private var crownRotation: Double = -30
    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var buttonPressed = false
    @State private var featuresAppeared = false

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

    let features: [PremiumFeature] = [
        PremiumFeature(icon: "crown.fill", title: "Limitsiz Məşq", description: "Sınırsız məşq qeydləri yarat", color: .yellow),
        PremiumFeature(icon: "chart.bar.fill", title: "Ətraflı Statistika", description: "Dərin analitika və tərəqqi", color: .blue),
        PremiumFeature(icon: "bell.badge.fill", title: "Smart Bildirişlər", description: "Ağıllı xatırlatma sistemi", color: .orange),
        PremiumFeature(icon: "person.2.fill", title: "Premium Müəllimlər", description: "Ən yaxşı müəllimlərlə əlaqə", color: .purple),
        PremiumFeature(icon: "sparkles", title: "AI Tövsiyələri", description: "Süni intellekt əsaslı planlar", color: .pink),
        PremiumFeature(icon: "cloud.fill", title: "Cloud Sync", description: "Bütün cihazlarda sinxronizasiya", color: .cyan)
    ]

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: animateGradient
                    ? [Color.black, Color.purple.opacity(0.4), Color.black]
                    : [Color.black, Color.orange.opacity(0.3), Color.black],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Close button
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(.top, 12)

                    // Crown animation
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.yellow.opacity(0.4), Color.clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .blur(radius: 20)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(crownScale)
                            .rotationEffect(.degrees(crownRotation))
                            .shadow(color: .yellow.opacity(0.6), radius: 20, x: 0, y: 10)
                    }
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                            crownScale = 1.0
                            crownRotation = 0
                        }
                    }

                    // Title
                    VStack(spacing: 8) {
                        Text("CoreVia")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(4)

                        Text("PREMIUM")
                            .font(.system(size: 40, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Bütün funksiyalara tam giriş")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Feature cards - horizontal scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                                PremiumFeatureCard(feature: feature)
                                    .opacity(featuresAppeared ? 1 : 0)
                                    .offset(y: featuresAppeared ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.7)
                                            .delay(Double(index) * 0.1),
                                        value: featuresAppeared
                                    )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .onAppear {
                        featuresAppeared = true
                    }

                    // Pricing plans
                    HStack(spacing: 14) {
                        // Monthly
                        PremiumPricingCard(
                            title: "Aylıq",
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
                            title: "İllik",
                            price: "79.99",
                            period: "il",
                            isSelected: selectedPlan == .yearly,
                            isPopular: true,
                            savings: "20% QƏNAƏT"
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
                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 20))
                            Text("Premium Aktivləşdir")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .yellow.opacity(0.5), radius: 15, x: 0, y: 8)
                    }
                    .scaleEffect(buttonPressed ? 0.95 : 1.0)

                    // Terms
                    VStack(spacing: 4) {
                        Text("Ödəniş Apple ID hesabınızdan çıxılacaq.")
                            .font(.system(size: 11))
                        Text("İstifadə şərtləri və məxfilik siyasəti tətbiq olunur.")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
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

// MARK: - Premium Feature Card
struct PremiumFeatureCard: View {
    let feature: PremiumView.PremiumFeature

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: feature.icon)
                    .font(.system(size: 24))
                    .foregroundColor(feature.color)
            }

            Text(feature.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            Text(feature.description)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 140, height: 160)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(feature.color.opacity(0.3), lineWidth: 1)
        )
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
        VStack(spacing: 12) {
            if isPopular {
                Text("ƏN POPULYAR")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(6)
            }

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("₼")
                    .font(.system(size: 16, weight: .semibold))
                Text(price)
                    .font(.system(size: 32, weight: .black))
                Text("/\(period)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            .foregroundColor(.white)

            if let savings = savings {
                Text(savings)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected
                        ? LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
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
