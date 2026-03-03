import SwiftUI

// MARK: - OTP View
struct OTPView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isOTPFieldFocused: Bool

    @State private var headerOpacity: Double = 0
    @State private var headerOffset: CGFloat = -15
    @State private var boxesOpacity: Double = 0
    @State private var boxesScale: CGFloat = 0.9
    @State private var buttonsOpacity: Double = 0
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                navigationBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xxxl) {
                        Spacer()
                            .frame(height: AppTheme.Spacing.xl)

                        // MARK: - Header
                        headerSection
                            .opacity(headerOpacity)
                            .offset(y: headerOffset)

                        // MARK: - OTP Input
                        otpInputSection
                            .opacity(boxesOpacity)
                            .scaleEffect(boxesScale)
                            .offset(x: shakeOffset)

                        // MARK: - Timer & Resend
                        timerSection
                            .opacity(buttonsOpacity)

                        // MARK: - Verify Button
                        verifyButton
                            .opacity(buttonsOpacity)

                        // MARK: - Error Message
                        if let error = viewModel.error {
                            errorBanner(message: error)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .padding(.horizontal, AppTheme.Spacing.sm)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                }
            }

            // Hidden text field for OTP keyboard input
            TextField("", text: Binding(
                get: { viewModel.otpCode },
                set: { viewModel.formatOTPInput($0) }
            ))
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused($isOTPFieldFocused)
            .opacity(0)
            .frame(width: 0, height: 0)
        }
        .navigationBarHidden(true)
        .onAppear {
            isOTPFieldFocused = true
            startEntranceAnimation()
        }
        .onChange(of: viewModel.otpCode) { newValue in
            if newValue.count == 4 {
                viewModel.verifyOTP()
            }
        }
        .onChange(of: viewModel.error) { newError in
            if newError != nil {
                triggerShake()
            }
        }
        .sheet(isPresented: $viewModel.showRegister) {
            RegisterView(viewModel: viewModel)
        }
    }

    // MARK: - Entrance Animation
    private func startEntranceAnimation() {
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            headerOpacity = 1.0
            headerOffset = 0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            boxesOpacity = 1.0
            boxesScale = 1.0
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
            buttonsOpacity = 1.0
        }
    }

    // MARK: - Shake Animation
    private func triggerShake() {
        withAnimation(.default) {
            shakeOffset = -10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.default) {
                shakeOffset = 10
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.default) {
                shakeOffset = -6
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            withAnimation(.default) {
                shakeOffset = 6
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            withAnimation(.spring()) {
                shakeOffset = 0
            }
        }
    }

    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Button {
                viewModel.resetState()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.cardBackground)
                    )
            }

            Spacer()

            Text("verification".localized)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Shield icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.accent.opacity(0.15),
                                AppTheme.Colors.accent.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 45
                        )
                    )
                    .frame(width: 88, height: 88)

                Circle()
                    .stroke(AppTheme.Colors.accent.opacity(0.2), lineWidth: 1)
                    .frame(width: 88, height: 88)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent, Color(hex: "0099CC")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("enter_verification_code".localized)
                    .font(AppTheme.Fonts.heading2())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                HStack(spacing: AppTheme.Spacing.xs) {
                    Text("code_sent_to".localized)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textSecondary)

                    Text(viewModel.maskedPhoneNumber)
                        .font(AppTheme.Fonts.bodyBold())
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
    }

    // MARK: - OTP Input Section
    private var otpInputSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ForEach(0..<4, id: \.self) { index in
                otpDigitBox(at: index)
            }
        }
        .onTapGesture {
            isOTPFieldFocused = true
        }
    }

    // MARK: - Single OTP Digit Box
    private func otpDigitBox(at index: Int) -> some View {
        let digit = digitAt(index)
        let isActive = index == viewModel.otpCode.count && isOTPFieldFocused
        let isFilled = index < viewModel.otpCode.count

        return ZStack {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.inputBackground)
                .frame(width: 68, height: 68)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(
                            isActive ? AppTheme.Colors.accent :
                            isFilled ? AppTheme.Colors.accent.opacity(0.5) :
                            AppTheme.Colors.inputBorder,
                            lineWidth: isActive ? 2 : 1
                        )
                )
                .shadow(
                    color: isActive ? AppTheme.Colors.accent.opacity(0.15) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 2
                )

            if let digit = digit {
                Text(digit)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .transition(.scale.combined(with: .opacity))
            }

            // Cursor blink for active box
            if isActive {
                RoundedRectangle(cornerRadius: 1)
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 2, height: 28)
                    .modifier(BlinkingModifier())
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isFilled)
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }

    // MARK: - Timer Section
    private var timerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if !viewModel.canResendOTP {
                // Circular timer indicator
                HStack(spacing: AppTheme.Spacing.sm) {
                    ZStack {
                        Circle()
                            .stroke(AppTheme.Colors.inputBorder, lineWidth: 2)
                            .frame(width: 22, height: 22)

                        Circle()
                            .trim(from: 0, to: CGFloat(viewModel.otpTimerRemaining) / 60.0)
                            .stroke(AppTheme.Colors.accent, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 22, height: 22)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: viewModel.otpTimerRemaining)
                    }

                    Text(timerText)
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .monospacedDigit()
                }
            }

            // Resend section
            HStack(spacing: AppTheme.Spacing.xs) {
                Text("didnt_receive_code".localized)
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Button {
                    viewModel.resendOTP()
                } label: {
                    Text("resend_code".localized)
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(
                            viewModel.canResendOTP
                                ? AppTheme.Colors.accent
                                : AppTheme.Colors.textTertiary
                        )
                        .underline(viewModel.canResendOTP)
                }
                .disabled(!viewModel.canResendOTP)
            }
        }
    }

    // MARK: - Verify Button
    private var verifyButton: some View {
        Button {
            hideKeyboard()
            viewModel.verifyOTP()
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("verify".localized)
                            .font(AppTheme.Fonts.bodyBold())
                            .foregroundColor(.white)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                viewModel.isOTPComplete
                    ? AppTheme.Colors.cyanGradient
                    : LinearGradient(
                        colors: [AppTheme.Colors.inputBackground, AppTheme.Colors.inputBackground],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(
                color: viewModel.isOTPComplete ? AppTheme.Colors.accent.opacity(0.3) : Color.clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(!viewModel.isOTPComplete || viewModel.isLoading)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isOTPComplete)
    }

    // MARK: - Error Banner
    private func errorBanner(message: String) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.error)

            Text(message)
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.error)
                .multilineTextAlignment(.leading)
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .fill(AppTheme.Colors.error.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(AppTheme.Colors.error.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Helpers

    private func digitAt(_ index: Int) -> String? {
        guard index < viewModel.otpCode.count else { return nil }
        let stringIndex = viewModel.otpCode.index(viewModel.otpCode.startIndex, offsetBy: index)
        return String(viewModel.otpCode[stringIndex])
    }

    private var timerText: String {
        let minutes = viewModel.otpTimerRemaining / 60
        let seconds = viewModel.otpTimerRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Blinking Cursor Modifier
struct BlinkingModifier: ViewModifier {
    @State private var isVisible = true

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isVisible = false
                }
            }
    }
}

// MARK: - Preview
#Preview {
    OTPView(viewModel: AuthViewModel())
        .preferredColorScheme(.dark)
}
