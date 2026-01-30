//
//  TrainerProfileView.swift
//  CoreVia
//
//  MÜƏLLİM / TƏLİMÇİ PROFİL VIEW
//

import SwiftUI

struct TrainerProfileView: View {
    
    @Binding var isLoggedIn: Bool
    @StateObject private var imageManager = ProfileImageManager.shared
    @StateObject private var profileManager = UserProfileManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    
    @State private var showImagePicker = false
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showNotifications = false
    @State private var showSecurity = false
    @State private var showPremium = false
    @State private var showAbout = false
    @State private var showSwitchToClient = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileHeader
                    statsSection
                    studentsSection
                    specialtySection
                    settingsSection
                    switchAccountButton
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
        .sheet(isPresented: $showPremium) {
            PremiumView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .alert("Müştəri Hesabına Keç", isPresented: $showSwitchToClient) {
            Button("Ləğv et", role: .cancel) { }
            Button("Dəyiş") {
                withAnimation {
                    profileManager.updateUserType(.client)
                }
            }
        } message: {
            Text("Müştəri hesabına keçmək istədiyinizə əminsiniz?")
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
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                    Text("Müəllim")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                
                Button {
                    showEditProfile = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Profili Redaktə Et")
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
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistikalar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 12) {
                TrainerStatCard(
                    icon: "star.fill",
                    value: String(format: "%.1f", profileManager.userProfile.rating ?? 4.8),
                    label: "Reytinq",
                    color: .yellow
                )
                
                TrainerStatCard(
                    icon: "person.2.fill",
                    value: "\(profileManager.userProfile.students ?? 0)",
                    label: "Tələbə",
                    color: .blue
                )
                
                TrainerStatCard(
                    icon: "calendar",
                    value: "\(profileManager.userProfile.experience ?? 0) il",
                    label: "Təcrübə",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Students Section
    private var studentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Aktiv Tələbələr")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Spacer()
                
                Text("\(profileManager.userProfile.students ?? 0) nəfər")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            
            VStack(spacing: 12) {
                StudentRow(name: "Nigar Əliyeva", progress: 75, avatar: "💪")
                StudentRow(name: "Rəşad Məmmədov", progress: 60, avatar: "🏃")
                StudentRow(name: "Leyla Həsənova", progress: 90, avatar: "🧘")
                
                Button {
                    print("Hamısını gör")
                } label: {
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text("Bütün Tələbələr")
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
            Text("İxtisas və Bio")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            VStack(spacing: 12) {
                if let specialty = profileManager.userProfile.specialty {
                    HStack {
                        Image(systemName: "medal.fill")
                            .foregroundColor(.purple)
                        Text("İxtisas:")
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
                        Text("Bio:")
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
    
    // MARK: - Switch Account Button
    private var switchAccountButton: some View {
        Button {
            showSwitchToClient = true
        } label: {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                Text("Müştəri Hesabına Keç")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 1)
            )
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

struct StudentRow: View {
    let name: String
    let progress: Int
    let avatar: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(avatar)
                .font(.system(size: 30))
                .frame(width: 50, height: 50)
                .background(AppTheme.Colors.background)
                .clipShape(Circle())
            
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
