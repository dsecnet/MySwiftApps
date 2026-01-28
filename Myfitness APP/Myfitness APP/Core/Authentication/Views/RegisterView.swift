//
//  RegisterView.swift
//  CoreVia
//
//  DÜZƏLDILMIŞ - Scroll problemi həll edildi!
//

import SwiftUI

struct RegisterView: View {
    
    @Binding var showRegister: Bool
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var userType: UserType = .client
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var acceptTerms: Bool = false
    
    enum UserType: String, CaseIterable {
        case client = "Müştəri"
        case trainer = "Müəllim"
        
        var icon: String {
            switch self {
            case .client: return "person.fill"
            case .trainer: return "person.2.fill"
            }
        }
        
        var description: String {
            switch self {
            case .client: return "Məşq və qida proqramları"
            case .trainer: return "Müştəri idarəsi və coaching"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // MARK: - Arxa Fon
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Header
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            showRegister = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Geri")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.black)
                
                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Başlıq
                        VStack(spacing: 8) {
                            Text("Qeydiyyat")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.white)
                            
                            Text("CoreVia ailəsinə qoşulun")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)
                        
                        // MARK: - User Type Seçimi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Hesab növü seçin")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 10) {
                                ForEach(UserType.allCases, id: \.self) { type in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            userType = type
                                        }
                                    } label: {
                                        VStack(spacing: 10) {
                                            ZStack {
                                                Circle()
                                                    .fill(userType == type ? Color.red.opacity(0.2) : Color.white.opacity(0.05))
                                                    .frame(width: 50, height: 50)
                                                
                                                Image(systemName: type.icon)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(userType == type ? .red : .gray)
                                            }
                                            
                                            VStack(spacing: 3) {
                                                Text(type.rawValue)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(userType == type ? .white : .gray)
                                                
                                                Text(type.description)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(userType == type ? Color.red.opacity(0.1) : Color.white.opacity(0.03))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(userType == type ? Color.red : Color.gray.opacity(0.2), lineWidth: userType == type ? 2 : 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Input Fields
                        VStack(spacing: 14) {
                            
                            // Ad Soyad
                            InputFieldCompact(
                                icon: "person.fill",
                                placeholder: "Ad və Soyad",
                                text: $name
                            )
                            
                            // Email
                            InputFieldCompact(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            // Şifrə
                            SecureFieldCompact(
                                icon: "lock.fill",
                                placeholder: "Şifrə (ən az 6 simvol)",
                                text: $password,
                                isVisible: $isPasswordVisible
                            )
                            
                            // Password strength
                            if !password.isEmpty {
                                HStack(spacing: 3) {
                                    ForEach(0..<3) { index in
                                        Rectangle()
                                            .fill(passwordStrength > index ? strengthColor : Color.gray.opacity(0.2))
                                            .frame(height: 3)
                                            .cornerRadius(1.5)
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                Text(strengthText)
                                    .font(.system(size: 11))
                                    .foregroundColor(strengthColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Şifrə Təkrarı
                            SecureFieldCompact(
                                icon: "lock.fill",
                                placeholder: "Şifrə təkrarı",
                                text: $confirmPassword,
                                isVisible: $isConfirmPasswordVisible
                            )
                            
                            // Match indicator
                            if !confirmPassword.isEmpty {
                                HStack(spacing: 5) {
                                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(passwordsMatch ? .green : .red)
                                        .font(.system(size: 12))
                                    
                                    Text(passwordsMatch ? "Şifrələr uyğundur" : "Şifrələr uyğun deyil")
                                        .font(.system(size: 11))
                                        .foregroundColor(passwordsMatch ? .green : .red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // MARK: - Terms
                        Button {
                            acceptTerms.toggle()
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.red, lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                    
                                    if acceptTerms {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                Text("Şərtlər və qaydalar ilə razıyam")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Error Message
                        if showError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // MARK: - Qeydiyyat Düyməsi
                        Button {
                            registerAction()
                        } label: {
                            HStack(spacing: 10) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Qeydiyyatdan keç")
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
                            .shadow(color: .red.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isLoading || !isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.5)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Computed Properties
    private var passwordStrength: Int {
        if password.count < 6 { return 0 }
        if password.count < 8 { return 1 }
        if password.count >= 8 && password.rangeOfCharacter(from: .decimalDigits) != nil { return 2 }
        return 3
    }
    
    private var strengthColor: Color {
        switch passwordStrength {
        case 0, 1: return .red
        case 2: return .orange
        case 3: return .green
        default: return .gray
        }
    }
    
    private var strengthText: String {
        switch passwordStrength {
        case 0, 1: return "Zəif şifrə"
        case 2: return "Orta güclü"
        case 3: return "Güclü şifrə"
        default: return ""
        }
    }
    
    private var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        passwordsMatch &&
        acceptTerms
    }
    
    // MARK: - Actions
    private func registerAction() {
        guard isFormValid else {
            showErrorMessage("Bütün sahələri düzgün doldurun")
            return
        }
        
        isLoading = true
        showError = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            print("✅ Qeydiyyat uğurlu!")
            print("Ad: \(name)")
            print("Email: \(email)")
            print("Tip: \(userType.rawValue)")
            
            withAnimation(.spring(response: 0.4)) {
                showRegister = false
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

// MARK: - Compact Input Components
struct InputFieldCompact: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 20)
                .font(.system(size: 14))
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .autocapitalization(.none)
                .keyboardType(keyboardType)
                .font(.system(size: 14))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(text.isEmpty ? Color.gray.opacity(0.2) : Color.red.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

struct SecureFieldCompact: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 20)
                .font(.system(size: 14))
            
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .foregroundColor(.white)
            .font(.system(size: 14))
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isVisible.toggle()
                }
            } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 13))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(text.isEmpty ? Color.gray.opacity(0.2) : Color.red.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    RegisterView(showRegister: .constant(true))
}
