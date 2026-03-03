import SwiftUI
import PhotosUI

// MARK: - Register View
struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var headerOpacity: Double = 0
    @State private var headerOffset: CGFloat = -15
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?

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
                            .frame(height: AppTheme.Spacing.lg)

                        // MARK: - Header
                        headerSection
                            .opacity(headerOpacity)
                            .offset(y: headerOffset)

                        // MARK: - Avatar Picker
                        avatarSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        // MARK: - Name Input
                        nameInputSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        // MARK: - Role Selection
                        roleSelectionSection
                            .opacity(contentOpacity)
                            .offset(y: contentOffset)

                        // MARK: - Error Message
                        if let error = viewModel.error {
                            errorBanner(message: error)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // MARK: - Create Profile Button
                        createProfileButton
                            .opacity(contentOpacity)

                        // MARK: - Terms
                        Text("terms_agree".localized)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)
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
        .onAppear {
            startEntranceAnimation()
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }

    // MARK: - Entrance Animation
    private func startEntranceAnimation() {
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            headerOpacity = 1.0
            headerOffset = 0
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

            Text("create_profile".localized)
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
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("create_profile".localized)
                .font(AppTheme.Fonts.heading2())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("welcome_subtitle".localized)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Avatar Section
    private var avatarSection: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack {
                if let selectedImage = selectedImage {
                    // Selected avatar image
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [AppTheme.Colors.accent, Color(hex: "0099CC")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                        )
                        .shadow(color: AppTheme.Colors.accent.opacity(0.2), radius: 8, x: 0, y: 4)
                } else {
                    // Default avatar placeholder
                    Circle()
                        .fill(AppTheme.Colors.cardBackground)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.Colors.accent.opacity(0.4),
                                            AppTheme.Colors.accent.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        )
                }

                // Camera badge
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.accent)
                        .frame(width: 32, height: 32)
                        .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 4, x: 0, y: 2)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .offset(x: 35, y: 35)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Name Input Section
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("full_name".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(
                        viewModel.fullName.isEmpty
                            ? AppTheme.Colors.textTertiary
                            : AppTheme.Colors.accent
                    )
                    .animation(.easeInOut(duration: 0.2), value: viewModel.fullName.isEmpty)

                TextField("", text: $viewModel.fullName)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                    .placeholder(when: viewModel.fullName.isEmpty) {
                        Text("full_name".localized)
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
                    .stroke(
                        viewModel.fullName.isEmpty
                            ? AppTheme.Colors.inputBorder
                            : AppTheme.Colors.inputBorderActive,
                        lineWidth: viewModel.fullName.isEmpty ? 1 : 1.5
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: viewModel.fullName.isEmpty)
        }
    }

    // MARK: - Role Selection Section
    private var roleSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("select_role".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                roleCard(
                    role: .user,
                    icon: "person.fill",
                    titleKey: "role_user",
                    description: "Ev axtaran"
                )

                roleCard(
                    role: .agent,
                    icon: "person.badge.key.fill",
                    titleKey: "role_agent",
                    description: "Pesekar makler"
                )

                roleCard(
                    role: .owner,
                    icon: "house.fill",
                    titleKey: "role_owner",
                    description: "Mulk sahibi"
                )
            }
        }
    }

    // MARK: - Role Card
    private func roleCard(role: UserRole, icon: String, titleKey: String, description: String) -> some View {
        let isSelected = viewModel.selectedRole == role

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedRole = role
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? AppTheme.Colors.accent.opacity(0.15)
                                : AppTheme.Colors.cardBackgroundLight
                        )
                        .frame(width: 52, height: 52)

                    if isSelected {
                        Circle()
                            .stroke(AppTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                            .frame(width: 52, height: 52)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(
                            isSelected
                                ? AppTheme.Colors.accent
                                : AppTheme.Colors.textTertiary
                        )
                }

                // Label
                Text(titleKey.localized)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(
                        isSelected
                            ? AppTheme.Colors.textPrimary
                            : AppTheme.Colors.textSecondary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .padding(.horizontal, AppTheme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(
                        isSelected
                            ? AppTheme.Colors.cardBackgroundLight
                            : AppTheme.Colors.cardBackground
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(
                        isSelected
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.inputBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppTheme.Colors.accent.opacity(0.15) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
            // Checkmark badge for selected state
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent)
                            .frame(width: 22, height: 22)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 6, y: -6)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Create Profile Button
    private var createProfileButton: some View {
        Button {
            hideKeyboard()
            viewModel.register()
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("create_profile".localized)
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
                viewModel.isRegisterValid
                    ? AppTheme.Colors.cyanGradient
                    : LinearGradient(
                        colors: [AppTheme.Colors.inputBackground, AppTheme.Colors.inputBackground],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(
                color: viewModel.isRegisterValid ? AppTheme.Colors.accent.opacity(0.3) : Color.clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(!viewModel.isRegisterValid || viewModel.isLoading)
        .padding(.top, AppTheme.Spacing.sm)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isRegisterValid)
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
}

// MARK: - Preview
#Preview {
    RegisterView(viewModel: AuthViewModel())
        .preferredColorScheme(.dark)
}
