//
//  LoginView.swift
//  FitnessApp
//
//  Giriş ekranı – Qara + Qırmızı theme
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - State Variables
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            // MARK: - Arxa fon
            Color.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Layout.spacingL) {
                    
                    // MARK: - Logo və Başlıq
                    VStack(spacing: Layout.spacingM) {
                        Image("corevia_icon")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .background(Color.red)

                        
                        Text("CoreVia")
                            .font(.system(size: Typography.titleLarge, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        Text("Fitness səyahətinə başla")
                            .font(.system(size: Typography.body))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, 60)
                    
                    // MARK: - Input Fields
                    VStack(spacing: Layout.spacingM) {
                        
                        CustomTextField(
                            placeholder: "Email",
                            text: $email,
                            icon: "envelope"
                        )
                        
                        CustomSecureField(
                            placeholder: "Şifrə",
                            text: $password,
                            isVisible: $isPasswordVisible
                        )
                    }
                    .padding(.horizontal, Layout.paddingL)
                    
                    // MARK: - Şifrəni unutdum
                    HStack {
                        Spacer()
                        Button {
                            print("Şifrəni unutdum")
                        } label: {
                            Text("Şifrəni unutdum?")
                                .font(.system(size: Typography.caption))
                                .foregroundColor(.primaryRed)
                        }
                    }
                    .padding(.horizontal, Layout.paddingL)
                    
                    // MARK: - Giriş düyməsi
                    Button(action: loginAction) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .textPrimary)
                                    )
                            } else {
                                Text("Daxil ol")
                                    .font(.system(size: Typography.body, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryRed)
                        .foregroundColor(.textPrimary)
                        .cornerRadius(Layout.cornerRadiusM)
                    }
                    .padding(.horizontal, Layout.paddingL)
                    .disabled(isLoading)
                    
                    // MARK: - Ayırıcı
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.4))
                        
                        Text("və ya")
                            .font(.system(size: Typography.caption))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, Layout.spacingS)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.4))
                    }
                    .padding(.horizontal, Layout.paddingL)
                    
                    // MARK: - Qeydiyyat linki
                    HStack(spacing: 4) {
                        Text("Hesabınız yoxdur?")
                            .font(.system(size: Typography.body))
                            .foregroundColor(.textSecondary)
                        
                        Button {
                            print("Qeydiyyat ekranı")
                        } label: {
                            Text("Qeydiyyatdan keç")
                                .font(.system(size: Typography.body, weight: .semibold))
                                .foregroundColor(.primaryRed)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Login Action
    private func loginAction() {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email və şifrə boş ola bilməz")
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            print("Giriş uğurlu: \(email)")
        }
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Layout.spacingM) {
            Image(systemName: icon)
                .foregroundColor(.textSecondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.textPrimary)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Layout.cornerRadiusM)
    }
}

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack(spacing: Layout.spacingM) {
            Image(systemName: "lock")
                .foregroundColor(.textSecondary)
                .frame(width: 20)
            
            if isVisible {
                TextField(placeholder, text: $text)
                    .foregroundColor(.textPrimary)
            } else {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.textPrimary)
            }
            
            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Layout.cornerRadiusM)
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
