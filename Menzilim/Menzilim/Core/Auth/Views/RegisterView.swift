import SwiftUI
import PhotosUI

// MARK: - Register View
struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        Spacer().frame(height: AppTheme.Spacing.lg)

                        avatarSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        nameInputSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        roleSelectionSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        emailInputSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        passwordInputSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        confirmPasswordInputSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        if let error = viewModel.error {
                            errorBanner(message: error)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        registerButton
                            .opacity(contentOpacity)

                        Text("terms_agree".localized)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .opacity(contentOpacity)

                        loginLink
                            .opacity(contentOpacity)

                        Spacer().frame(height: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture { hideKeyboard() }
        .onAppear { startEntranceAnimation() }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }

    private func startEntranceAnimation() {
        withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
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
            Text("create_profile".localized)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }

// MARK: - Avatar
    private var avatarSection: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(
                                LinearGradient(colors: [AppTheme.Colors.accent, Color(hex: "0099CC")], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2.5
                            )
                        )
                } else {
                    Circle()
                        .fill(AppTheme.Colors.cardBackground)
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(AppTheme.Colors.accent.opacity(0.3), lineWidth: 2))
                        .overlay(Image(systemName: "person.fill").font(.system(size: 36)).foregroundColor(AppTheme.Colors.textTertiary))
                }
                ZStack {
                    Circle().fill(AppTheme.Colors.accent).frame(width: 32, height: 32)
                    Image(systemName: "camera.fill").font(.system(size: 14)).foregroundColor(.white)
                }
                .offset(x: 35, y: 35)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Name Input
    private var nameInputSection: some View {
        inputField(
            label: "full_name",
            icon: "person.fill",
            text: $viewModel.fullName,
            placeholder: "full_name",
            contentType: .name,
            isEmpty: viewModel.fullName.isEmpty
        )
    }

    // MARK: - Email Input
    private var emailInputSection: some View {
        inputField(
            label: "email",
            icon: "envelope.fill",
            text: $viewModel.email,
            placeholder: "email_placeholder",
            contentType: .emailAddress,
            isEmpty: viewModel.email.isEmpty,
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
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
                        .textContentType(.newPassword)
                        .autocorrectionDisabled()
                        .placeholder(when: viewModel.password.isEmpty) {
                            Text("password_placeholder".localized).font(AppTheme.Fonts.body()).foregroundColor(AppTheme.Colors.textTertiary)
                        }
                } else {
                    SecureField("", text: $viewModel.password)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .textContentType(.newPassword)
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

    // MARK: - Confirm Password Input
    private var confirmPasswordInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("confirm_password".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.confirmPassword.isEmpty ? AppTheme.Colors.textTertiary : (viewModel.doPasswordsMatch ? AppTheme.Colors.success : AppTheme.Colors.error))

                if showConfirmPassword {
                    TextField("", text: $viewModel.confirmPassword)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled()
                        .placeholder(when: viewModel.confirmPassword.isEmpty) {
                            Text("confirm_password_placeholder".localized).font(AppTheme.Fonts.body()).foregroundColor(AppTheme.Colors.textTertiary)
                        }
                } else {
                    SecureField("", text: $viewModel.confirmPassword)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .textContentType(.newPassword)
                        .placeholder(when: viewModel.confirmPassword.isEmpty) {
                            Text("confirm_password_placeholder".localized).font(AppTheme.Fonts.body()).foregroundColor(AppTheme.Colors.textTertiary)
                        }
                }

                Button { showConfirmPassword.toggle() } label: {
                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
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
                    .stroke(viewModel.confirmPassword.isEmpty ? AppTheme.Colors.inputBorder : (viewModel.doPasswordsMatch ? AppTheme.Colors.success : AppTheme.Colors.error), lineWidth: viewModel.confirmPassword.isEmpty ? 1 : 1.5)
            )
        }
    }

    // MARK: - Role Selection
    private var roleSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("select_role".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.sm) {
                rolePill(role: .owner, titleKey: "role_owner")
                rolePill(role: .agent, titleKey: "role_agent")
            }
        }
    }

    // MARK: - Role Pill
    private func rolePill(role: UserRole, titleKey: String) -> some View {
        let isSelected = viewModel.selectedRole == role
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedRole = role }
        } label: {
            Text(titleKey.localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    Capsule().fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground)
                )
                .overlay(
                    Capsule().stroke(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Register Button
    private var registerButton: some View {
        Button {
            hideKeyboard()
            viewModel.register()
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("create_profile".localized).font(AppTheme.Fonts.bodyBold()).foregroundColor(.white)
                        Image(systemName: "arrow.right.circle.fill").font(.system(size: 18)).foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(viewModel.isRegisterFormValid ? AppTheme.Colors.cyanGradient : LinearGradient(colors: [AppTheme.Colors.inputBackground, AppTheme.Colors.inputBackground], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: viewModel.isRegisterFormValid ? AppTheme.Colors.accent.opacity(0.3) : Color.clear, radius: 12, x: 0, y: 6)
        }
        .disabled(!viewModel.isRegisterFormValid || viewModel.isLoading)
        .padding(.top, AppTheme.Spacing.sm)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isRegisterFormValid)
    }

    // MARK: - Login Link
    private var loginLink: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text("already_have_account".localized).font(AppTheme.Fonts.caption()).foregroundColor(AppTheme.Colors.textSecondary)
            Button { dismiss() } label: {
                Text("sign_in".localized).font(AppTheme.Fonts.captionBold()).foregroundColor(AppTheme.Colors.accent)
            }
        }
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Reusable Input Field
    private func inputField(label: String, icon: String, text: Binding<String>, placeholder: String, contentType: UITextContentType, isEmpty: Bool, keyboardType: UIKeyboardType = .default, autocapitalization: TextInputAutocapitalization = .sentences) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label.localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon).font(.system(size: 16))
                    .foregroundColor(isEmpty ? AppTheme.Colors.textTertiary : AppTheme.Colors.accent)

                TextField("", text: text)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
                    .placeholder(when: isEmpty) {
                        Text(placeholder.localized).font(AppTheme.Fonts.body()).foregroundColor(AppTheme.Colors.textTertiary)
                    }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .frame(height: 54)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isEmpty ? AppTheme.Colors.inputBorder : AppTheme.Colors.inputBorderActive, lineWidth: isEmpty ? 1 : 1.5)
            )
        }
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
}

// MARK: - Preview
#Preview {
    RegisterView(viewModel: AuthViewModel())
        .preferredColorScheme(.dark)
}
