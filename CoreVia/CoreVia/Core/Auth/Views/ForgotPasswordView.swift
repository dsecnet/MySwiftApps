//
//  ForgotPasswordView.swift
//  CoreVia
//
//  WhatsApp OTP ilə şifrəni bərpa etmək
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var loc = LocalizationManager.shared

    // States
    @State private var email: String = ""
    @State private var otpCode: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var currentStep: ForgotPasswordStep = .enterEmail
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showSuccess: Bool = false
    @State private var isPasswordVisible: Bool = false

    // Timer for OTP
    @State private var otpCountdown: Int = 0
    @State private var timer: Timer?

    enum ForgotPasswordStep {
        case enterEmail
        case enterOTP
        case enterNewPassword
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Content based on step
                    switch currentStep {
                    case .enterEmail:
                        phoneInputSection
                    case .enterOTP:
                        otpInputSection
                    case .enterNewPassword:
                        newPasswordSection
                    }

                    Spacer()
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Şifrəni Bərpa Et")
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Xəta", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Uğurlu!", isPresented: $showSuccess) {
            Button("Giriş et") {
                dismiss()
            }
        } message: {
            Text("Şifrəniz uğurla yeniləndi")
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: currentStep == .enterEmail ? "envelope.fill" :
                      currentStep == .enterOTP ? "lock.shield.fill" : "key.fill")
                    .font(.system(size: 35))
                    .foregroundColor(AppTheme.Colors.accent)
            }

            Text(stepTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(stepDescription)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 20)
    }

    // MARK: - Step 1: Email & Phone Input
    private var phoneInputSection: some View {
        VStack(spacing: 20) {
            // Email Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(AppTheme.Colors.accent)
                        .frame(width: 20)

                    TextField("email@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                }
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(email.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
                )
            }

            // Send OTP Button
            Button {
                sendOTP()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Email-ə OTP Göndər")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading || email.isEmpty)
            .opacity(email.isEmpty ? 0.6 : 1.0)
        }
        .padding(.top, 30)
    }

    // MARK: - Step 2: OTP Input
    private var otpInputSection: some View {
        VStack(spacing: 20) {
            // OTP Code Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Təsdiq Kodu")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                HStack(spacing: 12) {
                    Image(systemName: "message.fill")
                        .foregroundColor(AppTheme.Colors.accent)
                        .frame(width: 20)

                    TextField("6 rəqəmli kod", text: $otpCode)
                        .keyboardType(.numberPad)
                        .onChange(of: otpCode) { newValue in
                            // Limit to 6 digits
                            if newValue.count > 6 {
                                otpCode = String(newValue.prefix(6))
                            }
                        }
                }
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(otpCode.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
                )
            }

            // Resend OTP
            if otpCountdown > 0 {
                Text("Yenidən göndər: \(otpCountdown)s")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.tertiaryText)
            } else {
                Button {
                    sendOTP()
                } label: {
                    Text("Kodu yenidən göndər")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }

            // Verify Button
            Button {
                currentStep = .enterNewPassword
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Təsdiq Et")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading || otpCode.count != 6)
            .opacity(otpCode.count == 6 ? 1.0 : 0.6)
        }
        .padding(.top, 30)
    }

    // MARK: - Step 3: New Password
    private var newPasswordSection: some View {
        VStack(spacing: 20) {
            // New Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Yeni Şifrə")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppTheme.Colors.accent)
                        .frame(width: 20)

                    if isPasswordVisible {
                        TextField("", text: $newPassword)
                    } else {
                        SecureField("", text: $newPassword)
                    }

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                }
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(newPassword.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
                )
            }

            // Confirm Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Şifrəni Təsdiq Et")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppTheme.Colors.accent)
                        .frame(width: 20)

                    SecureField("", text: $confirmPassword)
                }
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(confirmPassword.isEmpty ? AppTheme.Colors.separator :
                               (newPassword == confirmPassword ? AppTheme.Colors.success : AppTheme.Colors.error), lineWidth: 1)
                )
            }

            // Password strength indicator
            if !newPassword.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index < passwordStrength ? strengthColor : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                Text(strengthText)
                    .font(.system(size: 12))
                    .foregroundColor(strengthColor)
            }

            // Reset Button
            Button {
                resetPassword()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Şifrəni Yenilə")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.success, AppTheme.Colors.success.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading || !isPasswordValid)
            .opacity(isPasswordValid ? 1.0 : 0.6)
        }
        .padding(.top, 30)
    }

    // MARK: - Computed Properties
    private var stepTitle: String {
        switch currentStep {
        case .enterEmail:
            return "Şifrəni Bərpa Et"
        case .enterOTP:
            return "Kodu Daxil Et"
        case .enterNewPassword:
            return "Yeni Şifrə"
        }
    }

    private var stepDescription: String {
        switch currentStep {
        case .enterEmail:
            return "Email adresinize OTP kodu göndərəcəyik"
        case .enterOTP:
            return "Email -ə göndərilən 6 rəqəmli kodu daxil edin"
        case .enterNewPassword:
            return "Yeni şifrənizi daxil edin"
        }
    }

    private var passwordStrength: Int {
        let length = newPassword.count
        if length < 6 { return 0 }
        if length < 8 { return 1 }

        var strength = 2
        if newPassword.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        if newPassword.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }

        return min(strength, 4)
    }

    private var strengthColor: Color {
        switch passwordStrength {
        case 0...1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .green
        }
    }

    private var strengthText: String {
        switch passwordStrength {
        case 0...1: return "Zəif"
        case 2: return "Orta"
        case 3: return "Yaxşı"
        default: return "Güclü"
        }
    }

    private var isPasswordValid: Bool {
        return newPassword.count >= 6 && newPassword == confirmPassword
    }

    // MARK: - Functions
    private func sendOTP() {
        guard !email.isEmpty else { return }

        isLoading = true

        Task {
            do {
                struct ForgotPasswordRequest: Codable {
                    let email: String
                }

                let response: OTPResponse = try await APIService.shared.request(
                    endpoint: "/api/v1/auth/forgot-password",
                    method: "POST",
                    body: ForgotPasswordRequest(email: email),
                    requiresAuth: false
                )

                await MainActor.run {
                    isLoading = false
                    if response.success {
                        currentStep = .enterOTP
                        startOTPTimer()

                        // Mock mode-da kodu göstər
                        if let code = response.code {
                            print("🔐 OTP Code (test): \(code)")
                        }
                    } else {
                        errorMessage = response.message
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Xəta baş verdi"
                    showError = true
                }
            }
        }
    }

    private func resetPassword() {
        guard isPasswordValid else { return }

        isLoading = true

        Task {
            do {
                struct ResetPasswordRequest: Codable {
                    let email: String
                    let otp_code: String
                    let new_password: String
                }

                struct ResetPasswordResponse: Codable {
                    let success: Bool
                    let message: String
                }

                let _: ResetPasswordResponse = try await APIService.shared.request(
                    endpoint: "/api/v1/auth/reset-password",
                    method: "POST",
                    body: ResetPasswordRequest(
                        email: email,
                        otp_code: otpCode,
                        new_password: newPassword
                    ),
                    requiresAuth: false
                )

                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Şifrə yenilənərkən xəta"
                    showError = true
                }
            }
        }
    }

    private func startOTPTimer() {
        otpCountdown = 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if otpCountdown > 0 {
                otpCountdown -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

// MARK: - Response Model
struct OTPResponse: Codable {
    let success: Bool
    let message: String
    let code: String?
}
