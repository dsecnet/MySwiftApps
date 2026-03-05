//
//  SmartRecommendationView.swift
//  CoreVia
//
//  Data-driven AI Tovsiye ekrani
//  Backend ML-den ferdileshdirilmish tovsiyeler
//  Client + Trainer ucun ferqli layout
//

import SwiftUI

struct SmartRecommendationView: View {
    @StateObject private var viewModel = SmartRecommendationViewModel()
    @ObservedObject private var loc = LocalizationManager.shared

    private var isTrainer: Bool {
        UserProfileManager.shared.userProfile.userType == .trainer
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            if viewModel.isLoading {
                loadingState
            } else if let error = viewModel.errorMessage {
                errorState(error)
            } else {
                contentView
            }
        }
        .navigationTitle(loc.localized("ai_recommendation_title"))
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // 1. Heftelik Skor
                if let score = viewModel.weeklyScore {
                    weeklyScoreCard(score: score)
                }

                // 2. Xulase
                if let summary = viewModel.summary, !summary.isEmpty {
                    summaryCard(summary)
                }

                // 3. Bu Hefte vs Kecen Hefte
                if let comparison = viewModel.weeklyComparison {
                    weeklyComparisonSection(comparison)
                }

                // 4. Indi senin ucun (time-based tip)
                if let tip = viewModel.timeBasedTip {
                    timeBasedSection(tip)
                }

                // 5. Butun Tovsiyeler
                if !viewModel.recommendations.isEmpty {
                    allRecommendationsSection
                }

                // 6. Xeberdarlar
                if let warnings = viewModel.warnings, !warnings.isEmpty {
                    warningsSection(warnings)
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
    }

    // MARK: - Weekly Score Ring

    private func weeklyScoreCard(score: Int) -> some View {
        VStack(spacing: 16) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(AppTheme.Colors.secondaryBackground, lineWidth: 12)
                    .frame(width: 120, height: 120)

                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100.0)
                    .stroke(
                        scoreColor(score),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: score)

                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(scoreColor(score))

                    Text("/100")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }

            Text(scoreLabel(score))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }

    // MARK: - Summary Card

    private func summaryCard(_ summary: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "text.quote")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.Colors.accent)
                .padding(.top, 2)

            Text(summary)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.primaryText)
                .lineSpacing(4)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
    }

    // MARK: - Weekly Comparison

    private func weeklyComparisonSection(_ comparison: WeeklyComparison) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(AppTheme.Colors.accent)
                Text(loc.localized("ai_rec_weekly_compare"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            HStack(spacing: 12) {
                ComparisonCard(
                    icon: "figure.run",
                    label: loc.localized("ai_rec_workout"),
                    change: comparison.workoutChange,
                    unit: "",
                    color: AppTheme.Colors.accent
                )

                ComparisonCard(
                    icon: "flame.fill",
                    label: loc.localized("home_calories"),
                    change: comparison.calorieChange,
                    unit: "kcal",
                    color: .orange
                )

                ComparisonCard(
                    icon: "fork.knife",
                    label: "Protein",
                    change: 0,
                    unit: "g",
                    color: .blue,
                    displayValue: String(format: "%.0f", comparison.proteinAvg)
                )
            }
        }
    }

    // MARK: - Time-Based Section

    private func timeBasedSection(_ tip: AIRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.purple)
                Text(loc.localized("ai_rec_now_for_you"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: tipIcon(tip.type))
                        .font(.system(size: 18))
                        .foregroundColor(.purple)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(tip.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(tip.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.05), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - All Recommendations

    private var allRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundColor(AppTheme.Colors.accent)
                Text(loc.localized("ai_rec_all_tips"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            ForEach(viewModel.recommendations) { rec in
                SmartRecCard(recommendation: rec)
            }
        }
    }

    // MARK: - Warnings

    private func warningsSection(_ warnings: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppTheme.Colors.error)
                Text(loc.localized("ai_rec_warnings"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            ForEach(warnings, id: \.self) { warning in
                HStack(spacing: 10) {
                    Circle()
                        .fill(AppTheme.Colors.error)
                        .frame(width: 6, height: 6)

                    Text(warning)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
            .padding()
            .background(AppTheme.Colors.error.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.error.opacity(0.15), lineWidth: 1)
            )
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppTheme.Colors.accent)

            Text(loc.localized("ai_rec_loading"))
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.secondaryText)
            Spacer()
        }
    }

    // MARK: - Error State

    private func errorState(_ error: String) -> some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(loc.localized("ai_rec_error_title"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(error)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                Task { await viewModel.load() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text(loc.localized("ai_rec_retry"))
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.accent)
                .cornerRadius(12)
            }

            Spacer()
        }
    }

    // MARK: - Helpers

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return AppTheme.Colors.success }
        if score >= 60 { return AppTheme.Colors.accent }
        if score >= 40 { return .orange }
        return AppTheme.Colors.error
    }

    private func scoreLabel(_ score: Int) -> String {
        if score >= 80 { return loc.localized("ai_rec_score_great") }
        if score >= 60 { return loc.localized("ai_rec_score_good") }
        if score >= 40 { return loc.localized("ai_rec_score_average") }
        return loc.localized("ai_rec_score_improve")
    }

    private func tipIcon(_ type: String) -> String {
        switch type {
        case "workout": return "figure.run"
        case "meal": return "fork.knife"
        case "hydration": return "drop.fill"
        case "sleep": return "moon.fill"
        case "rest": return "leaf.fill"
        default: return "sparkles"
        }
    }
}

// MARK: - Smart Recommendation Card

struct SmartRecCard: View {
    let recommendation: AIRecommendation

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(typeName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(iconColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(iconColor.opacity(0.1))
                        .cornerRadius(6)

                    if recommendation.priority == 1 {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 9))
                            Text(LocalizationManager.shared.localized("ai_rec_important"))
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(AppTheme.Colors.error)
                    }

                    Spacer()
                }

                Text(recommendation.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(recommendation.description)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var iconName: String {
        if let customIcon = recommendation.iconName {
            return customIcon
        }
        switch recommendation.type {
        case "workout": return "figure.run"
        case "meal": return "fork.knife"
        case "hydration": return "drop.fill"
        case "sleep": return "moon.fill"
        case "rest": return "leaf.fill"
        default: return "sparkles"
        }
    }

    private var iconColor: Color {
        switch recommendation.type {
        case "workout": return AppTheme.Colors.accent
        case "meal": return .orange
        case "hydration": return .blue
        case "sleep": return .purple
        case "rest": return AppTheme.Colors.success
        default: return AppTheme.Colors.accent
        }
    }

    private var typeName: String {
        let loc = LocalizationManager.shared
        switch recommendation.type {
        case "workout": return loc.localized("ai_rec_workout")
        case "meal": return loc.localized("ai_rec_meal")
        case "hydration": return loc.localized("ai_rec_hydration")
        case "sleep": return loc.localized("ai_rec_sleep")
        case "rest": return loc.localized("ai_rec_rest")
        default: return recommendation.type.capitalized
        }
    }
}

// MARK: - Comparison Card

struct ComparisonCard: View {
    let icon: String
    let label: String
    let change: Int
    let unit: String
    let color: Color
    var displayValue: String? = nil

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            if let display = displayValue {
                Text("\(display)\(unit.isEmpty ? "" : " \(unit)")")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            } else {
                HStack(spacing: 2) {
                    if change > 0 {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.Colors.success)
                    } else if change < 0 {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.Colors.error)
                    }

                    Text("\(change > 0 ? "+" : "")\(change)\(unit.isEmpty ? "" : " \(unit)")")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(change > 0 ? AppTheme.Colors.success : (change < 0 ? AppTheme.Colors.error : AppTheme.Colors.primaryText))
                }
            }

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - ViewModel

@MainActor
class SmartRecommendationViewModel: ObservableObject {
    @Published var recommendations: [AIRecommendation] = []
    @Published var weeklyScore: Int?
    @Published var summary: String?
    @Published var weeklyComparison: WeeklyComparison?
    @Published var timeBasedTip: AIRecommendation?
    @Published var warnings: [String]?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await AIRecommendationService.shared.getRecommendations()
            recommendations = response.recommendations
            weeklyScore = response.weeklyScore
            summary = response.summary
            weeklyComparison = response.weeklyComparison
            timeBasedTip = response.timeBasedTip
            warnings = response.warnings?.isEmpty == true ? nil : response.warnings
        } catch {
            AppLogger.ml.error("Smart recommendation fetch xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
