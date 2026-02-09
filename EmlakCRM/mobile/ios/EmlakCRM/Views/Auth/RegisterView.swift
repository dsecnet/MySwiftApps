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
            AppTheme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Qeydiyyat")
                        .font(AppTheme.largeTitle())
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.top, 40)

                    // Form
                    VStack(spacing: 16) {
                        // Full Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ad Soyad")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Ad Soyad", text: $fullName)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.name)
                        }

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
                                .textContentType(.newPassword)
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifrəni təsdiqlə")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            SecureField("••••••••", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.newPassword)
                        }

                        // Error Message
                        if let error = authVM.errorMessage {
                            Text(error)
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.errorColor)
                                .padding(.vertical, 8)
                        }

                        // Password mismatch warning
                        if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Şifrələr uyğun gəlmir")
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.warningColor)
                        }

                        // Register Button
                        Button {
                            Task {
                                await authVM.register(email: email, password: password, fullName: fullName)
                            }
                        } label: {
                            if authVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Qeydiyyatdan keç")
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(
                            authVM.isLoading ||
                            fullName.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty ||
                            password != confirmPassword
                        )

                        // Back to Login
                        Button {
                            dismiss()
                        } label: {
                            Text("Artıq hesabınız var? ")
                                .foregroundColor(AppTheme.textSecondary) +
                            Text("Daxil ol")
                                .foregroundColor(AppTheme.primaryColor)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
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
