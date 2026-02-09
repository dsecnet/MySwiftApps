//
//  LoginView.swift
//  EmlakCRM
//
//  Login Screen
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Logo & Title
                        VStack(spacing: 16) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.primaryColor)

                            Text("Əmlak CRM")
                                .font(AppTheme.largeTitle())
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Azərbaycan Əmlakçıları üçün")
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 40)

                        // Login Form
                        VStack(spacing: 20) {
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)

                                TextField("agent@emlak.az", text: $email)
                                    .textFieldStyle(.plain)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }

                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifrə")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)

                                HStack {
                                    if showPassword {
                                        TextField("••••••••", text: $password)
                                            .textFieldStyle(.plain)
                                    } else {
                                        SecureField("••••••••", text: $password)
                                            .textFieldStyle(.plain)
                                    }

                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)
                            }

                            // Error Message
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

                            // Login Button
                            Button {
                                Task {
                                    await authVM.login(email: email, password: password)
                                }
                            } label: {
                                HStack {
                                    if authVM.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Daxil ol")
                                    }
                                }
                            }
                            .primaryButtonStyle()
                            .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
                            .opacity((authVM.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)

                            // Register Link
                            Button {
                                showRegister = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Hesabınız yoxdur?")
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text("Qeydiyyat")
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
