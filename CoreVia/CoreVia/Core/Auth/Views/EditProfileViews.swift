
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
                        
                        EditField(
                            label: loc.localized("edit_name"),
                            icon: "person.fill",
                            text: $name
                        )

                        EditField(
                            label: loc.localized("common_email"),
                            icon: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        EditField(
                            label: loc.localized("edit_age"),
                            icon: "calendar",
                            text: $age,
                            keyboardType: .numberPad
                        )
                        .onChange(of: age) { val in
                            age = val.filter { $0.isNumber }
                            if let n = Int(age), n > 120 { age = "120" }
                        }

                        EditField(
                            label: loc.localized("edit_weight"),
                            icon: "scalemass",
                            text: $weight,
                            keyboardType: .decimalPad
                        )
                        .onChange(of: weight) { val in
                            weight = val.filter { $0.isNumber || $0 == "." }
                            if let n = Double(weight), n > 500 { weight = "500" }
                        }

                        EditField(
                            label: loc.localized("edit_height"),
                            icon: "ruler",
                            text: $height,
                            keyboardType: .numberPad
                        )
                        .onChange(of: height) { val in
                            height = val.filter { $0.isNumber }
                            if let n = Int(height), n > 300 { height = "300" }
                        }

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
                            .background(AppTheme.Colors.accent)
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
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
    }

    private var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard trimmedName.count >= 2 else { return false }
        if let a = Int(age), (a < 13 || a > 120) { return false }
        if let w = Double(weight), (w < 20 || w > 500) { return false }
        if let h = Double(height), (h < 50 || h > 300) { return false }
        return true
    }

    private func saveProfile() {
        guard isFormValid else { return }
        var updatedProfile = profileManager.userProfile
        updatedProfile.name = name.trimmingCharacters(in: .whitespaces)
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
    @State private var pricePerSession: String
    @State private var instagramHandle: String

    init() {
        let profile = UserProfileManager.shared.userProfile
        _name = State(initialValue: profile.name)
        _email = State(initialValue: profile.email)
        _specialty = State(initialValue: profile.specialty ?? "")
        _experience = State(initialValue: "\(profile.experience ?? 0)")
        _bio = State(initialValue: profile.bio ?? "")
        _pricePerSession = State(initialValue: profile.pricePerSession != nil ? String(format: "%.0f", profile.pricePerSession!) : "")
        _instagramHandle = State(initialValue: "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        EditField(
                            label: loc.localized("edit_name"),
                            icon: "person.fill",
                            text: $name
                        )

                        EditField(
                            label: loc.localized("common_email"),
                            icon: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("edit_specialty"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            VStack(spacing: 8) {
                                                ForEach([
                                    loc.localized("specialty_fitness"),
                                    loc.localized("specialty_strength"),
                                    loc.localized("specialty_yoga"),
                                    loc.localized("specialty_nutrition"),
                                    loc.localized("specialty_cardio"),
                                    loc.localized("specialty_bodybuilding")
                                ], id: \.self) { option in
                                    SpecialtyRow(
                                        title: option,
                                        isSelected: specialty == option
                                    ) {
                                        specialty = option
                                    }
                                }
                            }
                        }
                        
                        EditField(
                            label: loc.localized("edit_experience"),
                            icon: "calendar",
                            text: $experience,
                            keyboardType: .numberPad
                        )
                        .onChange(of: experience) { val in
                            experience = val.filter { $0.isNumber }
                            if let n = Int(experience), n > 60 { experience = "60" }
                        }

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
                                    .onChange(of: bio) { val in
                                        if val.count > 1000 { bio = String(val.prefix(1000)) }
                                    }
                            }
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                        }

                        EditField(
                            label: loc.localized("trainer_price_per_session"),
                            icon: "manatsign",
                            text: $pricePerSession,
                            keyboardType: .decimalPad
                        )
                        .onChange(of: pricePerSession) { val in
                            pricePerSession = val.filter { $0.isNumber || $0 == "." }
                            if let n = Double(pricePerSession), n > 10000 { pricePerSession = "10000" }
                        }

                        EditField(
                            label: loc.localized("trainer_instagram"),
                            icon: "camera.fill",
                            text: $instagramHandle
                        )

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
                            .background(AppTheme.Colors.accent)
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
                    .foregroundColor(AppTheme.Colors.accent)
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
        updatedProfile.pricePerSession = Double(pricePerSession)

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
                    .foregroundColor(AppTheme.Colors.accent)
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
                .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.secondaryBackground)
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
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.Colors.accent : Color.clear, lineWidth: 2)
            )
        }
    }
}

// #Preview("Client") { // iOS 17+ only
//     EditClientProfileView()
// }
//
// #Preview("Trainer") { // iOS 17+ only
//     EditTrainerProfileView()
// }
