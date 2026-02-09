import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Soft gradient background
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        Spacer()
                            .frame(height: 60)

                        // Modern Logo with gradient
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 20, x: 0, y: 10)

                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }

                            Text("EmlakCRM")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Real Estate Management")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.bottom, 20)

                        // Form Card
                        VStack(spacing: 20) {
                            Text("Daxil Olun")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Modern Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)

                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(AppTheme.textSecondary)
                                        .frame(width: 20)

                                    TextField("email@example.com", text: $email)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .font(.system(size: 16))
                                }
                                .padding()
                                .background(AppTheme.backgroundColor)
                                .cornerRadius(12)
                            }

                            // Modern Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifrə")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)

                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(AppTheme.textSecondary)
                                        .frame(width: 20)

                                    SecureField("••••••••", text: $password)
                                        .textContentType(.password)
                                        .font(.system(size: 16))
                                }
                                .padding()
                                .background(AppTheme.backgroundColor)
                                .cornerRadius(12)
                            }

                            // Error Message
                            if let error = authVM.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(AppTheme.errorColor)
                                    Text(error)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.errorColor)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.errorColor.opacity(0.1))
                                .cornerRadius(12)
                            }

                            // Login Button
                            Button {
                                Task {
                                    await authVM.login(email: email, password: password)
                                }
                            } label: {
                                HStack {
                                    if authVM.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Daxil ol")
                                            .font(.system(size: 17, weight: .semibold))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.primaryGradient)
                                .cornerRadius(14)
                                .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
                            }
                            .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
                            .opacity((authVM.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)

                            // Register Link
                            HStack {
                                Text("Hesabınız yoxdur?")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)

                                Button {
                                    showRegister = true
                                } label: {
                                    Text("Qeydiyyatdan keçin")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryColor)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(28)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 20)

                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
