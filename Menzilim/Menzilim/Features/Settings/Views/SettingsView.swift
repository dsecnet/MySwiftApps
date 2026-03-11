import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppTheme.Spacing.xxl) {
                    // MARK: - Profile Card
                    profileCard

                    // MARK: - General Section
                    settingsSection(
                        title: "GENERAL",
                        items: [
                            SettingsItem(
                                icon: "globe",
                                iconColor: AppTheme.Colors.info,
                                title: "language".localized,
                                trailing: .text(viewModel.currentLanguage.displayName),
                                action: { viewModel.isShowingLanguagePicker = true }
                            ),
                            SettingsItem(
                                icon: "bell.badge.fill",
                                iconColor: AppTheme.Colors.accent,
                                title: "notifications".localized,
                                trailing: .toggle(isOn: $viewModel.notificationsEnabled),
                                action: nil
                            )
                        ]
                    )

                    // MARK: - Preferences Section
                    settingsSection(
                        title: "PREFERENCES",
                        items: [
                            SettingsItem(
                                icon: "moon.fill",
                                iconColor: AppTheme.Colors.premiumBadge,
                                title: "dark_mode".localized,
                                trailing: .toggle(isOn: $viewModel.isDarkMode),
                                action: nil
                            ),
                            SettingsItem(
                                icon: "dollarsign.circle.fill",
                                iconColor: AppTheme.Colors.success,
                                title: "currency".localized,
                                trailing: .text(viewModel.selectedCurrency.rawValue),
                                action: { }
                            )
                        ]
                    )

                    // MARK: - Support Section
                    settingsSection(
                        title: "SUPPORT",
                        items: [
                            SettingsItem(
                                icon: "lock.shield.fill",
                                iconColor: AppTheme.Colors.error,
                                title: "privacy_security".localized,
                                trailing: .chevron,
                                action: { }
                            ),
                            SettingsItem(
                                icon: "questionmark.circle.fill",
                                iconColor: AppTheme.Colors.warning,
                                title: "help_support".localized,
                                trailing: .chevron,
                                action: { }
                            ),
                            SettingsItem(
                                icon: "info.circle.fill",
                                iconColor: AppTheme.Colors.accent,
                                title: "about_app".localized,
                                trailing: .chevron,
                                action: { }
                            )
                        ]
                    )

                    // MARK: - Log Out Button
                    logoutButton

                    // MARK: - Version
                    Text("Mənzilim v\(viewModel.appVersion) (\(viewModel.buildNumber))")
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .padding(.bottom, AppTheme.Spacing.xxxl)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.isShowingProfileEdit) {
                ProfileEditView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingLanguagePicker) {
                languagePickerSheet
            }
            .alert("log_out".localized, isPresented: $viewModel.isShowingLogoutAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("log_out".localized, role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("Hesabınızdan çıxmaq istəyirsiniz?")
            }
        }
    }

    // MARK: - Profile Card
    private var profileCard: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            // Avatar
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
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        )
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppTheme.Colors.accent, lineWidth: 2)
            )

            // Name, email and role badge
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(viewModel.currentUser.fullName)
                    .font(AppTheme.Fonts.bodyBold())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(viewModel.currentUser.email)
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: viewModel.currentUser.role == .agent ? "person.badge.key.fill" : "house.fill")
                        .font(.system(size: 9))
                    Text(viewModel.currentUser.role.displayKey.localized)
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(viewModel.currentUser.role == .agent ? AppTheme.Colors.premiumBadge : AppTheme.Colors.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule().fill(
                        (viewModel.currentUser.role == .agent ? AppTheme.Colors.premiumBadge : AppTheme.Colors.accent).opacity(0.12)
                    )
                )
            }

            Spacer()

            // Edit button
            Button {
                viewModel.isShowingProfileEdit = true
            } label: {
                Text("edit".localized)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.accent.opacity(0.12))
                    .cornerRadius(AppTheme.CornerRadius.small)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }

    // MARK: - Settings Section
    private func settingsSection(title: String, items: [SettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(title)
                .font(AppTheme.Fonts.smallBold())
                .foregroundColor(AppTheme.Colors.textTertiary)
                .padding(.leading, AppTheme.Spacing.xs)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    settingsRow(item)

                    if index < items.count - 1 {
                        Divider()
                            .background(AppTheme.Colors.inputBorder)
                            .padding(.leading, 52)
                    }
                }
            }
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
        }
    }

    // MARK: - Settings Row
    private func settingsRow(_ item: SettingsItem) -> some View {
        Button {
            item.action?()
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .fill(item.iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: item.icon)
                        .font(.system(size: 15))
                        .foregroundColor(item.iconColor)
                }

                // Title
                Text(item.title)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()

                // Trailing
                switch item.trailing {
                case .chevron:
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                case .text(let value):
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(value)
                            .font(AppTheme.Fonts.caption())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                case .toggle(let isOn):
                    Toggle("", isOn: isOn)
                        .labelsHidden()
                        .tint(AppTheme.Colors.accent)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(item.trailing.isToggle)
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button {
            viewModel.isShowingLogoutAlert = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                Text("log_out".localized)
                    .font(AppTheme.Fonts.bodyBold())
            }
            .foregroundColor(AppTheme.Colors.error)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.Colors.error.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.error.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Language Picker Sheet
    private var languagePickerSheet: some View {
        NavigationStack {
            List {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button {
                        viewModel.setLanguage(language)
                        viewModel.isShowingLanguagePicker = false
                    } label: {
                        HStack {
                            Text(language.flag)
                                .font(.system(size: 24))
                            Text(language.displayName)
                                .font(AppTheme.Fonts.body())
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            if viewModel.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.Colors.accent)
                            }
                        }
                    }
                }
                .listRowBackground(AppTheme.Colors.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle("language".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        viewModel.isShowingLanguagePicker = false
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Settings Item Model
struct SettingsItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let trailing: SettingsTrailing
    let action: (() -> Void)?
}

// MARK: - Settings Trailing
enum SettingsTrailing {
    case chevron
    case text(String)
    case toggle(isOn: Binding<Bool>)

    var isToggle: Bool {
        if case .toggle = self { return true }
        return false
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(AuthManager.shared)
}
