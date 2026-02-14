import SwiftUI

struct LoginView: View {

    @Binding var isLoggedIn: Bool
    @Binding var showRegister: Bool
    @StateObject private var profileManager = UserProfileManager.shared
    @StateObject private var authManager = AuthManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var selectedUserType: UserProfileType = .client
    @State private var isPasswordVisible: Bool = false
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    // 2FA OTP
    @State private var currentStep: Int = 1 // 1: Email+Password, 2: OTP Verification
    @State private var otpCode: String = ""

    var body: some View {
        ZStack {
            // MARK: - Arxa Fon (Adaptiv)
            AppTheme.Colors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // MARK: - Dil Seçici (Sol Yuxarıda)
                    HStack(spacing: 8) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Button {
                                withAnimation(.spring()) {
                                    loc.currentLanguage = language
                                }
                            } label: {
                                Text(language.flag)
                                    .font(.system(size: 22))
                                    .frame(width: 40, height: 40)
                                    .background(loc.currentLanguage == language ? AppTheme.Colors.accent.opacity(0.15) : AppTheme.Colors.secondaryBackground)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(loc.currentLanguage == language ? AppTheme.Colors.accent : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 12)

                    // MARK: - Logo Bölməsi
                    VStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.Colors.accent.opacity(0.3), AppTheme.Colors.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 15)

                             Image("corevia_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .padding(12)
                                .background(
                                    LinearGradient(
                                        colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: AppTheme.Colors.accent.opacity(0.5), radius: 15, x: 0, y: 8)
                        }

                        // App Adı
                        VStack(spacing: 6) {
                            Text("CoreVia")
                                .font(.system(size: 38, weight: .black))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            Text(loc.localized("login_slogan"))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.accent)
                                .tracking(2.5)
                        }
                    }

                    // MARK: - User Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.localized("login_account_type"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        HStack(spacing: 12) {
                            // Tələbə Button
                            Button {
                                withAnimation(.spring()) {
                                    selectedUserType = .client
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                    Text(loc.localized("login_student"))
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedUserType == .client ? AppTheme.Colors.accent : AppTheme.Colors.secondaryBackground)
                                .foregroundColor(selectedUserType == .client ? .white : AppTheme.Colors.primaryText)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedUserType == .client ? AppTheme.Colors.accent : AppTheme.Colors.separator, lineWidth: selectedUserType == .client ? 2 : 1)
                                )
                            }

                            // Müəllim Button
                            Button {
                                withAnimation(.spring()) {
                                    selectedUserType = .trainer
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 16))
                                    Text(loc.localized("login_teacher"))
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedUserType == .trainer ? AppTheme.Colors.accent : AppTheme.Colors.secondaryBackground)
                                .foregroundColor(selectedUserType == .trainer ? .white : AppTheme.Colors.primaryText)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedUserType == .trainer ? AppTheme.Colors.accent : AppTheme.Colors.separator, lineWidth: selectedUserType == .trainer ? 2 : 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 28)

                    // MARK: - Step-based Content
                    if currentStep == 1 {
                        // Step 1: Email + Password
                        emailPasswordInputs
                    } else {
                        // Step 2: OTP Verification
                        otpVerificationSection
                    }
                }
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(.keyboard)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    // MARK: - Email + Password Inputs
    private var emailPasswordInputs: some View {
        Group {
            // MARK: - Input Fields
            VStack(spacing: 16) {

                        // Email Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text(loc.localized("common_email"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .frame(width: 20)

                                TextField("", text: $email, prompt: Text(loc.localized("login_email_placeholder")).foregroundColor(AppTheme.Colors.placeholderText))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                            }
                            .padding()
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        email.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5),
                                        lineWidth: 1
                                    )
                            )
                        }

                        // Şifrə Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text(loc.localized("common_password"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack(spacing: 10) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .frame(width: 20)

                                Group {
                                    if isPasswordVisible {
                                        TextField("", text: $password, prompt: Text(loc.localized("login_password_placeholder")).foregroundColor(AppTheme.Colors.placeholderText))
                                    } else {
                                        SecureField("", text: $password, prompt: Text(loc.localized("login_password_placeholder")).foregroundColor(AppTheme.Colors.placeholderText))
                                    }
                                }
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .textContentType(.password)

                                Button {
                                    withAnimation(.spring()) {
                                        isPasswordVisible.toggle()
                                    }
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                        .font(.system(size: 14))
                                }
                            }
                            .padding()
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        password.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 28)

                    // MARK: - Şifrəni Unutdum
                    HStack {
                        Spacer()
                        NavigationLink {
                            ForgotPasswordView()
                        } label: {
                            Text(loc.localized("login_forgot_password"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }
                    .padding(.horizontal, 28)

                    // MARK: - Error Message
                    if showError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppTheme.Colors.error)
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.primaryText)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.Colors.error.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 28)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // MARK: - Giriş Düymələri
                    VStack(spacing: 12) {

                        // Əsas Giriş
                        Button {
                            loginAction()
                        } label: {
                            HStack(spacing: 10) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: selectedUserType == .client ? "person.fill" : "person.2.fill")
                                        .font(.system(size: 14, weight: .bold))

                                    Text(selectedUserType == .client ? loc.localized("login_as_student") : loc.localized("login_as_teacher"))
                                        .font(.system(size: 16, weight: .bold))

                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(
                                color: AppTheme.Colors.accent.opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        }
                        .disabled(isLoading)

                    }
                    .padding(.horizontal, 28)

                    // MARK: - Ayırıcı
                    HStack(spacing: 12) {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(AppTheme.Colors.separator)

                        Text(loc.localized("common_or"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(AppTheme.Colors.separator)
                    }
                    .padding(.horizontal, 28)

                    // MARK: - Qeydiyyat Linki
                    HStack(spacing: 5) {
                        Text(loc.localized("login_no_account"))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        Button {
                            withAnimation(.spring()) {
                                showRegister = true
                            }
                        } label: {
                            Text(loc.localized("login_register"))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.Colors.accent)
                        }
                    }
                    .padding(.bottom, 30)
        }
    }

    // MARK: - Actions
    private func loginAction() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            showErrorMessage("Email boşdur")
            return
        }

        guard !password.isEmpty else {
            showErrorMessage("Şifrə boşdur")
            return
        }

        guard email.contains("@") else {
            showErrorMessage("Email düzgün deyil")
            return
        }

        guard password.count >= 6 else {
            showErrorMessage("Şifrə minimum 6 simvol olmalıdır")
            return
        }

        isLoading = true
        showError = false

        Task {
            do {
                // Step 1: Send credentials, receive OTP
                let url = URL(string: "\(APIService.shared.baseURL)/auth/login")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: String] = [
                    "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
                    "password": password
                ]
                request.httpBody = try JSONEncoder().encode(body)

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }

                if httpResponse.statusCode == 200 {
                    await MainActor.run {
                        isLoading = false
                        withAnimation {
                            currentStep = 2 // Go to OTP step
                        }
                    }
                } else {
                    let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                    throw NSError(domain: errorResponse?["detail"] ?? "Email və ya şifrə səhvdir", code: httpResponse.statusCode)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showErrorMessage(error.localizedDescription)
                }
            }
        }
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        withAnimation {
            showError = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showError = false
            }
        }
    }

    // MARK: - OTP Verification Section
    private var otpVerificationSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("OTP Təsdiqi")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text("\(email) ünvanına göndərilən 6 rəqəmli kodu daxil edin")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .padding(.top, 40)

            // OTP Input
            TextField("000000", text: $otpCode)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .onChange(of: otpCode) { newValue in
                    otpCode = String(newValue.prefix(6).filter { $0.isNumber })
                }

            if showError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.Colors.error)
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.primaryText)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.error.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 28)
            }

            // Verify Button
            Button {
                verifyOTPAndLogin()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Təsdiq Et və Daxil Ol")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
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
            .opacity(otpCode.count == 6 ? 1.0 : 0.5)
            .padding(.horizontal, 28)

            // Resend OTP
            Button {
                currentStep = 1
                otpCode = ""
            } label: {
                Text("Geri qayıt")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.accent)
            }

            Spacer()
        }
    }

    private func verifyOTPAndLogin() {
        isLoading = true
        showError = false

        Task {
            do {
                let url = URL(string: "\(APIService.shared.baseURL)/auth/login-verify")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: String] = [
                    "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
                    "otp_code": otpCode
                ]
                request.httpBody = try JSONEncoder().encode(body)

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }

                if httpResponse.statusCode == 200 {
                    // Parse token response
                    struct TokenResponse: Codable {
                        let access_token: String
                        let refresh_token: String
                    }

                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

                    // Save tokens
                    AuthManager.shared.accessToken = tokenResponse.access_token
                    AuthManager.shared.refreshToken = tokenResponse.refresh_token

                    await MainActor.run {
                        isLoading = false
                        withAnimation {
                            isLoggedIn = true
                        }
                    }
                } else {
                    let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                    throw NSError(domain: errorResponse?["detail"] ?? "OTP səhvdir", code: httpResponse.statusCode)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showErrorMessage(error.localizedDescription)
                }
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// #Preview { // iOS 17+ only
//     LoginView(isLoggedIn: .constant(false), showRegister: .constant(false))
// }
