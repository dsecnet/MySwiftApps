//
//  PremiumView.swift
//  CoreVia
//

import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var isLoading = false
    @State private var showCancelAlert = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if settingsManager.isPremium {
                            activePremiumSection
                        } else {
                            premiumOfferSection
                        }

                        featuresSection
                    }
                    .padding()
                }

                if isLoading {
                    PremiumLoadingOverlay()
                }
            }
            .navigationTitle(loc.localized("premium_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_close")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .alert(loc.localized("common_error"), isPresented: $showError) {
                Button(loc.localized("common_ok"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? loc.localized("common_unknown_error"))
            }
            .alert(loc.localized("premium_cancel_title"), isPresented: $showCancelAlert) {
                Button(loc.localized("common_cancel"), role: .cancel) {}
                Button(loc.localized("premium_cancel_yes"), role: .destructive) {
                    cancelPremium()
                }
            } message: {
                Text(loc.localized("premium_cancel_message"))
            }
        }
    }

    // MARK: - Active Premium Section
    private var activePremiumSection: some View {
        VStack(spacing: 16) {
            // Premium Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: AppTheme.Colors.premiumGradientStart.opacity(0.5), radius: 20)

                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)

            Text(loc.localized("premium_active"))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(loc.localized("premium_active_desc"))
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Plan Info
            VStack(spacing: 16) {
                InfoRow(
                    icon: "calendar",
                    title: loc.localized("premium_plan"),
                    value: loc.localized("premium_monthly")
                )

                Divider()
                    .background(AppTheme.Colors.tertiaryText.opacity(0.3))

                InfoRow(
                    icon: "creditcard",
                    title: loc.localized("premium_price"),
                    value: "9.99 ₼/\(loc.localized("premium_month"))"
                )
            }
            .padding(20)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(20)

            // Cancel Button
            Button {
                showCancelAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 18))
                    Text(loc.localized("premium_cancel_button"))
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(AppTheme.Colors.error)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.error.opacity(0.1))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.Colors.error, lineWidth: 1.5)
                )
            }
        }
    }

    // MARK: - Premium Offer Section
    private var premiumOfferSection: some View {
        VStack(spacing: 20) {
            // Hero Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.premiumGradientStart.opacity(0.2), AppTheme.Colors.premiumGradientEnd.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 20)

            Text("Premium")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
                .multilineTextAlignment(.center)

            // Price Card
            VStack(spacing: 16) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("9.99")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("₼")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        Text("/\(loc.localized("premium_month"))")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                }

                Text(loc.localized("premium_trial_info"))
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.tertiaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(20)

            // Activate Button (Development Only)
            #if DEBUG
            Button {
                activatePremium()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                    Text(loc.localized("premium_activate"))
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: AppTheme.Colors.premiumGradientStart.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            #endif

            Text(loc.localized("premium_coming_soon"))
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(loc.localized("premium_features_title"))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
                .padding(.horizontal, 4)

            VStack(spacing: 14) {
                FeatureRow(
                    icon: "figure.run",
                    title: loc.localized("premium_feature_activities"),
                    description: loc.localized("premium_feature_activities_desc")
                )

                FeatureRow(
                    icon: "message.fill",
                    title: loc.localized("premium_feature_chat"),
                    description: loc.localized("premium_feature_chat_desc")
                )

                FeatureRow(
                    icon: "camera.fill",
                    title: loc.localized("premium_feature_food"),
                    description: loc.localized("premium_feature_food_desc")
                )

                FeatureRow(
                    icon: "person.fill",
                    title: loc.localized("premium_feature_trainer"),
                    description: loc.localized("premium_feature_trainer_desc")
                )

                FeatureRow(
                    icon: "chart.bar.fill",
                    title: loc.localized("premium_feature_stats"),
                    description: loc.localized("premium_feature_stats_desc")
                )

                FeatureRow(
                    icon: "sparkles",
                    title: loc.localized("premium_feature_ai"),
                    description: loc.localized("premium_feature_ai_desc")
                )
            }
        }
    }

    // MARK: - Actions
    private func activatePremium() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                struct ActivateResponse: Codable {
                    let message: String
                    let isPremium: Bool

                    enum CodingKeys: String, CodingKey {
                        case message
                        case isPremium = "is_premium"
                    }
                }

                let response: ActivateResponse = try await APIService.shared.request(
                    endpoint: "/api/v1/premium/activate",
                    method: "POST"
                )

                // Refresh user data to get updated premium status
                await authManager.fetchCurrentUser()

                await MainActor.run {
                    isLoading = false
                    settingsManager.isPremium = response.isPremium
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func cancelPremium() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await APIService.shared.requestVoid(
                    endpoint: "/api/v1/premium/cancel",
                    method: "POST"
                )

                // Refresh user data
                await authManager.fetchCurrentUser()

                await MainActor.run {
                    isLoading = false
                    settingsManager.isPremium = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(20)
    }
}

// MARK: - Loading Overlay
private struct PremiumLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ProgressView()
                .tint(.white)
                .controlSize(.large)
                .padding(20)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
        }
    }
}

// #Preview { // iOS 17+ only
//     PremiumView()
// }
