import SwiftUI

// MARK: - Login View
struct LoginView: View {
    @StateObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var iconOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    @State private var navigateToRegister = false
    @State private var showPassword = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        Spacer().frame(height: AppTheme.Spacing.xl)

                        buildingIcon
                            .opacity(iconOpacity)
                            .scaleEffect(iconScale)

                        headerSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        emailInputSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        passwordInputSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        loginButton
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        if let error = viewModel.error {
                            errorBanner(message: error)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        termsSection
                            .opacity(contentOpacity)

                        registerLink
                            .opacity(contentOpacity)

                        Spacer().frame(height: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture { hideKeyboard() }
        .navigationDestination(isPresented: $navigateToRegister) {
            RegisterView(viewModel: viewModel)
        }
        .onAppear { startEntranceAnimation() }
    }

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
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(AppTheme.Colors.cardBackground))
            }
            Spacer()
            Text("sign_in".localized)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Building Icon
    private var buildingIcon: some View {
        Image("app_logo")
            .resizable()
            .scaledToFit()
            .frame(width: 88, height: 88)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("welcome".localized)
                .font(AppTheme.Fonts.heading2())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            Text("login_subtitle".localized)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Email Input
    private var emailInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("email".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.email.isEmpty ? AppTheme.Colors.textTertiary : AppTheme.Colors.accent)

                TextField("", text: $viewModel.email)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .placeholder(when: viewModel.email.isEmpty) {
                        Text("email_placeholder".localized)
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .frame(height: 54)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(viewModel.email.isEmpty ? AppTheme.Colors.inputBorder : AppTheme.Colors.inputBorderActive, lineWidth: viewModel.email.isEmpty ? 1 : 1.5)
            )
        }
    }

    // MARK: - Password Input
    private var passwordInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("password".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.password.isEmpty ? AppTheme.Colors.textTertiary : AppTheme.Colors.accent)

                if showPassword {
                    TextField("", text: $viewModel.password)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .placeholder(when: viewModel.password.isEmpty) {
                            Text("password_placeholder".localized).font(AppTheme.Fonts.body()).foregroundColor(AppTheme.Colors.textTertiary)
                        }
                } else {
                    SecureField("", text: $viewModel.password)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .textContentType(.password)
                        .placeholder(when: viewModel.password.isEmpty) {
                            Text("password_placeholder".localized).font(AppTheme.Fonts.body()).foregroundColor(AppTheme.Colors.textTertiary)
                        }
                }

                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .frame(height: 54)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(viewModel.password.isEmpty ? AppTheme.Colors.inputBorder : AppTheme.Colors.inputBorderActive, lineWidth: viewModel.password.isEmpty ? 1 : 1.5)
            )
        }
    }

    // MARK: - Login Button
    private var loginButton: some View {
        Button {
            hideKeyboard()
            viewModel.login()
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("sign_in".localized).font(AppTheme.Fonts.bodyBold()).foregroundColor(.white)
                        Image(systemName: "arrow.right.circle.fill").font(.system(size: 18)).foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(viewModel.isLoginFormValid ? AppTheme.Colors.cyanGradient : LinearGradient(colors: [AppTheme.Colors.inputBackground, AppTheme.Colors.inputBackground], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: viewModel.isLoginFormValid ? AppTheme.Colors.accent.opacity(0.3) : Color.clear, radius: 12, x: 0, y: 6)
        }
        .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)
        .padding(.top, AppTheme.Spacing.sm)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoginFormValid)
    }

    // MARK: - Error Banner
    private func errorBanner(message: String) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.circle.fill").font(.system(size: 16)).foregroundColor(AppTheme.Colors.error)
            Text(message).font(AppTheme.Fonts.caption()).foregroundColor(AppTheme.Colors.error).multilineTextAlignment(.leading)
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .fill(AppTheme.Colors.error.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small).stroke(AppTheme.Colors.error.opacity(0.3), lineWidth: 1))
        )
    }

    // MARK: - Terms
    private var termsSection: some View {
        Text("terms_agree".localized)
            .font(AppTheme.Fonts.small())
            .foregroundColor(AppTheme.Colors.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: - Register Link
    private var registerLink: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text("no_account".localized).font(AppTheme.Fonts.caption()).foregroundColor(AppTheme.Colors.textSecondary)
            Button { navigateToRegister = true } label: {
                Text("create_profile".localized).font(AppTheme.Fonts.captionBold()).foregroundColor(AppTheme.Colors.accent)
            }
        }
        .padding(.top, AppTheme.Spacing.sm)
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
