//
//  ClientProfileView.swift
//  CoreVia
//
//  MÜŞTƏRİ / TƏLƏBƏ PROFİL VIEW
//

import SwiftUI

struct ClientProfileView: View {
    
    @Binding var isLoggedIn: Bool
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
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileHeader
                    weeklyProgressSection
                    todayStatsSection
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
        .alert("Çıxış", isPresented: $showLogoutAlert) {
            Button("Ləğv et", role: .cancel) { }
            Button("Çıxış", role: .destructive) {
                withAnimation {
                    isLoggedIn = false
                }
            }
        } message: {
            Text("Hesabdan çıxmaq istədiyinizə əminsiniz?")
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
                        .frame(width: 120, height: 120)
                    
                    if let image = imageManager.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                if settingsManager.isPremium {
                    ZStack {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 32, height: 32)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .offset(x: -5, y: -5)
                }
                
                Button {
                    showImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 36, height: 36)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.blue.opacity(0.5), radius: 8)
                }
            }
            
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Text(profileManager.userProfile.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    
                    if settingsManager.isPremium {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(profileManager.userProfile.email)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                    Text("Müştəri")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                Button {
                    showEditProfile = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Profili Redaktə Et")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Weekly Progress
    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Həftəlik Tərəqqi")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 12) {
                ProgressCard(
                    icon: "figure.strengthtraining.traditional",
                    value: "\(workoutManager.weekWorkouts.count)",
                    total: "5",
                    label: "Məşqlər",
                    color: .red
                )
                
                ProgressCard(
                    icon: "flame.fill",
                    value: "\(foodManager.todayTotalCalories)",
                    total: "\(foodManager.dailyCalorieGoal)",
                    label: "Kalori",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Today Stats
    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bu Gün")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            VStack(spacing: 12) {
                StatRow(
                    icon: "figure.run",
                    label: "Məşqlər",
                    value: "\(workoutManager.todayWorkouts.count) ədəd",
                    color: .red
                )
                
                StatRow(
                    icon: "fork.knife",
                    label: "Öğünlər",
                    value: "\(foodManager.todayEntries.count) ədəd",
                    color: .green
                )
                
                StatRow(
                    icon: "flame.fill",
                    label: "Kalori",
                    value: "\(foodManager.todayTotalCalories) kcal",
                    color: .orange
                )
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Goals Section
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Məqsədlərim")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ClientStatCard(
                        icon: "calendar",
                        value: "\(profileManager.userProfile.age ?? 0)",
                        label: "Yaş"
                    )
                    ClientStatCard(
                        icon: "scalemass",
                        value: "\(Int(profileManager.userProfile.weight ?? 0)) kg",
                        label: "Çəki"
                    )
                    ClientStatCard(
                        icon: "ruler",
                        value: "\(Int(profileManager.userProfile.height ?? 0)) sm",
                        label: "Boy"
                    )
                }
                
                if let goal = profileManager.userProfile.goal {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                        Text("Məqsəd:")
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
            Text("Tənzimləmələr")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Bildirişlər",
                    badge: settingsManager.notificationsEnabled ? "Aktiv" : nil,
                    badgeColor: .green
                ) {
                    showNotifications = true
                }
                
                SettingsRow(
                    icon: "lock.fill",
                    title: "Təhlükəsizlik",
                    badge: settingsManager.faceIDEnabled || settingsManager.hasAppPassword ? "🔒" : nil,
                    badgeColor: .blue
                ) {
                    showSecurity = true
                }
                
                SettingsRow(
                    icon: "star.fill",
                    title: "Premium",
                    badge: settingsManager.isPremium ? "👑" : nil,
                    badgeColor: .yellow
                ) {
                    showPremium = true
                }
                
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Haqqında"
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
                Text("Çıxış")
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
    ClientProfileView(isLoggedIn: .constant(true))
}
