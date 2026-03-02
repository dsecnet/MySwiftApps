//
//  DailySurveyView.swift
//  CoreVia
//
//  Gundelik veziyet sorgusu ekrani
//  Her sual bir card seklinde — slider/number input
//  AppTheme dizaynina tam uygun
//

import SwiftUI
import os.log

struct DailySurveyView: View {
    @StateObject private var viewModel = DailySurveyViewModel()
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppTheme.Colors.accent)
                } else if viewModel.isCompleted {
                    completedView
                } else {
                    surveyFormView
                }
            }
            .navigationTitle(loc.localized("daily_survey_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                }
            }
            .task {
                await viewModel.checkTodayStatus()
            }
            .alert(loc.localized("common_error"), isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Survey Form

    private var surveyFormView: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Enerji
                SurveySliderCard(
                    title: loc.localized("daily_survey_energy"),
                    description: loc.localized("daily_survey_energy_desc"),
                    value: $viewModel.energyLevel,
                    range: 1...5,
                    emojiLabels: ["😴", "😐", "🙂", "😊", "⚡"],
                    color: .orange
                )

                // Yuxu saati
                SurveyNumberCard(
                    title: loc.localized("daily_survey_sleep"),
                    description: loc.localized("daily_survey_sleep_desc"),
                    value: $viewModel.sleepHours,
                    range: 0...24,
                    unit: loc.localized("daily_survey_hours"),
                    icon: "moon.fill",
                    color: .purple
                )

                // Yuxu keyfiyyeti
                SurveySliderCard(
                    title: loc.localized("daily_survey_sleep_quality"),
                    description: loc.localized("daily_survey_sleep_quality_desc"),
                    value: $viewModel.sleepQuality,
                    range: 1...5,
                    emojiLabels: ["😫", "😕", "😐", "😊", "😴"],
                    color: .purple
                )

                // Stress
                SurveySliderCard(
                    title: loc.localized("daily_survey_stress"),
                    description: loc.localized("daily_survey_stress_desc"),
                    value: $viewModel.stressLevel,
                    range: 1...5,
                    emojiLabels: ["😌", "🙂", "😐", "😰", "🤯"],
                    color: .red
                )

                // Ezele agrisi
                SurveySliderCard(
                    title: loc.localized("daily_survey_soreness"),
                    description: loc.localized("daily_survey_soreness_desc"),
                    value: $viewModel.muscleSoreness,
                    range: 1...5,
                    emojiLabels: ["💪", "🙂", "😐", "😣", "🥵"],
                    color: AppTheme.Colors.accent
                )

                // Ehval
                SurveySliderCard(
                    title: loc.localized("daily_survey_mood"),
                    description: loc.localized("daily_survey_mood_desc"),
                    value: $viewModel.mood,
                    range: 1...5,
                    emojiLabels: ["😢", "😕", "😐", "😊", "🤩"],
                    color: AppTheme.Colors.success
                )

                // Su
                SurveyStepperCard(
                    title: loc.localized("daily_survey_water"),
                    description: loc.localized("daily_survey_water_desc"),
                    value: $viewModel.waterGlasses,
                    range: 0...20,
                    icon: "drop.fill",
                    color: .blue
                )

                // Gonder buttonu
                Button(action: {
                    Task { await viewModel.submitSurvey() }
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        Text(loc.localized("daily_survey_submit"))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(AppTheme.CornerRadius.md)
                }
                .disabled(viewModel.isSubmitting)
                .padding(.top, 8)
            }
            .padding()
            .padding(.bottom, 40)
        }
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.success)

            Text(loc.localized("daily_survey_completed"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(loc.localized("daily_survey_completed_desc"))
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button(action: { dismiss() }) {
                Text(loc.localized("common_close"))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(AppTheme.CornerRadius.md)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Survey Slider Card

struct SurveySliderCard: View {
    let title: String
    let description: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let emojiLabels: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                Spacer()
                Text(currentEmoji)
                    .font(.system(size: 28))
            }

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.secondaryText)

            // Emoji row
            HStack {
                ForEach(Array(emojiLabels.enumerated()), id: \.offset) { index, emoji in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            value = index + range.lowerBound
                        }
                    }) {
                        Text(emoji)
                            .font(.system(size: isSelected(index) ? 32 : 22))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                isSelected(index) ? color.opacity(0.15) : Color.clear
                            )
                            .cornerRadius(10)
                            .scaleEffect(isSelected(index) ? 1.1 : 1.0)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    private var currentEmoji: String {
        let idx = value - range.lowerBound
        guard idx >= 0, idx < emojiLabels.count else { return "" }
        return emojiLabels[idx]
    }

    private func isSelected(_ index: Int) -> Bool {
        return value == index + range.lowerBound
    }
}

// MARK: - Survey Number Card

struct SurveyNumberCard: View {
    let title: String
    let description: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                Text(String(format: "%.1f %@", value, unit))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(color)
            }

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.secondaryText)

            Slider(value: $value, in: range, step: 0.5)
                .tint(color)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Survey Stepper Card

struct SurveyStepperCard: View {
    let title: String
    let description: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()
            }

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.secondaryText)

            HStack(spacing: 16) {
                Button(action: {
                    if value > range.lowerBound {
                        withAnimation { value -= 1 }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(value > range.lowerBound ? color : AppTheme.Colors.tertiaryText)
                }
                .disabled(value <= range.lowerBound)

                HStack(spacing: 4) {
                    Text("\(value)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Image(systemName: "drop.fill")
                        .foregroundColor(color)
                        .font(.system(size: 16))
                }
                .frame(minWidth: 80)

                Button(action: {
                    if value < range.upperBound {
                        withAnimation { value += 1 }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(value < range.upperBound ? color : AppTheme.Colors.tertiaryText)
                }
                .disabled(value >= range.upperBound)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - ViewModel

@MainActor
class DailySurveyViewModel: ObservableObject {
    @Published var energyLevel: Int = 3
    @Published var sleepHours: Double = 7.0
    @Published var sleepQuality: Int = 3
    @Published var stressLevel: Int = 3
    @Published var muscleSoreness: Int = 1
    @Published var mood: Int = 3
    @Published var waterGlasses: Int = 4

    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var isCompleted = false
    @Published var errorMessage: String?

    func checkTodayStatus() async {
        isLoading = true
        do {
            let status = try await DailySurveyService.shared.getTodayStatus()
            if status.completed, let survey = status.survey {
                // Movcud deyerleri doldur
                energyLevel = survey.energyLevel
                sleepHours = survey.sleepHours
                sleepQuality = survey.sleepQuality
                stressLevel = survey.stressLevel
                muscleSoreness = survey.muscleSoreness
                mood = survey.mood
                waterGlasses = survey.waterGlasses
                isCompleted = true
            }
        } catch {
            // Ilk defe giris — survey yoxdur, normaldir
            AppLogger.general.debug("Survey status: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func submitSurvey() async {
        isSubmitting = true
        errorMessage = nil

        let request = DailySurveyRequest(
            energyLevel: energyLevel,
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            stressLevel: stressLevel,
            muscleSoreness: muscleSoreness,
            mood: mood,
            waterGlasses: waterGlasses,
            notes: nil
        )

        do {
            _ = try await DailySurveyService.shared.submitSurvey(request)
            withAnimation {
                isCompleted = true
            }
        } catch {
            AppLogger.general.error("Submit daily survey xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }
}
