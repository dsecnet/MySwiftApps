//
//  OnboardingView.swift
//  CoreVia
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var onboardingManager = OnboardingManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var currentStep = 0
    @State private var selectedGoal: String = ""
    @State private var selectedLevel: String = ""
    @State private var selectedTrainerType: String? = nil
    @State private var isSubmitting = false
    @Binding var isCompleted: Bool

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { step in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(step <= currentStep ? AppTheme.Colors.accent : AppTheme.Colors.separator)
                            .frame(height: 6)
                    }
                }
                .padding()

                // Content
                TabView(selection: $currentStep) {
                    goalStep.tag(0)
                    levelStep.tag(1)
                    trainerTypeStep.tag(2)
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
                        if currentStep < 2 {
                            withAnimation { currentStep += 1 }
                        } else {
                            submitOnboarding()
                        }
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text(currentStep < 2 ? loc.localized("onboarding_next") : loc.localized("onboarding_finish"))
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
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0: return !selectedGoal.isEmpty
        case 1: return !selectedLevel.isEmpty
        case 2: return true
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

    // MARK: - Step 3: Preferred Trainer Type
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
            let success = await onboardingManager.complete(
                goal: selectedGoal,
                level: selectedLevel,
                trainerType: selectedTrainerType
            )
            isSubmitting = false
            if success {
                isCompleted = true
            }
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
