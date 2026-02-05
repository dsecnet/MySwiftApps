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
    @StateObject private var dashboard = TrainerDashboardManager.shared

    @State private var showImagePicker = false
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showNotifications = false
    @State private var showSecurity = false
    @State private var showAbout = false
    @State private var showAllStudents = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileHeader
                    profileCompletionSection
                    statsSection
                    earningsSection
                    myPlansSection
                    studentsSection
                    specialtySection
                    memberSinceSection
                    settingsSection
                    logoutButton
                }
                .padding()
            }
        }
        .onAppear {
            Task { await dashboard.fetchStats() }
        }
        .sheet(isPresented: $showAllStudents) {
            NavigationStack {
                MyStudentsView()
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
                                colors: [AppTheme.Colors.accent.opacity(0.3), AppTheme.Colors.accent],
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
                .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 20, x: 0, y: 10)

                Button {
                    showImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent)
                            .frame(width: 36, height: 36)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .shadow(color: AppTheme.Colors.accent.opacity(0.5), radius: 8)
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
                .foregroundColor(AppTheme.Colors.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.accent.opacity(0.1))
                .cornerRadius(12)

                // Verification status badge
                verificationBadge

                if let price = profileManager.userProfile.pricePerSession, price > 0 {
                    Text("\(String(format: "%.0f", price)) ₼ / \(loc.localized("trainer_session_short"))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.Colors.accent)
                }

                Button {
                    showEditProfile = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text(loc.localized("profile_edit"))
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.accent.opacity(0.1))
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
                Text(loc.localized("teacher_verified"))
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(AppTheme.Colors.badgeVerified)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(AppTheme.Colors.badgeVerified.opacity(0.12))
            .cornerRadius(10)
        } else if status == "pending" {
            HStack(spacing: 6) {
                Image(systemName: "hourglass")
                    .font(.system(size: 12))
                Text(loc.localized("teacher_pending"))
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(AppTheme.Colors.badgePending)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(AppTheme.Colors.badgePending.opacity(0.12))
            .cornerRadius(10)
        } else {
            HStack(spacing: 6) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                Text(loc.localized("teacher_rejected"))
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(AppTheme.Colors.badgeRejected)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(AppTheme.Colors.badgeRejected.opacity(0.12))
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
                    icon: "person.2.fill",
                    value: "\(dashboard.stats?.totalSubscribers ?? profileManager.userProfile.students ?? 0)",
                    label: loc.localized("profile_subscribers"),
                    color: AppTheme.Colors.accent
                )

                TrainerStatCard(
                    icon: "person.fill.checkmark",
                    value: "\(dashboard.stats?.activeStudents ?? 0)",
                    label: loc.localized("profile_active_students"),
                    color: AppTheme.Colors.success
                )

                TrainerStatCard(
                    icon: "calendar",
                    value: "\(profileManager.userProfile.experience ?? 0) \(loc.localized("common_year"))",
                    label: loc.localized("profile_experience"),
                    color: AppTheme.Colors.accent
                )
            }

            if let summary = dashboard.stats?.statsSummary {
                HStack(spacing: 12) {
                    TrainerStatCard(
                        icon: "flame.fill",
                        value: String(format: "%.1f", summary.avgStudentWorkoutsPerWeek),
                        label: loc.localized("profile_avg_workouts_week"),
                        color: AppTheme.Colors.accent
                    )

                    TrainerStatCard(
                        icon: "figure.strengthtraining.traditional",
                        value: "\(summary.totalWorkoutsAllStudents)",
                        label: loc.localized("profile_total_workouts"),
                        color: AppTheme.Colors.accent
                    )

                    TrainerStatCard(
                        icon: "star.fill",
                        value: String(format: "%.1f", profileManager.userProfile.rating ?? 0.0),
                        label: loc.localized("profile_rating"),
                        color: AppTheme.Colors.starFilled
                    )
                }
            }
        }
    }

    // MARK: - My Plans Section (Plan Satisi)
    private var myPlansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loc.localized("teacher_my_plans"))
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
                            .fill(AppTheme.Colors.accent.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.Colors.accent)
                    }

                    Text("\(trainingPlanManager.totalPlans)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(loc.localized("teacher_workout_plan"))
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
                            .fill(AppTheme.Colors.accent.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "fork.knife")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.Colors.accent)
                    }

                    Text("\(mealPlanManager.totalPlans)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(loc.localized("teacher_meal_plan"))
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

                Text("\(dashboard.stats?.activeStudents ?? 0) \(loc.localized("common_person"))")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            VStack(spacing: 12) {
                if dashboard.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                } else if dashboard.stats?.students.isEmpty ?? true {
                    HStack(spacing: 12) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.tertiaryText)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(loc.localized("profile_no_students_yet"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                            Text(loc.localized("profile_no_students_desc"))
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                } else {
                    ForEach(Array((dashboard.stats?.students ?? []).prefix(3))) { student in
                        StudentRow(
                            name: student.name,
                            goal: student.goal,
                            thisWeekWorkouts: student.thisWeekWorkouts,
                            avatar: student.initials,
                            avatarColor: student.avatarColor
                        )
                    }
                }

                Button {
                    showAllStudents = true
                } label: {
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text(loc.localized("profile_all_students"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(AppTheme.Colors.accent)
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
                if let specialty = profileManager.userProfile.specialty, !specialty.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(loc.localized("trainer_specialties"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        WrappingHStack(spacing: 8) {
                            ForEach(specialtyTagsFromProfile, id: \.self) { tag in
                                HStack(spacing: 6) {
                                    Image(systemName: tag.icon)
                                        .font(.system(size: 12))
                                    Text(tag.localizedName)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(tag.color)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(tag.color.opacity(0.12))
                                .cornerRadius(20)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                }

                if let bio = profileManager.userProfile.bio, !bio.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("teacher_about"))
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

    private var specialtyTagsFromProfile: [TrainerCategory] {
        guard let spec = profileManager.userProfile.specialty?.lowercased() else { return [.fitness] }
        var tags: [TrainerCategory] = []
        if spec.contains("yoga") { tags.append(.yoga) }
        if spec.contains("cardio") { tags.append(.cardio) }
        if spec.contains("nutrition") || spec.contains("qidalanma") { tags.append(.nutrition) }
        if spec.contains("strength") || spec.contains("guc") { tags.append(.strength) }
        if spec.contains("fitness") || tags.isEmpty { tags.insert(.fitness, at: 0) }
        return tags
    }

    // MARK: - Profile Completion Section
    private var profileCompletionPercentage: Double {
        let user = AuthManager.shared.currentUser
        let profile = profileManager.userProfile
        var filled = 0
        let total = 8

        if !profile.name.isEmpty { filled += 1 }
        if !profile.email.isEmpty { filled += 1 }
        if profile.bio != nil && !(profile.bio?.isEmpty ?? true) { filled += 1 }
        if profile.specialty != nil && !(profile.specialty?.isEmpty ?? true) { filled += 1 }
        if profile.experience != nil && (profile.experience ?? 0) > 0 { filled += 1 }
        if profile.pricePerSession != nil && (profile.pricePerSession ?? 0) > 0 { filled += 1 }
        if user?.instagramHandle != nil && !(user?.instagramHandle?.isEmpty ?? true) { filled += 1 }
        if imageManager.profileImage != nil || user?.profileImageUrl != nil { filled += 1 }

        return Double(filled) / Double(total)
    }

    private var profileCompletionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let percentage = profileCompletionPercentage

            if percentage < 1.0 {
                HStack(spacing: 16) {
                    // Circular progress indicator
                    ZStack {
                        Circle()
                            .stroke(AppTheme.Colors.separator, lineWidth: 6)
                            .frame(width: 56, height: 56)

                        Circle()
                            .trim(from: 0, to: percentage)
                            .stroke(
                                AppTheme.Colors.accent,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(percentage * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.accent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.localized("profile_completion"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(loc.localized("profile_complete_profile"))
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    Spacer()

                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)
            }
        }
    }

    // MARK: - Earnings Section
    private var earningsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_earnings"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 12) {
                // Monthly Earnings Card
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.success.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "banknote.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.Colors.success)
                    }

                    Text(String(format: "%.0f %@", dashboard.stats?.monthlyEarnings ?? 0, dashboard.stats?.currency ?? "₼"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(loc.localized("profile_monthly_earnings"))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)

                // Subscribers Card
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.Colors.accent)
                    }

                    Text("\(dashboard.stats?.totalSubscribers ?? 0)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(loc.localized("profile_subscribers"))
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

    // MARK: - Member Since Section
    private var memberSinceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let createdAtString = AuthManager.shared.currentUser?.createdAt {
                let formattedDate = formatMemberSinceDate(createdAtString)
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.accent)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.localized("profile_member_since"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(formattedDate)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    Spacer()
                }
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
            }
        }
    }

    private func formatMemberSinceDate(_ dateString: String) -> String {
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

            VStack(spacing: 12) {
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
                    badge: settingsManager.faceIDEnabled || settingsManager.hasAppPassword ? "ON" : nil,
                    badgeColor: AppTheme.Colors.accent
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
}

// MARK: - Components

struct StudentRow: View {
    let name: String
    let goal: String?
    let thisWeekWorkouts: Int
    let avatar: String
    var avatarColor: Color = AppTheme.Colors.accent

    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                Text(avatar)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(avatarColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                if let goal = goal, !goal.isEmpty {
                    Text(goal)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.accent)
                    Text("\(thisWeekWorkouts) \(loc.localized("profile_workouts_this_week"))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.accent)
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
