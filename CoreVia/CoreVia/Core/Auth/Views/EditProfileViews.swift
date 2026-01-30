//
//  EditProfileViews.swift
//  CoreVia
//
//  Profil redaktə view-ləri - Müştəri və Müəllim
//

import SwiftUI

// MARK: - Edit Client Profile
struct EditClientProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var profileManager = UserProfileManager.shared
    
    @State private var name: String
    @State private var email: String
    @State private var age: String
    @State private var weight: String
    @State private var height: String
    @State private var goal: String
    
    init() {
        let profile = UserProfileManager.shared.userProfile
        _name = State(initialValue: profile.name)
        _email = State(initialValue: profile.email)
        _age = State(initialValue: "\(profile.age ?? 0)")
        _weight = State(initialValue: "\(Int(profile.weight ?? 0))")
        _height = State(initialValue: "\(Int(profile.height ?? 0))")
        _goal = State(initialValue: profile.goal ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Name
                        EditField(
                            label: "Ad və Soyad",
                            icon: "person.fill",
                            text: $name
                        )
                        
                        // Email
                        EditField(
                            label: "Email",
                            icon: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        // Age
                        EditField(
                            label: "Yaş",
                            icon: "calendar",
                            text: $age,
                            keyboardType: .numberPad
                        )
                        
                        // Weight
                        EditField(
                            label: "Çəki (kg)",
                            icon: "scalemass",
                            text: $weight,
                            keyboardType: .decimalPad
                        )
                        
                        // Height
                        EditField(
                            label: "Boy (sm)",
                            icon: "ruler",
                            text: $height,
                            keyboardType: .numberPad
                        )
                        
                        // Goal
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Məqsəd")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            HStack(spacing: 12) {
                                ForEach(["Arıqlamaq", "Əzələ toplamaq", "Sağlam qalmaq"], id: \.self) { option in
                                    GoalChip(
                                        title: option,
                                        isSelected: goal == option
                                    ) {
                                        goal = option
                                    }
                                }
                            }
                        }
                        
                        // Save Button
                        Button {
                            saveProfile()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Saxla")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profili Redaktə Et")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func saveProfile() {
        var updatedProfile = profileManager.userProfile
        updatedProfile.name = name
        updatedProfile.email = email
        updatedProfile.age = Int(age)
        updatedProfile.weight = Double(weight)
        updatedProfile.height = Double(height)
        updatedProfile.goal = goal
        
        profileManager.saveProfile(updatedProfile)
        dismiss()
    }
}

// MARK: - Edit Trainer Profile
struct EditTrainerProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var profileManager = UserProfileManager.shared
    
    @State private var name: String
    @State private var email: String
    @State private var specialty: String
    @State private var experience: String
    @State private var bio: String
    
    init() {
        let profile = UserProfileManager.shared.userProfile
        _name = State(initialValue: profile.name)
        _email = State(initialValue: profile.email)
        _specialty = State(initialValue: profile.specialty ?? "")
        _experience = State(initialValue: "\(profile.experience ?? 0)")
        _bio = State(initialValue: profile.bio ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Name
                        EditField(
                            label: "Ad və Soyad",
                            icon: "person.fill",
                            text: $name
                        )
                        
                        // Email
                        EditField(
                            label: "Email",
                            icon: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        // Specialty
                        VStack(alignment: .leading, spacing: 8) {
                            Text("İxtisas")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            VStack(spacing: 8) {
                                ForEach(["Fitness Coach", "Strength Trainer", "Yoga Instructor", "Nutrition Specialist"], id: \.self) { option in
                                    SpecialtyRow(
                                        title: option,
                                        isSelected: specialty == option
                                    ) {
                                        specialty = option
                                    }
                                }
                            }
                        }
                        
                        // Experience
                        EditField(
                            label: "Təcrübə (il)",
                            icon: "calendar",
                            text: $experience,
                            keyboardType: .numberPad
                        )
                        
                        // Bio
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Haqqımda")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            ZStack(alignment: .topLeading) {
                                if bio.isEmpty {
                                    Text("Özünüz haqqında qısa məlumat yazın...")
                                        .foregroundColor(AppTheme.Colors.tertiaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                }
                                
                                TextEditor(text: $bio)
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .scrollContentBackground(.hidden)
                                    .frame(height: 100)
                                    .padding(8)
                            }
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                        }
                        
                        // Save Button
                        Button {
                            saveProfile()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Saxla")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profili Redaktə Et")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func saveProfile() {
        var updatedProfile = profileManager.userProfile
        updatedProfile.name = name
        updatedProfile.email = email
        updatedProfile.specialty = specialty
        updatedProfile.experience = Int(experience)
        updatedProfile.bio = bio
        
        profileManager.saveProfile(updatedProfile)
        dismiss()
    }
}

// MARK: - Components

struct EditField: View {
    let label: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.red)
                    .frame(width: 20)
                
                TextField("", text: $text)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }
}

struct GoalChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppTheme.Colors.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.red : AppTheme.Colors.secondaryBackground)
                .cornerRadius(8)
        }
    }
}

struct SpecialtyRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.red : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview("Client") {
    EditClientProfileView()
}

#Preview("Trainer") {
    EditTrainerProfileView()
}
