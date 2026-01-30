
import SwiftUI
import PhotosUI

struct ProfileView: View {
    
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
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileHeader
                    userTypeSwitcher
                    
                    if profileManager.userProfile.userType == .client {
                        clientStatsSection
                    } else {
                        trainerStatsSection
                    }
                    
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
            if profileManager.userProfile.userType == .client {
                EditClientProfileView()
            } else {
                EditTrainerProfileView()
            }
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
                                colors: [Color.red.opacity(0.3), Color.red],
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
                .shadow(color: Color.red.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Premium Badge
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
                            .fill(Color.red)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.red.opacity(0.5), radius: 8)
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
                
                Button {
                    showEditProfile = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Profili Redaktə Et")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - User Type Switcher
    private var userTypeSwitcher: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hesab Növü")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 12) {
                TypeButton(
                    title: "Müştəri",
                    icon: "person.fill",
                    isSelected: profileManager.userProfile.userType == .client
                ) {
                    withAnimation {
                        profileManager.updateUserType(.client)
                    }
                }
                
                TypeButton(
                    title: "Müəllim",
                    icon: "person.2.fill",
                    isSelected: profileManager.userProfile.userType == .trainer
                ) {
                    withAnimation {
                        profileManager.updateUserType(.trainer)
                    }
                }
            }
        }
    }
    
    // MARK: - Client Stats
    private var clientStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Məlumatlarım")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ClientStatCard(icon: "calendar", value: "\(profileManager.userProfile.age ?? 0)", label: "Yaş")
                    ClientStatCard(icon: "scalemass", value: "\(Int(profileManager.userProfile.weight ?? 0)) kg", label: "Çəki")
                    ClientStatCard(icon: "ruler", value: "\(Int(profileManager.userProfile.height ?? 0)) sm", label: "Boy")
                }
                
                if let goal = profileManager.userProfile.goal {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.red)
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
    
    // MARK: - Trainer Stats
    private var trainerStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Müəllim Statistikası")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TrainerStatCard(icon: "star.fill", value: String(format: "%.1f", profileManager.userProfile.rating ?? 4.8), label: "Reytinq", color: .yellow)
                    TrainerStatCard(icon: "person.2.fill", value: "\(profileManager.userProfile.students ?? 0)", label: "Tələbə", color: .blue)
                    TrainerStatCard(icon: "calendar", value: "\(profileManager.userProfile.experience ?? 0) il", label: "Təcrübə", color: .green)
                }
                
                if let specialty = profileManager.userProfile.specialty {
                    HStack {
                        Image(systemName: "medal.fill")
                            .foregroundColor(.red)
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



#Preview {
    ProfileView(isLoggedIn: .constant(true))
}
