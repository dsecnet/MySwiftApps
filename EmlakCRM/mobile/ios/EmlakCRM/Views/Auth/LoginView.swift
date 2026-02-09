import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Logo
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.primaryColor)
                            .padding(.top, 60)

                        Text("EmlakCRM")
                            .font(AppTheme.largeTitle())
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Giriş edin")
                            .font(AppTheme.title())
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.bottom, 32)

                        // Form
                        VStack(spacing: 16) {
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)

                                TextField("email@example.com", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }

                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifrə")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)

                                SecureField("••••••••", text: $password)
                                    .textFieldStyle(.roundedBorder)
                                    .textContentType(.password)
                            }

                            // Error Message
                            if let error = authVM.errorMessage {
                                Text(error)
                                    .font(AppTheme.caption())
                                    .foregroundColor(AppTheme.errorColor)
                                    .padding(.vertical, 8)
                            }

                            // Login Button
                            Button {
                                Task {
                                    await authVM.login(email: email, password: password)
                                }
                            } label: {
                                if authVM.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Daxil ol")
                                }
                            }
                            .primaryButtonStyle()
                            .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)

                            // Register Link
                            Button {
                                showRegister = true
                            } label: {
                                Text("Hesabınız yoxdur? ")
                                    .foregroundColor(AppTheme.textSecondary) +
                                Text("Qeydiyyat")
                                    .foregroundColor(AppTheme.primaryColor)
                                    .fontWeight(.semibold)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
