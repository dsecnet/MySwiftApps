//
//  TrainerProfileView.swift
//  CoreVia
//
//  MÜƏLLİM / TƏLİMÇİ PROFİL VIEW
//

import SwiftUI

struct TrainerProfileView: View {

    @Binding var isLoggedIn: Bool
    @ObservedObject private var loc = LocalizationManager.shared
    @StateObject private var imageManager = ProfileImageManager.shared
    @StateObject private var profileManager = UserProfileManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var trainingPlanManager = TrainingPlanManager.shared
    @StateObject private var mealPlanManager = MealPlanManager.shared

    @State private var showImagePicker = false
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showNotifications = false
    @State private var showSecurity = false
    @State private var showAbout = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileHeader
                    statsSection
                    myPlansSection
                    studentsSection
                    specialtySection
                    settingsSection
                    logoutButton
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: Binding(
                get: { imageManager.profileImage },
                set: { newImage in
                    if let image = newImage {
                        imageManager.saveImage(image)
                    }
                }
            ))
        }
        .sheet(isPresented: $showEditProfile) {
            EditTrainerProfileView()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsSettingsView()
        }
        .sheet(isPresented: $showSecurity) {
            SecuritySettingsView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .alert(loc.localized("profile_logout"), isPresented: $showLogoutAlert) {
            Button(loc.localized("common_cancel"), role: .cancel) { }
            Button(loc.localized("profile_logout"), role: .destructive) {
                withAnimation {
                    AuthManager.shared.logout()
                }
            }
        } message: {
            Text(loc.localized("profile_logout_confirm"))
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.3), Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    if let image = imageManager.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: Color.purple.opacity(0.3), radius: 20, x: 0, y: 10)

                Button {
                    showImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 36, height: 36)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.purple.opacity(0.5), radius: 8)
                }
            }

            VStack(spacing: 6) {
                Text(profileManager.userProfile.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(profileManager.userProfile.email)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                    Text(loc.localized("profile_type_trainer"))
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)

                // Verification status badge
                verificationBadge

                if let price = profileManager.userProfile.pricePerSession, price > 0 {
                    Text("\(String(format: "%.0f", price)) AZN / seans")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.green)
                }

                Button {
                    showEditProfile = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text(loc.localized("profile_edit"))
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Verification Badge
    @ViewBuilder
    private var verificationBadge: some View {
        let status = AuthManager.shared.currentUser?.verificationStatus ?? "pending"

        if status == "verified" {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 12))
                Text("Dogrulanmis Muellim")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.green)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.green.opacity(0.12))
            .cornerRadius(10)
        } else if status == "pending" {
            HStack(spacing: 6) {
                Image(systemName: "hourglass")
                    .font(.system(size: 12))
                Text("Gozden kecirilir")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.orange.opacity(0.12))
            .cornerRadius(10)
        } else {
            HStack(spacing: 6) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                Text("Redd edildi")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.red.opacity(0.12))
            .cornerRadius(10)
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_statistics"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 12) {
                TrainerStatCard(
                    icon: "star.fill",
                    value: String(format: "%.1f", profileManager.userProfile.rating ?? 0.0),
                    label: loc.localized("profile_rating"),
                    color: .yellow
                )

                TrainerStatCard(
                    icon: "person.2.fill",
                    value: "\(profileManager.userProfile.students ?? 0)",
                    label: loc.localized("profile_students"),
                    color: .blue
                )

                TrainerStatCard(
                    icon: "calendar",
                    value: "\(profileManager.userProfile.experience ?? 0) \(loc.localized("common_year"))",
                    label: loc.localized("profile_experience"),
                    color: .green
                )
            }
        }
    }

    // MARK: - My Plans Section (Plan Satisi)
    private var myPlansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Planlarim")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                Text("\(trainingPlanManager.totalPlans + mealPlanManager.totalPlans) plan")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            HStack(spacing: 12) {
                // Training Plans
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 22))
                            .foregroundColor(.red)
                    }

                    Text("\(trainingPlanManager.totalPlans)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text("Idman Plani")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)

                // Meal Plans
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "fork.knife")
                            .font(.system(size: 22))
                            .foregroundColor(.orange)
                    }

                    Text("\(mealPlanManager.totalPlans)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text("Yemek Plani")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)
            }
        }
    }

    // MARK: - Students Section
    private var studentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loc.localized("profile_active_students"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                Text("\(profileManager.userProfile.students ?? 0) \(loc.localized("common_person"))")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            VStack(spacing: 12) {
                StudentRow(name: "Nigar Aliyeva", progress: 75, avatar: "A")
                StudentRow(name: "Resad Mammadov", progress: 60, avatar: "R")
                StudentRow(name: "Leyla Hasanova", progress: 90, avatar: "L")

                Button {
                    print("Hamisini gor")
                } label: {
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text(loc.localized("profile_all_students"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.purple)
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Specialty Section
    private var specialtySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_specialty_bio"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            VStack(spacing: 12) {
                if let specialty = profileManager.userProfile.specialty {
                    HStack {
                        Image(systemName: "medal.fill")
                            .foregroundColor(.purple)
                        Text(loc.localized("profile_specialty"))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        Text(specialty)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                }

                if let bio = profileManager.userProfile.bio {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("profile_bio"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(bio)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_settings"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            VStack(spacing: 12) {
                SettingsRow(
                    icon: "bell.fill",
                    title: loc.localized("settings_notifications"),
                    badge: settingsManager.notificationsEnabled ? loc.localized("common_active") : nil,
                    badgeColor: .green
                ) {
                    showNotifications = true
                }

                SettingsRow(
                    icon: "lock.fill",
                    title: loc.localized("settings_security"),
                    badge: settingsManager.faceIDEnabled || settingsManager.hasAppPassword ? "ON" : nil,
                    badgeColor: .blue
                ) {
                    showSecurity = true
                }

                SettingsRow(
                    icon: "info.circle.fill",
                    title: loc.localized("settings_about")
                ) {
                    showAbout = true
                }
            }
        }
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button {
            showLogoutAlert = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text(loc.localized("profile_logout"))
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red, lineWidth: 1)
            )
        }
    }
}

// MARK: - Components

struct StudentRow: View {
    let name: String
    let progress: Int
    let avatar: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 50, height: 50)
                Text(avatar)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.purple)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                HStack(spacing: 8) {
                    ProgressView(value: Double(progress) / 100.0)
                        .tint(.green)

                    Text("\(progress)%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.green)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.Colors.secondaryText)
                .font(.caption)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    TrainerProfileView(isLoggedIn: .constant(true))
}
