import SwiftUI

// MARK: - Profile Edit View
struct ProfileEditView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var isShowingImagePicker: Bool = false
    @State private var isSaving: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppTheme.Spacing.xxl) {
                    // MARK: - Avatar Picker
                    avatarSection

                    // MARK: - Form Fields
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Full Name
                        formField(
                            label: "full_name".localized,
                            icon: "person.fill",
                            text: $fullName,
                            placeholder: "full_name".localized,
                            isEditable: true
                        )

                        // Email
                        formField(
                            label: "E-mail",
                            icon: "envelope.fill",
                            text: $email,
                            placeholder: "email@example.com",
                            isEditable: true,
                            keyboardType: .emailAddress
                        )

                        // Phone (read-only)
                        readOnlyField(
                            label: "phone_number".localized,
                            icon: "phone.fill",
                            value: viewModel.currentUser.phone
                        )
                    }

                    // MARK: - Save Button
                    saveButton

                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("personal_info".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
            .onAppear {
                fullName = viewModel.currentUser.fullName
                email = viewModel.currentUser.email ?? ""
            }
        }
    }

    // MARK: - Avatar Section
    private var avatarSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: viewModel.currentUser.avatarUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Circle()
                            .fill(AppTheme.Colors.surfaceBackground)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            )
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppTheme.Colors.accent, lineWidth: 2)
                )

                // Camera button
                Button {
                    isShowingImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent)
                            .frame(width: 32, height: 32)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 4, y: 4)
            }

            Text("Profil şəklini dəyiş")
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.accent)
        }
    }

    // MARK: - Form Field
    private func formField(
        label: String,
        icon: String,
        text: Binding<String>,
        placeholder: String,
        isEditable: Bool,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Fonts.smallBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .frame(width: 24)

                TextField(placeholder, text: text)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .disabled(!isEditable)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Read Only Field
    private func readOnlyField(label: String, icon: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Fonts.smallBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .frame(width: 24)

                Text(value)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.inputBackground.opacity(0.5))
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder.opacity(0.5), lineWidth: 1)
            )
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            isSaving = true
            viewModel.updateProfile(
                fullName: fullName,
                email: email.isEmpty ? nil : email
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSaving = false
                dismiss()
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text("save".localized)
                    .font(AppTheme.Fonts.bodyBold())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                fullName.isEmpty
                    ? AppTheme.Colors.accent.opacity(0.4)
                    : AppTheme.Colors.accent
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .disabled(fullName.isEmpty || isSaving)
        .padding(.top, AppTheme.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    ProfileEditView(viewModel: SettingsViewModel())
}
