//
//  TrainerHubView.swift
//  CoreVia
//
//  Trainer Hub — "Canli Sessiyalar" ve "Market" alt bolmeleri
//  Movcut dizayn uslubu qorunur (AppTheme, FilterChip, card radius, shadow)
//

import SwiftUI

struct TrainerHubView: View {
    @State private var selectedSegment: HubSegment = .sessions
    @ObservedObject private var loc = LocalizationManager.shared

    enum HubSegment: String, CaseIterable {
        case sessions
        case market
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Segmented Picker
                segmentedPicker
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // Content
                switch selectedSegment {
                case .sessions:
                    TrainerSessionsView()
                case .market:
                    TrainerMarketplaceView()
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(loc.localized("trainer_hub_title"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(loc.localized("trainer_hub_subtitle"))
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Segmented Picker (app dizaynina uygun)

    private var segmentedPicker: some View {
        HStack(spacing: 0) {
            ForEach(HubSegment.allCases, id: \.self) { segment in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSegment = segment
                    }
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: segment == .sessions ? "video.fill" : "bag.fill")
                                .font(.system(size: 14))
                            Text(segmentTitle(segment))
                                .font(.system(size: 15, weight: selectedSegment == segment ? .semibold : .regular))
                        }
                        .foregroundColor(selectedSegment == segment ? .white : AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedSegment == segment ?
                            AnyView(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(AppTheme.Colors.accent)
                                    .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 6, x: 0, y: 3)
                            ) :
                            AnyView(Color.clear)
                        )
                    }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(AppTheme.Colors.secondaryBackground)
        )
    }

    private func segmentTitle(_ segment: HubSegment) -> String {
        switch segment {
        case .sessions: return loc.localized("trainer_hub_sessions")
        case .market: return loc.localized("trainer_hub_market")
        }
    }
}
