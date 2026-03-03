import SwiftUI

// MARK: - Login View
struct LoginView: View {
    @StateObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var iconOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                navigationBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        Spacer()
                            .frame(height: AppTheme.Spacing.xl)

                        // MARK: - Building Icon
                        buildingIcon
                            .opacity(iconOpacity)
                            .scaleEffect(iconScale)

                        // MARK: - Header
                        headerSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        // MARK: - Phone Input
                        phoneInputSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        // MARK: - Send Code Button
                        sendCodeButton
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        // MARK: - Error Message
                        if let error = viewModel.error {
                            errorBanner(message: error)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // MARK: - Terms
                        termsSection
                            .opacity(contentOpacity)

                        Spacer()
                            .frame(height: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $viewModel.showOTP) {
            OTPView(viewModel: viewModel)
        }
        .onAppear {
            startEntranceAnimation()
        }
    }

    // MARK: - Entrance Animation
    private func startEntranceAnimation() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
            iconOpacity = 1.0
            iconScale = 1.0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
            contentOpacity = 1.0
            contentOffset = 0
        }
    }

    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Button {
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

            Text("sign_in".localized)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            // Invisible spacer for centering
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Building Icon
    private var buildingIcon: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(AppTheme.Colors.accent.opacity(0.08))
                .frame(width: 100, height: 100)
                .blur(radius: 8)

            // Icon background
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

            // Border ring
            Circle()
                .stroke(AppTheme.Colors.accent.opacity(0.2), lineWidth: 1)
                .frame(width: 88, height: 88)

            Image(systemName: "building.2.fill")
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
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("welcome".localized)
                .font(AppTheme.Fonts.heading2())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("welcome_subtitle".localized)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Phone Input Section
    private var phoneInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("phone_number".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                // Country Code Picker
                Menu {
                    Button("+994 AZ") {
                        viewModel.phoneCode = "+994"
                    }
                    Button("+7 RU") {
                        viewModel.phoneCode = "+7"
                    }
                    Button("+90 TR") {
                        viewModel.phoneCode = "+90"
                    }
                    Button("+995 GE") {
                        viewModel.phoneCode = "+995"
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(flagForCode(viewModel.phoneCode))
                            .font(.system(size: 20))

                        Text(viewModel.phoneCode)
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .frame(height: 54)
                    .background(AppTheme.Colors.inputBackground)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                    )
                }

                // Phone Number Field
                TextField("", text: Binding(
                    get: { viewModel.formattedPhone },
                    set: { viewModel.formatPhoneInput($0) }
                ))
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                .placeholder(when: viewModel.phone.isEmpty) {
                    Text("XX XXX XX XX")
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .frame(height: 54)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(
                            viewModel.phone.isEmpty
                                ? AppTheme.Colors.inputBorder
                                : AppTheme.Colors.inputBorderActive,
                            lineWidth: viewModel.phone.isEmpty ? 1 : 1.5
                        )
                )
            }
        }
    }

    // MARK: - Send Code Button
    private var sendCodeButton: some View {
        Button {
            hideKeyboard()
            viewModel.sendOTP()
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("send_code".localized)
                            .font(AppTheme.Fonts.bodyBold())
                            .foregroundColor(.white)

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                viewModel.isPhoneValid
                    ? AppTheme.Colors.cyanGradient
                    : LinearGradient(
                        colors: [AppTheme.Colors.inputBackground, AppTheme.Colors.inputBackground],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(
                color: viewModel.isPhoneValid ? AppTheme.Colors.accent.opacity(0.3) : Color.clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(!viewModel.isPhoneValid || viewModel.isLoading)
        .padding(.top, AppTheme.Spacing.sm)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isPhoneValid)
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

    // MARK: - Terms Section
    private var termsSection: some View {
        Text("terms_agree".localized)
            .font(AppTheme.Fonts.small())
            .foregroundColor(AppTheme.Colors.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: - Flag Helper
    private func flagForCode(_ code: String) -> String {
        switch code {
        case "+994": return "\u{1F1E6}\u{1F1FF}"
        case "+7": return "\u{1F1F7}\u{1F1FA}"
        case "+90": return "\u{1F1F9}\u{1F1F7}"
        case "+995": return "\u{1F1EC}\u{1F1EA}"
        default: return "\u{1F1E6}\u{1F1FF}"
        }
    }
}

// MARK: - Placeholder Modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        LoginView(viewModel: AuthViewModel())
    }
    .preferredColorScheme(.dark)
}
