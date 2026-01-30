//
//  SettingsViews.swift
//  CoreVia
//
//  Bütün tənzimləmə səhifələri
//

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

// MARK: - Premium View
struct PremiumView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    
    let features = [
        ("crown.fill", "Limitsiz məşq qeydləri", "yellow"),
        ("chart.bar.fill", "Ətraflı statistika", "blue"),
        ("bell.badge.fill", "Premium bildirişlər", "orange"),
        ("person.2.fill", "Premium müəllimlərlə əlaqə", "purple"),
        ("sparkles", "AI tövsiyələri", "pink"),
        ("cloud.fill", "Cloud sync", "cyan")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                            
                            Text("CoreVia Premium")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            Text("Bütün funksiyalara giriş")
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                        .padding(.top, 20)
                        
                        // Features
                        VStack(spacing: 16) {
                            ForEach(features, id: \.0) { icon, title, colorName in
                                PremiumFeatureRow(icon: icon, title: title, color: getColor(colorName))
                            }
                        }
                        
                        // Pricing
                        VStack(spacing: 16) {
                            PricingCard(
                                title: "Aylıq",
                                price: "9.99",
                                period: "ay",
                                isPopular: false
                            )
                            
                            PricingCard(
                                title: "İllik",
                                price: "79.99",
                                period: "il",
                                isPopular: true,
                                savings: "20% qənaət"
                            )
                        }
                        
                        // Subscribe Button
                        Button {
                            activatePremium()
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Premium Aktivləşdir")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .yellow.opacity(0.4), radius: 10)
                        }
                        
                        // Terms
                        Text("Ödəniş Apple ID hesabınızdan çıxılacaq. İstifadə şərtləri və məxfilik siyasəti tətbiq olunur.")
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Premium")
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
    
    private func activatePremium() {
        // Demo: Activate premium
        settings.isPremium = true
        dismiss()
    }
    
    private func getColor(_ name: String) -> Color {
        switch name {
        case "yellow": return .yellow
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "cyan": return .cyan
        default: return .red
        }
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            Text(title)
                .foregroundColor(AppTheme.Colors.primaryText)
                .font(.system(size: 16))
            
            Spacer()
            
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.system(size: 16, weight: .bold))
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let period: String
    let isPopular: Bool
    var savings: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            if isPopular {
                Text("ƏN POPULYAR")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(4)
            }
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₼")
                    .font(.system(size: 20, weight: .semibold))
                Text(price)
                    .font(.system(size: 36, weight: .bold))
                Text("/ \(period)")
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            .foregroundColor(AppTheme.Colors.primaryText)
            
            if let savings = savings {
                Text(savings)
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPopular ? Color.orange : Color.clear, lineWidth: 2)
        )
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
