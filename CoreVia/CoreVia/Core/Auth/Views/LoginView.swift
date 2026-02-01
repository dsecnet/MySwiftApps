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
                                withAnimation(.spring(response: 0.3)) {
                                    loc.currentLanguage = language
                                }
                            } label: {
                                Text(language.flag)
                                    .font(.system(size: 22))
                                    .frame(width: 40, height: 40)
                                    .background(loc.currentLanguage == language ? Color.red.opacity(0.15) : AppTheme.Colors.secondaryBackground)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(loc.currentLanguage == language ? Color.red : Color.clear, lineWidth: 2)
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
                                        colors: [Color.red.opacity(0.3), Color.red],
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
                                        colors: [Color.red, Color.red.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 8)
                        }

                        // App Adı
                        VStack(spacing: 6) {
                            Text("CoreVia")
                                .font(.system(size: 38, weight: .black))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            Text(loc.localized("login_slogan"))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.red)
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
                                withAnimation(.spring(response: 0.3)) {
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
                                .background(selectedUserType == .client ? Color.red : AppTheme.Colors.secondaryBackground)
                                .foregroundColor(selectedUserType == .client ? .white : AppTheme.Colors.primaryText)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedUserType == .client ? Color.red : AppTheme.Colors.separator, lineWidth: selectedUserType == .client ? 2 : 1)
                                )
                            }

                            // Müəllim Button
                            Button {
                                withAnimation(.spring(response: 0.3)) {
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
                                .background(selectedUserType == .trainer ? Color.red : AppTheme.Colors.secondaryBackground)
                                .foregroundColor(selectedUserType == .trainer ? .white : AppTheme.Colors.primaryText)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedUserType == .trainer ? Color.red : AppTheme.Colors.separator, lineWidth: selectedUserType == .trainer ? 2 : 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 28)

                    // MARK: - Input Fields
                    VStack(spacing: 16) {

                        // Email Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text(loc.localized("common_email"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.red)
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
                                        email.isEmpty ? AppTheme.Colors.separator : Color.red.opacity(0.5),
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
                                    .foregroundColor(.red)
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
                                    withAnimation(.spring(response: 0.3)) {
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
                                        password.isEmpty ? AppTheme.Colors.separator : Color.red.opacity(0.5),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 28)

                    // MARK: - Şifrəni Unutdum
                    HStack {
                        Spacer()
                        Button {
                            print("Şifrəni unutdum")
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
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.primaryText)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.2))
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
                                    colors: [Color.red, Color.red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(
                                color: Color.red.opacity(0.4),
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
                            withAnimation(.spring(response: 0.4)) {
                                showRegister = true
                            }
                        } label: {
                            Text(loc.localized("login_register"))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    // MARK: - Actions
    private func loginAction() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            showErrorMessage(loc.localized("login_error_email_empty"))
            return
        }

        guard !password.isEmpty else {
            showErrorMessage(loc.localized("login_error_password_empty"))
            return
        }

        guard email.contains("@") else {
            showErrorMessage(loc.localized("login_error_email_invalid"))
            return
        }

        guard password.count >= 6 else {
            showErrorMessage(loc.localized("login_error_password_short"))
            return
        }

        isLoading = true
        showError = false

        Task {
            let success = await authManager.login(
                email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                password: password
            )

            await MainActor.run {
                isLoading = false
                if success {
                    withAnimation {
                        isLoggedIn = true
                    }
                } else {
                    showErrorMessage(authManager.errorMessage ?? loc.localized("login_error_wrong_credentials"))
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

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false), showRegister: .constant(false))
}
