//
//  AIRecommendationView.swift
//  CoreVia
//
//  AI Tovsiye ekrani — backend ML-den ferdileshdirilmish tovsiyeler
//  Movcut app dizaynina tam uygun (AppTheme, card radius, shadow)
//

import SwiftUI
import os.log

struct AIRecommendationView: View {
    @StateObject private var viewModel = AIRecommendationViewModel()
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var selectedType: String = "all"

    let types = ["all", "workout", "meal", "hydration", "sleep", "rest"]

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Filter Chips
                filterSection

                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppTheme.Colors.accent)
                    Spacer()
                } else if viewModel.recommendations.isEmpty {
                    emptyState
                } else {
                    recommendationsListView
                }
            }
        }
        .navigationTitle(loc.localized("ai_recommendation_title"))
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadRecommendations()
        }
        .refreshable {
            await viewModel.loadRecommendations()
        }
        .alert("Xeta", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(types, id: \.self) { type in
                    FilterChip(
                        title: typeTitle(type),
                        icon: typeIcon(type),
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                        Task {
                            await viewModel.loadRecommendations(type: type == "all" ? nil : type)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Recommendations List

    private var recommendationsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.recommendations) { rec in
                    RecommendationCard(recommendation: rec)
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(loc.localized("ai_recommendation_empty"))
                .font(.headline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(loc.localized("ai_recommendation_empty_desc"))
                .font(.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private func typeTitle(_ type: String) -> String {
        switch type {
        case "all": return loc.localized("ai_rec_all")
        case "workout": return loc.localized("ai_rec_workout")
        case "meal": return loc.localized("ai_rec_meal")
        case "hydration": return loc.localized("ai_rec_hydration")
        case "sleep": return loc.localized("ai_rec_sleep")
        case "rest": return loc.localized("ai_rec_rest")
        default: return type.capitalized
        }
    }

    private func typeIcon(_ type: String) -> String {
        switch type {
        case "all": return "sparkles"
        case "workout": return "figure.run"
        case "meal": return "fork.knife"
        case "hydration": return "drop.fill"
        case "sleep": return "moon.fill"
        case "rest": return "leaf.fill"
        default: return "star"
        }
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let recommendation: AIRecommendation

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Priority Badge + Type
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

                // Title
                Text(recommendation.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                // Description
                Text(recommendation.description)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
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

// MARK: - ViewModel

@MainActor
class AIRecommendationViewModel: ObservableObject {
    @Published var recommendations: [AIRecommendation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadRecommendations(type: String? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            let response: AIRecommendationResponse
            if let type = type {
                response = try await AIRecommendationService.shared.getRecommendations(type: type)
            } else {
                response = try await AIRecommendationService.shared.getRecommendations()
            }
            recommendations = response.recommendations
        } catch {
            AppLogger.ml.error("AI recommendation fetch xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
