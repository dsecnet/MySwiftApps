import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showLogoutAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: AppTheme.primaryColor.opacity(0.4), radius: 20, x: 0, y: 10)

                                if let user = authVM.currentUser {
                                    Text(user.name.prefix(1).uppercased())
                                        .font(.system(size: 44, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }

                            if let user = authVM.currentUser {
                                Text(user.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)

                                Text(user.email)
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(.top, 20)

                        // Profile Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Profil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 12)

                            VStack(spacing: 0) {
                                SettingsRowButton(
                                    icon: "person.fill",
                                    title: "Şəxsi Məlumat",
                                    iconColor: AppTheme.primaryColor
                                ) {
                                    // Edit profile
                                }

                                Divider().padding(.leading, 56)

                                SettingsRowButton(
                                    icon: "bell.fill",
                                    title: "Bildirişlər",
                                    iconColor: AppTheme.accentColor
                                ) {
                                    // Notifications settings
                                }

                                Divider().padding(.leading, 56)

                                SettingsRowButton(
                                    icon: "lock.fill",
                                    title: "Təhlükəsizlik",
                                    iconColor: AppTheme.warningColor
                                ) {
                                    // Security settings
                                }
                            }
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.cornerRadius)
                            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
                        }
                        .padding(.horizontal)

                        // App Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Tətbiq")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 12)

                            VStack(spacing: 0) {
                                SettingsRowButton(
                                    icon: "info.circle.fill",
                                    title: "Haqqında",
                                    iconColor: AppTheme.infoColor
                                ) {
                                    // About
                                }

                                Divider().padding(.leading, 56)

                                SettingsRowButton(
                                    icon: "envelope.fill",
                                    title: "Dəstək",
                                    iconColor: AppTheme.secondaryColor
                                ) {
                                    // Support
                                }

                                Divider().padding(.leading, 56)

                                SettingsRowButton(
                                    icon: "doc.text.fill",
                                    title: "Qaydalar və Şərtlər",
                                    iconColor: AppTheme.textSecondary
                                ) {
                                    // Terms
                                }
                            }
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.cornerRadius)
                            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
                        }
                        .padding(.horizontal)

                        // Logout Button
                        Button {
                            showLogoutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Çıxış")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.errorColor)
                            .cornerRadius(12)
                            .shadow(color: AppTheme.errorColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Version
                        Text("EmlakCRM v1.0.0")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Tənzimləmələr")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .alert("Çıxış etmək istədiyinizdən əminsiniz?", isPresented: $showLogoutAlert) {
                Button("Ləğv et", role: .cancel) { }
                Button("Çıxış", role: .destructive) {
                    authVM.logout()
                    dismiss()
                }
            }
        }
    }
}

struct SettingsRowButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(iconColor.opacity(0.15))
                    .cornerRadius(8)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
