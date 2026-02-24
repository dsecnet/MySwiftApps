//
//  AICalorieHistoryView.swift
//  CoreVia
//
//  Kecmish AI kalori analiz tarixcesi
//  Movcut app dizaynina uygun (AppTheme, card radius, shadow)
//

import SwiftUI

struct AICalorieHistoryView: View {
    @StateObject private var viewModel = AICalorieHistoryViewModel()
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
            } else if viewModel.items.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.items) { item in
                            historyCard(item)
                        }

                        if viewModel.hasMore {
                            ProgressView()
                                .onAppear {
                                    Task { await viewModel.loadMore() }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(loc.localized("ai_calorie_history_title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadHistory(refresh: true)
        }
        .refreshable {
            await viewModel.loadHistory(refresh: true)
        }
    }

    // MARK: - History Card

    private func historyCard(_ item: CalorieHistoryItem) -> some View {
        HStack(spacing: 14) {
            // Photo thumbnail
            if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    AppTheme.Colors.accent.opacity(0.1)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(AppTheme.CornerRadius.md)
            } else {
                ZStack {
                    AppTheme.Colors.accent.opacity(0.1)
                    Image(systemName: "fork.knife")
                        .foregroundColor(AppTheme.Colors.accent)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(AppTheme.CornerRadius.md)
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(Int(item.totalCalories)) kcal")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.Colors.accent)

                    Spacer()

                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                // Macros
                HStack(spacing: 12) {
                    macroTag("P: \(Int(item.totalProtein))g", color: .blue)
                    macroTag("K: \(Int(item.totalCarbs))g", color: .orange)
                    macroTag("Y: \(Int(item.totalFat))g", color: .purple)
                }

                Text("\(item.foodCount) qida a\u{015F}kar edildi")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.tertiaryText)
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    private func macroTag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(loc.localized("ai_calorie_history_empty"))
                .font(.headline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(loc.localized("ai_calorie_history_empty_desc"))
                .font(.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - ViewModel

@MainActor
class AICalorieHistoryViewModel: ObservableObject {
    @Published var items: [CalorieHistoryItem] = []
    @Published var isLoading = false
    @Published var hasMore = true

    private var currentPage = 1
    private let pageSize = 20

    func loadHistory(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            hasMore = true
        }
        guard !isLoading else { return }
        isLoading = true

        do {
            let response = try await AICalorieService.shared.getHistory(
                page: currentPage,
                pageSize: pageSize
            )

            if refresh {
                items = response.analyses
            } else {
                items.append(contentsOf: response.analyses)
            }

            hasMore = response.hasMore
            currentPage += 1
        } catch {
            print("AI Calorie history error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMore, !isLoading else { return }
        await loadHistory()
    }
}
