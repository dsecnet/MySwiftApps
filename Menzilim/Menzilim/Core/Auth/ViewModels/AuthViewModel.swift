import SwiftUI
import Combine

// MARK: - Auth Step
enum AuthStep: Equatable {
    case phone
    case otp
    case register
}

// MARK: - Auth ViewModel
@MainActor
class AuthViewModel: ObservableObject {

    // MARK: - Published Properties

    // Phone entry
    @Published var phone: String = ""
    @Published var phoneCode: String = "+994"

    // OTP verification
    @Published var otpCode: String = ""
    @Published var otpTimerRemaining: Int = 60
    @Published var canResendOTP: Bool = false

    // Registration
    @Published var fullName: String = ""
    @Published var selectedRole: UserRole = .user

    // State management
    @Published var currentStep: AuthStep = .phone
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isNewUser: Bool = false

    // Navigation triggers
    @Published var showOTP: Bool = false
    @Published var showRegister: Bool = false

    // MARK: - Private
    private var otpTimer: AnyCancellable?
    private let authManager = AuthManager.shared

    // MARK: - Computed Properties

    /// Full phone number with country code (digits only)
    var fullPhoneNumber: String {
        let digits = phone.filter { $0.isNumber }
        return phoneCode + digits
    }

    /// Masked phone number for display (e.g., +994 50 *** ** 67)
    var maskedPhoneNumber: String {
        let digits = phone.filter { $0.isNumber }
        guard digits.count >= 4 else { return fullPhoneNumber }

        let prefix = String(digits.prefix(2))
        let suffix = String(digits.suffix(2))
        return "\(phoneCode) \(prefix) *** ** \(suffix)"
    }

    /// Formatted phone for display in input field
    var formattedPhone: String {
        let digits = phone.filter { $0.isNumber }
        guard !digits.isEmpty else { return "" }

        var result = ""
        for (index, char) in digits.enumerated() {
            if index == 2 || index == 5 || index == 7 {
                result.append(" ")
            }
            result.append(char)
            if index >= 8 { break }
        }
        return result
    }

    /// Whether the phone number is valid (9 digits for Azerbaijan)
    var isPhoneValid: Bool {
        let digits = phone.filter { $0.isNumber }
        return digits.count >= 9
    }

    /// Whether the OTP code is complete (4 digits)
    var isOTPComplete: Bool {
        return otpCode.count == 4
    }

    /// Whether the registration form is valid
    var isRegisterValid: Bool {
        return !fullName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Send OTP

    func sendOTP() {
        guard isPhoneValid else {
            error = "error".localized
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                try await authManager.sendOTP(phone: fullPhoneNumber)
                currentStep = .otp
                showOTP = true
                startOTPTimer()
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Verify OTP

    func verifyOTP() {
        guard isOTPComplete else { return }

        isLoading = true
        error = nil

        Task {
            do {
                let newUser = try await authManager.verifyOTP(phone: fullPhoneNumber, code: otpCode)
                isNewUser = newUser

                if newUser {
                    currentStep = .register
                    showRegister = true
                } else {
                    // Existing user: complete login
                    try await authManager.login(phone: fullPhoneNumber, code: otpCode)
                }
            } catch {
                self.error = error.localizedDescription
                otpCode = ""
            }
            isLoading = false
        }
    }

    // MARK: - Register

    func register() {
        guard isRegisterValid else { return }

        isLoading = true
        error = nil

        Task {
            do {
                try await authManager.register(
                    phone: fullPhoneNumber,
                    code: otpCode,
                    fullName: fullName.trimmingCharacters(in: .whitespaces),
                    role: selectedRole
                )
                // Auth state will change to .authenticated automatically via AuthManager
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Login (direct, if needed)

    func login() {
        guard isOTPComplete else { return }

        isLoading = true
        error = nil

        Task {
            do {
                try await authManager.login(phone: fullPhoneNumber, code: otpCode)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - OTP Timer

    func startOTPTimer() {
        otpTimerRemaining = 60
        canResendOTP = false
        otpTimer?.cancel()

        otpTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.otpTimerRemaining > 0 {
                    self.otpTimerRemaining -= 1
                } else {
                    self.canResendOTP = true
                    self.otpTimer?.cancel()
                }
            }
    }

    func resendOTP() {
        guard canResendOTP else { return }
        otpCode = ""
        error = nil
        sendOTP()
    }

    // MARK: - Phone Formatting Helpers

    func formatPhoneInput(_ newValue: String) {
        // Strip non-digits and limit to 9 characters
        let digits = newValue.filter { $0.isNumber }
        if digits.count <= 9 {
            phone = digits
        } else {
            phone = String(digits.prefix(9))
        }
    }

    func formatOTPInput(_ newValue: String) {
        let digits = newValue.filter { $0.isNumber }
        if digits.count <= 4 {
            otpCode = digits
        } else {
            otpCode = String(digits.prefix(4))
        }
    }

    // MARK: - Navigation Helpers

    /// Go back one step in the auth flow
    func goBack() {
        error = nil
        switch currentStep {
        case .phone:
            break
        case .otp:
            currentStep = .phone
            showOTP = false
            resetOTPState()
        case .register:
            currentStep = .otp
            showRegister = false
        }
    }

    // MARK: - Reset

    func resetState() {
        otpCode = ""
        error = nil
        otpTimer?.cancel()
        canResendOTP = false
        otpTimerRemaining = 60
    }

    private func resetOTPState() {
        otpCode = ""
        otpTimer?.cancel()
        canResendOTP = false
        otpTimerRemaining = 60
    }

    /// Full reset back to phone step
    func resetToStart() {
        phone = ""
        otpCode = ""
        fullName = ""
        selectedRole = .user
        currentStep = .phone
        isLoading = false
        error = nil
        isNewUser = false
        showOTP = false
        showRegister = false
        otpTimer?.cancel()
        canResendOTP = false
        otpTimerRemaining = 60
    }

    deinit {
        otpTimer?.cancel()
    }
}
