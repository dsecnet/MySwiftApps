//
//  RegisterView.swift
//  EmlakCRM
//
//  Register Screen
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false

    private var isValid: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty &&
        password.count >= 6 && password == confirmPassword
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Qeydiyyat")
                            .font(AppTheme.title())
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Yeni hesab yaradın")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 40)

                    // Form
                    VStack(spacing: 16) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ad Soyad")
                                .font(AppTheme.headline())
                            TextField("Məsələn: Rəşad Məmmədov", text: $name)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)
                        }

                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(AppTheme.headline())
                            TextField("agent@emlak.az", text: $email)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)
                        }

                        // Phone
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Telefon")
                                .font(AppTheme.headline())
                            TextField("+994501234567", text: $phone)
                                .textFieldStyle(.plain)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifrə")
                                .font(AppTheme.headline())
                            SecureField("Minimum 6 simvol", text: $password)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifrəni təsdiq et")
                                .font(AppTheme.headline())
                            SecureField("Şifrəni yenidən daxil edin", text: $confirmPassword)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)

                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Şifrələr uyğun gəlmir")
                                    .font(AppTheme.caption())
                                    .foregroundColor(AppTheme.errorColor)
                            }
                        }

                        // Error
                        if let error = authVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error)
                                    .font(AppTheme.caption())
                            }
                            .foregroundColor(AppTheme.errorColor)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.errorColor.opacity(0.1))
                            .cornerRadius(AppTheme.cornerRadius)
                        }

                        // Register Button
                        Button {
                            Task {
                                await authVM.register(
                                    name: name,
                                    email: email,
                                    phone: phone,
                                    password: password
                                )
                            }
                        } label: {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Qeydiyyatdan keç")
                                }
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(!isValid || authVM.isLoading)
                        .opacity((!isValid || authVM.isLoading) ? 0.6 : 1.0)

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
                            .font(AppTheme.body())
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
