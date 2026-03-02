//
//  OnboardingView.swift
//  CoreVia
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var onboardingManager = OnboardingManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var profileManager = UserProfileManager.shared

    @State private var currentStep = 0
    @State private var selectedGoal: String = ""
    @State private var selectedLevel: String = ""
    @State private var selectedTrainerType: String? = nil
    @State private var isSubmitting = false

    // Yeni: Boy/Çəki/Yaş addımı üçün
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""

    private let totalSteps = 4 // 0: Goal, 1: Level, 2: Body info, 3: Trainer type

    // M08: Default placeholder values for body info fields
    private enum BodyDefaults {
        static let agePlaceholder = "25"
        static let weightPlaceholder = "70"
        static let heightPlaceholder = "175"
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { step in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(step <= currentStep ? AppTheme.Colors.accent : AppTheme.Colors.separator)
                            .frame(height: 6)
                    }
                }
                .padding()

                // Step counter
                Text("\(currentStep + 1)/\(totalSteps)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.secondaryText)

                // Content
                TabView(selection: $currentStep) {
                    goalStep.tag(0)
                    levelStep.tag(1)
                    bodyInfoStep.tag(2)
                    trainerTypeStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button {
                            withAnimation { currentStep -= 1 }
                        } label: {
                            Text(loc.localized("common_back"))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                        }
                    }

                    Button {
                        if currentStep < totalSteps - 1 {
                            withAnimation { currentStep += 1 }
                        } else {
                            submitOnboarding()
                        }
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text(currentStep < totalSteps - 1 ? loc.localized("onboarding_next") : loc.localized("onboarding_finish"))
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canProceed ? AppTheme.Colors.accent : AppTheme.Colors.separator)
                        .cornerRadius(12)
                    }
                    .disabled(!canProceed || isSubmitting)
                }
                .padding()
            }
        }
        .onAppear {
            Task { await onboardingManager.fetchOptions() }
            // Profildən mövcud dəyərləri yüklə
            if let userAge = profileManager.userProfile.age { age = "\(userAge)" }
            if let userWeight = profileManager.userProfile.weight { weight = "\(Int(userWeight))" }
            if let userHeight = profileManager.userProfile.height { height = "\(Int(userHeight))" }
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0: return !selectedGoal.isEmpty
        case 1: return !selectedLevel.isEmpty
        case 2: return !age.isEmpty && !weight.isEmpty && !height.isEmpty
        case 3: return true
        default: return false
        }
    }

    // MARK: - Step 1: Goal Selection
    private var goalStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(loc.localized("onboarding_goal_title"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(loc.localized("onboarding_goal_subtitle"))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            if let goals = onboardingManager.options?.goals {
                LazyVStack(spacing: 12) {
                    ForEach(goals, id: \.self) { goal in
                        let goalId = goal["id"] ?? ""
                        let name = localizedName(from: goal)
                        let icon = goal["icon"] ?? "circle"
                        OnboardingOptionCard(
                            icon: icon,
                            title: name,
                            isSelected: selectedGoal == goalId
                        ) {
                            selectedGoal = goalId
                        }
                    }
                }
            } else {
                ProgressView()
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Step 2: Fitness Level
    private var levelStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(loc.localized("onboarding_level_title"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(loc.localized("onboarding_level_subtitle"))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            if let levels = onboardingManager.options?.fitnessLevels {
                LazyVStack(spacing: 12) {
                    ForEach(levels, id: \.self) { level in
                        let levelId = level["id"] ?? ""
                        let name = localizedName(from: level)
                        let icon = level["icon"] ?? "circle"
                        OnboardingOptionCard(
                            icon: icon,
                            title: name,
                            isSelected: selectedLevel == levelId
                        ) {
                            selectedLevel = levelId
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Step 3: Body Info (Yaş, Çəki, Boy)
    private var bodyInfoStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(loc.localized("onboarding_body_title"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(loc.localized("onboarding_body_subtitle"))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            bodyInfoFields

            bmiIndicator

            Spacer()
        }
        .padding()
        .onChange(of: age) { val in age = String(val.prefix(3).filter { $0.isNumber }) }
        .onChange(of: weight) { val in weight = String(val.prefix(3).filter { $0.isNumber }) }
        .onChange(of: height) { val in height = String(val.prefix(3).filter { $0.isNumber }) }
    }

    private var bodyInfoFields: some View {
        VStack(spacing: 16) {
            BodyInfoRow(
                icon: "calendar",
                label: loc.localized("profile_age"),
                placeholder: BodyDefaults.agePlaceholder,
                text: $age,
                unit: loc.localized("onboarding_years"),
                isFilled: !age.isEmpty
            )

            BodyInfoRow(
                icon: "scalemass",
                label: loc.localized("profile_weight"),
                placeholder: BodyDefaults.weightPlaceholder,
                text: $weight,
                unit: "kg",
                isFilled: !weight.isEmpty
            )

            BodyInfoRow(
                icon: "ruler",
                label: loc.localized("profile_height"),
                placeholder: BodyDefaults.heightPlaceholder,
                text: $height,
                unit: "sm",
                isFilled: !height.isEmpty
            )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var bmiIndicator: some View {
        if let w = Double(weight), let h = Double(height), h > 0, w > 0 {
            let bmi = w / ((h / 100) * (h / 100))
            let color = bmiColor(bmi)
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Text("BMI: \(String(format: "%.1f", bmi)) — \(bmiCategory(bmi))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color.opacity(0.1))
            .cornerRadius(20)
        }
    }

    // BMI rəng və kateqoriya
    private func bmiColor(_ bmi: Double) -> Color {
        if bmi < 18.5 { return .blue }
        if bmi < 25 { return AppTheme.Colors.success }
        if bmi < 30 { return .orange }
        return AppTheme.Colors.error
    }

    private func bmiCategory(_ bmi: Double) -> String {
        if bmi < 18.5 { return loc.localized("bmi_underweight") }
        if bmi < 25 { return loc.localized("bmi_normal") }
        if bmi < 30 { return loc.localized("bmi_overweight") }
        return loc.localized("bmi_obese")
    }

    // MARK: - Step 4: Preferred Trainer Type
    private var trainerTypeStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(loc.localized("onboarding_trainer_title"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(loc.localized("onboarding_trainer_subtitle"))
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            if let types = onboardingManager.options?.trainerTypes {
                LazyVStack(spacing: 12) {
                    ForEach(types, id: \.self) { type in
                        let typeId = type["id"] ?? ""
                        let name = localizedName(from: type)
                        let icon = type["icon"] ?? "circle"
                        OnboardingOptionCard(
                            icon: icon,
                            title: name,
                            isSelected: selectedTrainerType == typeId
                        ) {
                            selectedTrainerType = typeId
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers
    private func localizedName(from dict: [String: String]) -> String {
        switch loc.currentLanguage {
        case .az: return dict["name_az"] ?? dict["id"] ?? ""
        case .en: return dict["name_en"] ?? dict["id"] ?? ""
        case .ru: return dict["name_ru"] ?? dict["id"] ?? ""
        }
    }

    private func submitOnboarding() {
        isSubmitting = true
        Task {
            // Əvvəlcə profili yenilə (Boy/Çəki/Yaş)
            if let ageVal = Int(age) { profileManager.userProfile.age = ageVal }
            if let weightVal = Double(weight) { profileManager.userProfile.weight = weightVal }
            if let heightVal = Double(height) { profileManager.userProfile.height = heightVal }
            profileManager.saveProfile(profileManager.userProfile)

            // Onboarding-i tamamla
            _ = await onboardingManager.complete(
                goal: selectedGoal,
                level: selectedLevel,
                trainerType: selectedTrainerType
            )
            isSubmitting = false
        }
    }
}

// MARK: - Onboarding Option Card
struct OnboardingOptionCard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.accent)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.accent.opacity(0.1))
                    .cornerRadius(12)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.primaryText)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .padding()
            .background(isSelected ? AppTheme.Colors.accent.opacity(0.1) : AppTheme.Colors.secondaryBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppTheme.Colors.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Body Info Row
struct BodyInfoRow: View {
    let icon: String
    let label: String
    let placeholder: String
    @Binding var text: String
    let unit: String
    let isFilled: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                TextField(placeholder, text: $text)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .keyboardType(.numberPad)
            }

            Text(unit)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isFilled ? AppTheme.Colors.accent.opacity(0.5) : AppTheme.Colors.separator, lineWidth: 1)
        )
    }
}
