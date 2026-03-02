//
//  ClientProfileView.swift
//  CoreVia
//
//  MÜŞTƏRİ / TƏLƏBƏ PROFİL VIEW — Yenidən Dizayn
//

import SwiftUI
import os.log

struct ClientProfileView: View {

    @Binding var isLoggedIn: Bool
    @ObservedObject private var loc = LocalizationManager.shared
    @StateObject private var imageManager = ProfileImageManager.shared
    @StateObject private var profileManager = UserProfileManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var workoutManager = WorkoutManager.shared
    @StateObject private var foodManager = FoodManager.shared

    @State private var showImagePicker = false
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showNotifications = false
    @State private var showSecurity = false
    @State private var showPremium = false
    @State private var showAbout = false
    @State private var showAddWorkout = false
    @State private var showAddFood = false
    @State private var showCancelPremiumAlert = false

    // Delete Account
    @State private var showDeleteAccountAlert = false
    @State private var showDeletePasswordSheet = false
    @State private var deletePassword: String = ""
    @State private var deleteError: String? = nil
    @State private var isDeleting: Bool = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    profileHeader
                    profileCompletionSection
                    if !settingsManager.isPremium { premiumBanner }
                    todayHighlightsSection
                    weeklyProgressSection
                    teachersSection
                    goalsSection
                    memberSinceSection
                    settingsSection
                    logoutButton
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 100)
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
            EditClientProfileView()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsSettingsView()
        }
        .sheet(isPresented: $showSecurity) {
            SecuritySettingsView()
        }
        .sheet(isPresented: $showPremium) {
            PremiumView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showAddWorkout) {
            AddWorkoutView()
        }
        .sheet(isPresented: $showAddFood) {
            AddFoodView()
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
        .alert(loc.localized("premium_cancel_title"), isPresented: $showCancelPremiumAlert) {
            Button(loc.localized("premium_cancel_no"), role: .cancel) { }
            Button(loc.localized("premium_cancel_yes"), role: .destructive) {
                Task {
                    // Backend-e cancel gonderin
                    do {
                        try await APIService.shared.requestVoid(
                            endpoint: "/api/v1/premium/cancel",
                            method: "POST"
                        )
                    } catch {
                        AppLogger.network.error("Premium cancel backend xetasi: \(error.localizedDescription)")
                    }
                    // Token-leri yenile (is_premium claim yenilenir)
                    await AuthManager.shared.refreshTokenClaims()
                    // Lokal statusu sondur + muellim abuneliyini legv et
                    await MainActor.run {
                        settingsManager.isPremium = false
                        trainerManager.assignedTrainer = nil
                    }
                }
            }
        } message: {
            Text(loc.localized("premium_cancel_message"))
        }
        // Delete Account
        .alert(loc.localized("delete_account_title"), isPresented: $showDeleteAccountAlert) {
            Button(loc.localized("common_cancel"), role: .cancel) { }
            Button(loc.localized("common_delete"), role: .destructive) {
                showDeletePasswordSheet = true
            }
        } message: {
            Text(loc.localized("delete_account_warning"))
        }
        .sheet(isPresented: $showDeletePasswordSheet) {
            DeleteAccountSheet(
                password: $deletePassword,
                error: $deleteError,
                isDeleting: $isDeleting
            ) {
                Task {
                    isDeleting = true
                    deleteError = nil
                    let result = await AuthManager.shared.deleteAccount(password: deletePassword)
                    isDeleting = false
                    if result.success {
                        showDeletePasswordSheet = false
                        deletePassword = ""
                    } else {
                        deleteError = result.error ?? loc.localized("delete_account_error")
                    }
                }
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.Colors.accent.opacity(0.3), AppTheme.Colors.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    if let image = imageManager.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 15, x: 0, y: 8)

                if settingsManager.isPremium {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.Colors.starFilled, AppTheme.Colors.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .shadow(color: AppTheme.Colors.starFilled.opacity(0.5), radius: 4)
                    .offset(x: -2, y: -2)
                }

                Button {
                    showImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent)
                            .frame(width: 32, height: 32)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .shadow(color: AppTheme.Colors.accent.opacity(0.5), radius: 6)
                }
                .accessibilityLabel("Change profile photo")
            }

            VStack(spacing: 2) {
                HStack(spacing: 8) {
                    Text(profileManager.userProfile.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    if settingsManager.isPremium {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppTheme.Colors.accentDark)
                            .font(.system(size: 16))
                    }
                }

                Text(profileManager.userProfile.email)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                if settingsManager.isPremium {
                    HStack(spacing: 5) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11))
                        Text(loc.localized("premium_badge"))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.starFilled.opacity(0.9), AppTheme.Colors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 4, x: 0, y: 2)
                }

                Button {
                    showEditProfile = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                        Text(loc.localized("profile_edit"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.accent.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(.top, 2)
            }
        }
    }

    // MARK: - Profile Completion
    private var profileCompletionSection: some View {
        let fields: [Bool] = [
            !profileManager.userProfile.name.isEmpty,
            profileManager.userProfile.age != nil && profileManager.userProfile.age! > 0,
            profileManager.userProfile.weight != nil && profileManager.userProfile.weight! > 0,
            profileManager.userProfile.height != nil && profileManager.userProfile.height! > 0,
            profileManager.userProfile.goal != nil && !profileManager.userProfile.goal!.isEmpty,
            imageManager.profileImage != nil
        ]
        let filled = fields.filter { $0 }.count
        let total = fields.count
        let percentage = Double(filled) / Double(total)

        return Group {
            if percentage < 1.0 {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(loc.localized("profile_completion"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Spacer()
                        Text("\(Int(percentage * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.accent)
                    }

                    ProgressView(value: percentage)
                        .tint(AppTheme.Colors.accent)

                    Text(loc.localized("profile_complete_desc"))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)
            }
        }
    }

    // MARK: - Premium Banner
    private var premiumBanner: some View {
        Button {
            showPremium = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(loc.localized("premium_go_banner"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text(loc.localized("premium_go_banner_desc"))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: AppTheme.Colors.premiumGradientStart.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }

    // MARK: - Today Highlights (horizontal scroll)
    private var todayHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_today_highlights"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TodayHighlightCard(
                        icon: "figure.strengthtraining.traditional",
                        value: "\(workoutManager.todayWorkouts.count)",
                        label: loc.localized("profile_workouts"),
                        color: AppTheme.Colors.accent
                    )
                    TodayHighlightCard(
                        icon: "flame.fill",
                        value: "\(foodManager.todayTotalCalories)",
                        label: loc.localized("profile_calorie"),
                        color: AppTheme.Colors.accent
                    )
                    TodayHighlightCard(
                        icon: "fork.knife",
                        value: "\(foodManager.todayEntries.count)",
                        label: loc.localized("profile_meals"),
                        color: AppTheme.Colors.success
                    )
                }
            }
        }
    }

    // MARK: - Weekly Progress (Circular Rings)
    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_weekly_progress"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 14) {
                CircularProgressCard(
                    value: Double(workoutManager.weekWorkouts.count),
                    total: 5.0,
                    label: loc.localized("profile_workouts"),
                    color: AppTheme.Colors.accent,
                    icon: "figure.strengthtraining.traditional"
                )

                CircularProgressCard(
                    value: Double(foodManager.todayTotalCalories),
                    total: Double(foodManager.dailyCalorieGoal),
                    label: loc.localized("profile_calorie"),
                    color: AppTheme.Colors.accent,
                    icon: "flame.fill"
                )
            }
        }
    }

    // MARK: - Teachers Section
    @ObservedObject private var trainerManager = TrainerManager.shared

    private var teachersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_my_teachers"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            // Bagli trainer varsa goster
            if let trainer = trainerManager.assignedTrainer {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [trainer.category.color.opacity(0.3), trainer.category.color],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        Image(systemName: trainer.category.icon)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(trainer.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Text(trainer.specialization ?? trainer.category.localizedName)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    Spacer()

                    if let rating = trainer.rating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.Colors.starFilled)
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                        }
                    }

                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppTheme.Colors.success)
                        .font(.system(size: 16))
                }
                .padding(14)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.Colors.success.opacity(0.2), lineWidth: 1)
                )
            }

            // Butun muellimlere bax linki
            NavigationLink(destination: TeachersView()) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.Colors.accent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(trainerManager.assignedTrainer != nil ? loc.localized("profile_change_teacher") : loc.localized("profile_select_teacher"))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Text(loc.localized("profile_view_teachers"))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    Spacer()

                    if !settingsManager.isPremium {
                        HStack(spacing: 3) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text(loc.localized("premium_badge"))
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(8)
                    }

                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                        .font(.system(size: 13))
                }
                .padding(14)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.Colors.accent.opacity(0.15), lineWidth: 1)
                )
            }
        }
        .onAppear {
            Task { await trainerManager.loadAssignedTrainer() }
        }
    }

    // MARK: - Goals Section (compact)
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.localized("profile_goals"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ClientStatCard(
                        icon: "calendar",
                        value: "\(profileManager.userProfile.age ?? 0)",
                        label: loc.localized("profile_age")
                    )
                    ClientStatCard(
                        icon: "scalemass",
                        value: "\(Int(profileManager.userProfile.weight ?? 0)) \(loc.localized("unit_kg"))",
                        label: loc.localized("profile_weight")
                    )
                    ClientStatCard(
                        icon: "ruler",
                        value: "\(Int(profileManager.userProfile.height ?? 0)) \(loc.localized("unit_cm"))",
                        label: loc.localized("profile_height")
                    )
                }

                if let goal = profileManager.userProfile.goal {
                    HStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.accent)
                        Text(loc.localized("profile_goal_label"))
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        Text(goal)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(10)
                }

                // Complete profile prompt when fields are missing
                if profileManager.userProfile.age == nil
                    || profileManager.userProfile.weight == nil
                    || profileManager.userProfile.height == nil
                    || profileManager.userProfile.goal == nil {
                    Button {
                        showEditProfile = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.Colors.accent)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(loc.localized("profile_complete_profile"))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                Text(loc.localized("profile_complete_desc"))
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                                .font(.system(size: 12))
                        }
                        .padding(10)
                        .background(AppTheme.Colors.accent.opacity(0.08))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.Colors.accent.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Member Since
    private var memberSinceSection: some View {
        Group {
            if let user = AuthManager.shared.currentUser {
                let formattedDate = formatDateString(user.createdAt)
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.Colors.accent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(loc.localized("profile_member_since"))
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        Text(formattedDate)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }

                    Spacer()
                }
                .padding(14)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)
            }
        }
    }

    private func formatDateString(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let date = isoFormatter.date(from: dateString) ?? fallbackFormatter.date(from: dateString) ?? Date()

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        displayFormatter.timeStyle = .none
        displayFormatter.locale = Locale.current
        return displayFormatter.string(from: date)
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_settings"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            VStack(spacing: 8) {
                SettingsRow(
                    icon: "bell.fill",
                    title: loc.localized("settings_notifications"),
                    badge: settingsManager.notificationsEnabled ? loc.localized("common_active") : nil,
                    badgeColor: AppTheme.Colors.success
                ) {
                    showNotifications = true
                }

                SettingsRow(
                    icon: "lock.fill",
                    title: loc.localized("settings_security"),
                    badge: settingsManager.faceIDEnabled || settingsManager.hasAppPassword ? "🔒" : nil,
                    badgeColor: AppTheme.Colors.accent
                ) {
                    showSecurity = true
                }

                SettingsRow(
                    icon: "sparkles",
                    title: loc.localized("settings_premium"),
                    badge: settingsManager.isPremium ? loc.localized("premium_active_badge") : nil,
                    badgeColor: settingsManager.isPremium ? AppTheme.Colors.success : AppTheme.Colors.accentDark
                ) {
                    showPremium = true
                }

                SettingsRow(
                    icon: "info.circle.fill",
                    title: loc.localized("settings_about")
                ) {
                    showAbout = true
                }

                // Delete Account
                SettingsRow(
                    icon: "trash.fill",
                    title: loc.localized("delete_account_title"),
                    iconColor: AppTheme.Colors.error,
                    titleColor: AppTheme.Colors.error
                ) {
                    showDeleteAccountAlert = true
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
            .foregroundColor(AppTheme.Colors.error)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.error, lineWidth: 1)
            )
        }
    }

    // MARK: - Delete Account Button
    private var deleteAccountButton: some View {
        Button {
            showDeleteAccountAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 14))
                Text(loc.localized("delete_account_title"))
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(AppTheme.Colors.error.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Today Highlight Card
struct TodayHighlightCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(width: 110)
        .padding(.vertical, 14)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
        .shadow(color: color.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Circular Progress Card
struct CircularProgressCard: View {
    let value: Double
    let total: Double
    let label: String
    let color: Color
    let icon: String

    var progress: Double {
        guard total > 0 else { return 0 }
        return min(value / total, 1.0)
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                    .frame(width: 70, height: 70)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(value))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text("/ \(Int(total))")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }
}

// MARK: - Legacy Components (still used)

struct ProgressCard: View {
    let icon: String
    let value: String
    let total: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text("/ \(total)")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Spacer()

            Text(value)
                .foregroundColor(AppTheme.Colors.primaryText)
                .fontWeight(.semibold)
        }
    }
}

// #Preview { // iOS 17+ only
//     NavigationStack {
//         ClientProfileView(isLoggedIn: .constant(true))
//     }
// }
