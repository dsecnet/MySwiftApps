import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Logo and Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryGradient)
                                .frame(width: 100, height: 100)
                                .shadow(color: AppTheme.primaryColor.opacity(0.4), radius: 20, x: 0, y: 10)

                            Image(systemName: "building.2.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }

                        Text("Yeni Hesab")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("EmlakCRM-ə qoşulun")
                            .font(AppTheme.subheadline())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 40)

                    // Form Card
                    VStack(spacing: 20) {
                        // Full Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ad Soyad")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)

                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(width: 20)

                                TextField("Ad Soyad", text: $fullName)
                                    .textContentType(.name)
                            }
                            .padding()
                            .background(AppTheme.backgroundColor)
                            .cornerRadius(12)
                        }

                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)

                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(width: 20)

                                TextField("email@example.com", text: $email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(AppTheme.backgroundColor)
                            .cornerRadius(12)
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifrə")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(width: 20)

                                SecureField("••••••••", text: $password)
                                    .textContentType(.newPassword)
                            }
                            .padding()
                            .background(AppTheme.backgroundColor)
                            .cornerRadius(12)
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifrəni təsdiqlə")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(width: 20)

                                SecureField("••••••••", text: $confirmPassword)
                                    .textContentType(.newPassword)
                            }
                            .padding()
                            .background(AppTheme.backgroundColor)
                            .cornerRadius(12)
                        }

                        // Error Message
                        if let error = authVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppTheme.errorColor)
                                Text(error)
                                    .font(AppTheme.caption())
                                    .foregroundColor(AppTheme.errorColor)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.errorColor.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Password mismatch warning
                        if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(AppTheme.warningColor)
                                Text("Şifrələr uyğun gəlmir")
                                    .font(AppTheme.caption())
                                    .foregroundColor(AppTheme.warningColor)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.warningColor.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Register Button
                        Button {
                            Task {
                                await authVM.register(email: email, password: password, fullName: fullName)
                            }
                        } label: {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Qeydiyyatdan keç")
                                        .font(.system(size: 17, weight: .semibold))
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(12)
                            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(
                            authVM.isLoading ||
                            fullName.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty ||
                            password != confirmPassword
                        )
                        .opacity(
                            (authVM.isLoading ||
                            fullName.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty ||
                            password != confirmPassword) ? 0.6 : 1.0
                        )
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)
                    .padding(.horizontal, 24)

                    // Back to Login
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Artıq hesabınız var?")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Daxil ol")
                                .foregroundColor(AppTheme.primaryColor)
                                .fontWeight(.semibold)
                        }
                        .font(AppTheme.subheadline())
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
