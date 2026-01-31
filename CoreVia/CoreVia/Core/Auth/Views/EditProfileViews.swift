
import SwiftUI

// MARK: - Edit Client Profile
struct EditClientProfileView: View {

    private let loc = LocalizationManager.shared
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
                            label: loc.localized("edit_name"),
                            icon: "person.fill",
                            text: $name
                        )

                        // Email
                        EditField(
                            label: loc.localized("common_email"),
                            icon: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        // Age
                        EditField(
                            label: loc.localized("edit_age"),
                            icon: "calendar",
                            text: $age,
                            keyboardType: .numberPad
                        )

                        // Weight
                        EditField(
                            label: loc.localized("edit_weight"),
                            icon: "scalemass",
                            text: $weight,
                            keyboardType: .decimalPad
                        )

                        // Height
                        EditField(
                            label: loc.localized("edit_height"),
                            icon: "ruler",
                            text: $height,
                            keyboardType: .numberPad
                        )

                        // Goal
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("edit_goal"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            HStack(spacing: 12) {
                                ForEach([loc.localized("edit_goal_lose"), loc.localized("edit_goal_muscle"), loc.localized("edit_goal_healthy")], id: \.self) { option in
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
                                Text(loc.localized("common_save"))
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
            .navigationTitle(loc.localized("edit_profile_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_cancel")) {
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

    private let loc = LocalizationManager.shared
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
                            label: loc.localized("edit_name"),
                            icon: "person.fill",
                            text: $name
                        )

                        // Email
                        EditField(
                            label: loc.localized("common_email"),
                            icon: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        // Specialty
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("edit_specialty"))
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
                            label: loc.localized("edit_experience"),
                            icon: "calendar",
                            text: $experience,
                            keyboardType: .numberPad
                        )

                        // Bio
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("edit_bio"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            ZStack(alignment: .topLeading) {
                                if bio.isEmpty {
                                    Text(loc.localized("edit_bio_placeholder"))
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
                                Text(loc.localized("common_save"))
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
            .navigationTitle(loc.localized("edit_profile_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_cancel")) {
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
