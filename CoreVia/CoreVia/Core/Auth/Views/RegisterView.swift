
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

    // OTP Step
    @State private var currentStep: Int = 1 // 1: Form, 2: OTP Verification
    @State private var otpCode: String = ""

    @ObservedObject private var loc = LocalizationManager.shared

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
            case .client: return LocalizationManager.shared.localized("register_client_desc")
            case .trainer: return LocalizationManager.shared.localized("register_trainer_desc")
            }
        }

        var localizedName: String {
            let loc = LocalizationManager.shared
            switch self {
            case .client: return loc.localized("login_student")
            case .trainer: return loc.localized("login_teacher")
            }
        }
    }
    
    var body: some View {
        ZStack {
            // MARK: - Arxa Fon (Adaptiv)
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if currentStep == 1 {
                            // Step 1: Form
                            titleSection
                            userTypeSelection
                            inputFields
                            termsCheckbox

                            if showError {
                                errorView
                            }

                            sendOTPButton
                        } else {
                            // Step 2: OTP Verification
                            otpVerificationSection
                        }
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button {
                withAnimation(.spring()) {
                    showRegister = false
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text(loc.localized("common_back"))
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(AppTheme.Colors.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.background)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(loc.localized("register_title"))
                .font(.system(size: 32, weight: .black))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text(loc.localized("register_subtitle"))
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .padding(.top, 10)
    }
    
    // MARK: - User Type Selection
    private var userTypeSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("register_select_type"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 10) {
                ForEach(UserType.allCases, id: \.self) { type in
                    userTypeButton(for: type)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func userTypeButton(for type: UserType) -> some View {
        Button {
            withAnimation(.spring()) {
                userType = type
            }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(userType == type ? AppTheme.Colors.accent.opacity(0.2) : AppTheme.Colors.secondaryBackground)
                        .frame(width: 50, height: 50)

                    Image(systemName: type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(userType == type ? AppTheme.Colors.accent : AppTheme.Colors.secondaryText)
                }
                
                VStack(spacing: 3) {
                    Text(type.localizedName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(userType == type ? AppTheme.Colors.primaryText : AppTheme.Colors.secondaryText)
                    
                    Text(type.description)
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(userType == type ? AppTheme.Colors.accent.opacity(0.1) : AppTheme.Colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(userType == type ? AppTheme.Colors.accent : AppTheme.Colors.separator, lineWidth: userType == type ? 2 : 1)
            )
        }
    }
    
    // MARK: - Input Fields
    private var inputFields: some View {
        VStack(spacing: 14) {
            InputFieldCompact(
                icon: "person.fill",
                placeholder: loc.localized("register_name"),
                text: $name
            )
            
            InputFieldCompact(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            
            SecureFieldCompact(
                icon: "lock.fill",
                placeholder: loc.localized("common_password"),
                text: $password,
                isVisible: $isPasswordVisible
            )
            
            if !password.isEmpty {
                passwordStrengthIndicator
            }
            
            SecureFieldCompact(
                icon: "lock.fill",
                placeholder: loc.localized("register_password_repeat"),
                text: $confirmPassword,
                isVisible: $isConfirmPasswordVisible
            )
            
            if !confirmPassword.isEmpty {
                passwordMatchIndicator
            }
        }
    }
    
    // MARK: - Password Strength
    private var passwordStrengthIndicator: some View {
        VStack(spacing: 6) {
            HStack(spacing: 3) {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(passwordStrength > index ? strengthColor : AppTheme.Colors.separator)
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
    }
    
    // MARK: - Password Match
    private var passwordMatchIndicator: some View {
        HStack(spacing: 5) {
            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(passwordsMatch ? AppTheme.Colors.success : AppTheme.Colors.error)
                .font(.system(size: 12))

            Text(passwordsMatch ? loc.localized("register_passwords_match") : loc.localized("register_passwords_mismatch"))
                .font(.system(size: 11))
                .foregroundColor(passwordsMatch ? AppTheme.Colors.success : AppTheme.Colors.error)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Terms Checkbox
    private var termsCheckbox: some View {
        Button {
            acceptTerms.toggle()
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(AppTheme.Colors.accent, lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if acceptTerms {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                
                Text(loc.localized("register_terms"))
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Error View
    private var errorView: some View {
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
        .padding(.horizontal, 20)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Register Button
    private var registerButton: some View {
        Button {
            registerAction()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(loc.localized("register_button"))
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
            .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
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
        case 0, 1: return AppTheme.Colors.error
        case 2: return AppTheme.Colors.warning
        case 3: return AppTheme.Colors.success
        default: return AppTheme.Colors.secondaryText
        }
    }
    
    private var strengthText: String {
        switch passwordStrength {
        case 0, 1: return loc.localized("register_weak_password")
        case 2: return loc.localized("register_medium_password")
        case 3: return loc.localized("register_strong_password")
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

        let backendUserType = userType == .client ? "client" : "trainer"

        Task {
            let success = await AuthManager.shared.register(
                name: name,
                email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                password: password,
                userType: backendUserType
            )

            await MainActor.run {
                isLoading = false
                if success {
                    withAnimation(.spring()) {
                        showRegister = false
                    }
                } else {
                    showErrorMessage(AuthManager.shared.errorMessage ?? "Qeydiyyat uğursuz oldu")
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

    // MARK: - OTP Actions

    private var sendOTPButton: some View {
        Button {
            sendOTPAction()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("OTP Göndər")
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
            .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }

    private var otpVerificationSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("OTP Kodu")
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
                errorView
            }

            // Verify Button
            Button {
                verifyOTPAndRegister()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Təsdiq Et və Qeydiyyatdan Keç")
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
            .padding(.horizontal, 20)

            // Resend OTP
            Button {
                sendOTPAction()
            } label: {
                Text("OTP-ni yenidən göndər")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.accent)
            }

            Spacer()
        }
    }

    private func sendOTPAction() {
        guard isFormValid else {
            showErrorMessage("Bütün sahələri düzgün doldurun")
            return
        }

        isLoading = true
        showError = false

        Task {
            do {
                // Step 1: Request OTP
                let url = URL(string: "\(APIService.shared.baseURL)/auth/register-request")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: String] = ["email": email.trimmingCharacters(in: .whitespaces).lowercased()]
                request.httpBody = try JSONEncoder().encode(body)

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }

                if httpResponse.statusCode == 200 {
                    await MainActor.run {
                        isLoading = false
                        withAnimation {
                            currentStep = 2
                        }
                    }
                } else {
                    let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                    throw NSError(domain: errorResponse?["detail"] ?? "OTP göndərilmədi", code: httpResponse.statusCode)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showErrorMessage(error.localizedDescription)
                }
            }
        }
    }

    private func verifyOTPAndRegister() {
        isLoading = true
        showError = false

        let backendUserType = userType == .client ? "client" : "trainer"

        Task {
            do {
                let url = URL(string: "\(APIService.shared.baseURL)/auth/register")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: String] = [
                    "name": name,
                    "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
                    "password": password,
                    "user_type": backendUserType,
                    "otp_code": otpCode
                ]
                request.httpBody = try JSONEncoder().encode(body)

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }

                if httpResponse.statusCode == 201 {
                    await MainActor.run {
                        isLoading = false
                        withAnimation(.spring()) {
                            showRegister = false
                        }
                    }
                } else {
                    let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                    throw NSError(domain: errorResponse?["detail"] ?? "Qeydiyyat uğursuz oldu", code: httpResponse.statusCode)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showErrorMessage(error.localizedDescription)
                }
            }
        }
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
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 20)
                .font(.system(size: 14))

            TextField(placeholder, text: $text)
                .foregroundColor(AppTheme.Colors.primaryText)
                .autocapitalization(.none)
                .keyboardType(keyboardType)
                .font(.system(size: 14))
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(text.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
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
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 20)
                .font(.system(size: 14))

            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .foregroundColor(AppTheme.Colors.primaryText)
            .font(.system(size: 14))
            
            Button {
                withAnimation(.spring()) {
                    isVisible.toggle()
                }
            } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .font(.system(size: 13))
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(text.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// #Preview { // iOS 17+ only
//     RegisterView(showRegister: .constant(true))
// }
