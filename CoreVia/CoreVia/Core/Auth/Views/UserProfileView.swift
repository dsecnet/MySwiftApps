//
//  ClientProfileView.swift
//  CoreVia
//
//  MÜŞTƏRİ / TƏLƏBƏ PROFİL VIEW — Yenidən Dizayn
//

import SwiftUI

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

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHeader
                    if !settingsManager.isPremium { premiumBanner }
                    quickActionsSection
                    todayHighlightsSection
                    weeklyProgressSection
                    teachersSection
                    goalsSection
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
        .alert("Premium-i legv et", isPresented: $showCancelPremiumAlert) {
            Button("Xeyr", role: .cancel) { }
            Button("Beli, legv et", role: .destructive) {
                Task {
                    // Backend-e cancel gonderin
                    do {
                        try await APIService.shared.requestVoid(
                            endpoint: "/api/v1/premium/cancel",
                            method: "POST"
                        )
                    } catch {
                        print("Premium cancel backend xetasi: \(error)")
                    }
                    // Token-leri yenile (is_premium claim yenilenir)
                    await AuthManager.shared.refreshTokenClaims()
                    // Lokal statusu sondur
                    await MainActor.run {
                        settingsManager.isPremium = false
                    }
                }
            }
        } message: {
            Text("Premium abuneliyinizi legv etmek isteyirsiniz? Butun premium xususiyyetlere girisiniz bitecek.")
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
                                colors: [Color.blue.opacity(0.3), Color.blue],
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
                .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 8)

                if settingsManager.isPremium {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .yellow.opacity(0.5), radius: 4)
                    .offset(x: -2, y: -2)
                }

                Button {
                    showImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 32, height: 32)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.blue.opacity(0.5), radius: 6)
                }
            }

            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Text(profileManager.userProfile.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    if settingsManager.isPremium {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.indigo)
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
                        Text("Premium")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [.yellow.opacity(0.9), .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
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
                    .foregroundColor(.blue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(.top, 2)
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
                    Text("Premium-a kecin")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text("AI analiz, detalli statistika ve daha cox")
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
                    colors: [.indigo, .purple.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .indigo.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suretli Emeliyyatlar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            VStack(spacing: 12) {
                // Row 1: Yeni Idman + Qida Elave Et
                HStack(spacing: 12) {
                    Button { showAddWorkout = true } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            Text("Yeni Idman")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(workoutManager.todayWorkouts.count) bugun")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }

                    Button { showAddFood = true } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            Text("Qida Elave Et")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(foodManager.todayTotalCalories) kcal")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }

                // Row 2: Herekete Basla (premium only)
                if settingsManager.isPremium {
                    NavigationLink(destination: ActivitiesView()) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "figure.run")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Herekete Basla")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("GPS ile qacis, gezinti izle")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 13))
                        }
                        .padding(14)
                        .background(
                            LinearGradient(
                                colors: [.blue, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
        }
    }

    // MARK: - Today Highlights (horizontal scroll)
    private var todayHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bugunun Netlikleri")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TodayHighlightCard(
                        icon: "figure.strengthtraining.traditional",
                        value: "\(workoutManager.todayWorkouts.count)",
                        label: loc.localized("profile_workouts"),
                        color: .red
                    )
                    TodayHighlightCard(
                        icon: "flame.fill",
                        value: "\(foodManager.todayTotalCalories)",
                        label: "Kalori",
                        color: .orange
                    )
                    TodayHighlightCard(
                        icon: "fork.knife",
                        value: "\(foodManager.todayEntries.count)",
                        label: loc.localized("profile_meals"),
                        color: .green
                    )
                }
            }
        }
    }

    // MARK: - Weekly Progress (Circular Rings)
    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Heftelik Inkisaf")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 14) {
                CircularProgressCard(
                    value: Double(workoutManager.weekWorkouts.count),
                    total: 5.0,
                    label: loc.localized("profile_workouts"),
                    color: .red,
                    icon: "figure.strengthtraining.traditional"
                )

                CircularProgressCard(
                    value: Double(foodManager.todayTotalCalories),
                    total: Double(foodManager.dailyCalorieGoal),
                    label: "Kalori",
                    color: .orange,
                    icon: "flame.fill"
                )
            }
        }
    }

    // MARK: - Teachers Section
    @ObservedObject private var trainerManager = TrainerManager.shared

    private var teachersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Muellimlerim")
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
                        Text(trainer.specialization ?? trainer.category.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    Spacer()

                    if let rating = trainer.rating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                        }
                    }

                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                }
                .padding(14)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
            }

            // Butun muellimlere bax linki
            NavigationLink(destination: TeachersView()) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.purple)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(trainerManager.assignedTrainer != nil ? "Muellimi Deyis" : "Muellim Sec")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Text("Professional muellimlere baxin")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    Spacer()

                    if !settingsManager.isPremium {
                        HStack(spacing: 3) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text("Premium")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
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
                        .stroke(Color.purple.opacity(0.15), lineWidth: 1)
                )
            }
        }
        .onAppear {
            Task { await trainerManager.loadAssignedTrainer() }
        }
    }

    // MARK: - Goals Section (compact)
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("profile_goals"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ClientStatCard(
                        icon: "calendar",
                        value: "\(profileManager.userProfile.age ?? 0)",
                        label: loc.localized("profile_age")
                    )
                    ClientStatCard(
                        icon: "scalemass",
                        value: "\(Int(profileManager.userProfile.weight ?? 0)) kg",
                        label: loc.localized("profile_weight")
                    )
                    ClientStatCard(
                        icon: "ruler",
                        value: "\(Int(profileManager.userProfile.height ?? 0)) sm",
                        label: loc.localized("profile_height")
                    )
                }

                if let goal = profileManager.userProfile.goal {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                        Text(loc.localized("profile_goal_label"))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        Text(goal)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .fontWeight(.semibold)
                        Spacer()
                    }
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

            VStack(spacing: 8) {
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
                    badge: settingsManager.faceIDEnabled || settingsManager.hasAppPassword ? "🔒" : nil,
                    badgeColor: .blue
                ) {
                    showSecurity = true
                }

                SettingsRow(
                    icon: "sparkles",
                    title: loc.localized("settings_premium"),
                    badge: settingsManager.isPremium ? "Aktiv" : nil,
                    badgeColor: settingsManager.isPremium ? .green : .indigo
                ) {
                    showPremium = true
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

#Preview {
    NavigationStack {
        ClientProfileView(isLoggedIn: .constant(true))
    }
}
