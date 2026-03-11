//
//  PremiumView.swift
//  CoreVia
//
//  iOS-02 fix: StoreKit 2 tam inteqrasiya edildi - receipt backend-e gonderilir
//  iOS-05 fix: Debug premium bypass butonu silinib, StoreKit flow ile evez edildi

import SwiftUI
import StoreKit
import SafariServices
import os.log

struct PremiumView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var storeKit = StoreKitManager.shared
    @ObservedObject private var kapitalPayment = KapitalPaymentManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var isLoading = false
    @State private var showCancelAlert = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var selectedProduct: Product?
    @State private var showPaymentWeb = false
    @State private var paymentURL: URL?
    @State private var selectedPlanId: String = "com.corevia.monthly"

    // isPremium: hemise backend-den gelen currentUser.isPremium istifade olunur (iOS-04 fix)
    private var isPremium: Bool {
        authManager.isPremium
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if isPremium {
                            activePremiumSection
                        } else {
                            premiumOfferSection
                        }
                        featuresSection
                    }
                    .padding()
                }

                if isLoading || storeKit.isLoading {
                    PremiumLoadingOverlay()
                }
            }
            .navigationTitle(loc.localized("premium_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_close")) { dismiss() }
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .alert(loc.localized("common_error"), isPresented: $showError) {
                Button(loc.localized("common_ok"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? storeKit.errorMessage ?? loc.localized("common_unknown_error"))
            }
            .onAppear {
                if storeKit.products.isEmpty {
                    Task { await storeKit.loadProducts() }
                }
            }
            .alert(loc.localized("premium_cancel_title"), isPresented: $showCancelAlert) {
                Button(loc.localized("common_cancel"), role: .cancel) {}
                Button(loc.localized("premium_cancel_yes"), role: .destructive) { cancelPremium() }
            } message: {
                Text(loc.localized("premium_cancel_message"))
            }
        }
    }

    // MARK: - Active Premium Section
    private var activePremiumSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
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

            VStack(spacing: 16) {
                InfoRow(icon: "calendar",
                        title: loc.localized("premium_plan"),
                        value: loc.localized("premium_monthly"))
                Divider().background(AppTheme.Colors.tertiaryText.opacity(0.3))
                InfoRow(icon: "creditcard",
                        title: loc.localized("premium_price"),
                        value: "\(storeKit.products.first?.displayPrice ?? "---")/\(loc.localized("premium_month"))")
            }
            .padding(20)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(20)

            Button { showCancelAlert = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle").font(.system(size: 18))
                    Text(loc.localized("premium_cancel_button")).font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(AppTheme.Colors.error)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.error.opacity(0.1))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.Colors.error, lineWidth: 1.5))
            }
        }
    }

    // MARK: - Premium Offer Section
    private var premiumOfferSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [AppTheme.Colors.premiumGradientStart.opacity(0.2),
                                 AppTheme.Colors.premiumGradientEnd.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient(
                        colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .padding(.top, 20)

            Text(loc.localized("premium_title"))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            // Plan seçimi
            VStack(spacing: 12) {
                planSelectionCard(
                    planId: "com.corevia.monthly",
                    title: loc.localized("premium_monthly"),
                    price: "9.99 ₼",
                    period: loc.localized("premium_month")
                )
                planSelectionCard(
                    planId: "com.corevia.yearly",
                    title: loc.localized("premium_yearly"),
                    price: "79.99 ₼",
                    period: loc.localized("premium_year"),
                    badge: "20% endirim"
                )
            }

            // Kapital Bank ile odenis
            Button {
                startKapitalPayment()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "crown.fill").font(.system(size: 18))
                    Text(loc.localized("premium_activate")).font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(LinearGradient(
                    colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                    startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
                .shadow(color: AppTheme.Colors.premiumGradientStart.opacity(0.4), radius: 12, x: 0, y: 6)
            }

            // Kapital Bank payment success
            if kapitalPayment.paymentSuccess {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Ödəniş uğurla tamamlandı!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
            }
        }
        .sheet(isPresented: $showPaymentWeb) {
            if let url = paymentURL {
                PaymentWebView(url: url) {
                    showPaymentWeb = false
                    // Safari bağlandıqda status yoxla
                    checkPaymentAfterReturn()
                }
            }
        }
    }

    private func planSelectionCard(planId: String, title: String, price: String, period: String, badge: String? = nil) -> some View {
        let isSelected = selectedPlanId == planId

        return Button {
            selectedPlanId = planId
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.Colors.premiumGradientStart)
                                .cornerRadius(6)
                        }
                    }
                    Text("1 \(period)")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                Spacer()
                Text(price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? AppTheme.Colors.premiumGradientStart : AppTheme.Colors.primaryText)
            }
            .padding(16)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? AppTheme.Colors.premiumGradientStart : AppTheme.Colors.separator,
                        lineWidth: isSelected ? 2 : 1))
        }
    }

    private func productCard(_ product: Product) -> some View {
        let isSelected = selectedProduct?.id == product.id || (selectedProduct == nil && storeKit.products.first?.id == product.id)

        return Button {
            selectedProduct = product
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text(product.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? AppTheme.Colors.premiumGradientStart : AppTheme.Colors.primaryText)
            }
            .padding(16)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? AppTheme.Colors.premiumGradientStart : AppTheme.Colors.separator,
                        lineWidth: isSelected ? 2 : 1))
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
                FeatureRow(icon: "figure.run",
                           title: loc.localized("premium_feature_activities"),
                           description: loc.localized("premium_feature_activities_desc"))
                FeatureRow(icon: "message.fill",
                           title: loc.localized("premium_feature_chat"),
                           description: loc.localized("premium_feature_chat_desc"))
                FeatureRow(icon: "camera.fill",
                           title: loc.localized("premium_feature_food"),
                           description: loc.localized("premium_feature_food_desc"))
                FeatureRow(icon: "person.fill",
                           title: loc.localized("premium_feature_trainer"),
                           description: loc.localized("premium_feature_trainer_desc"))
                FeatureRow(icon: "chart.bar.fill",
                           title: loc.localized("premium_feature_stats"),
                           description: loc.localized("premium_feature_stats_desc"))
                FeatureRow(icon: "sparkles",
                           title: loc.localized("premium_feature_ai"),
                           description: loc.localized("premium_feature_ai_desc"))
            }
        }
    }

    // MARK: - Kapital Bank Payment
    private func startKapitalPayment() {
        isLoading = true
        kapitalPayment.reset()

        Task {
            do {
                let response = try await kapitalPayment.createOrder(productId: selectedPlanId)

                await MainActor.run {
                    isLoading = false
                    if let url = URL(string: response.redirectUrl) {
                        paymentURL = url
                        showPaymentWeb = true
                    } else {
                        errorMessage = "Ödəniş linki yaradıla bilmədi"
                        showError = true
                    }
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

    private func checkPaymentAfterReturn() {
        guard let paymentId = kapitalPayment.currentPaymentId else { return }
        isLoading = true

        Task {
            let success = await kapitalPayment.waitForPaymentCompletion(paymentId: paymentId)

            await MainActor.run {
                isLoading = false
                if success {
                    // Premium aktivdir - user data yenilenib
                } else if let error = kapitalPayment.paymentError {
                    errorMessage = error
                    showError = true
                }
            }
        }
    }

    // MARK: - StoreKit Purchase (saxlanılıb - Apple IAP lazım olsa)
    private func purchaseProduct(_ product: Product) {
        isLoading = true
        Task {
            do {
                let transaction = try await storeKit.purchase(product)
                await MainActor.run {
                    isLoading = false
                    if transaction != nil {
                        Task { await authManager.fetchCurrentUser() }
                    }
                }
            } catch StoreError.backendVerificationFailed {
                await MainActor.run {
                    isLoading = false
                    errorMessage = loc.localized("premium_verification_failed")
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    if (error as? StoreKit.Product.PurchaseError) != nil { return }
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func cancelPremium() {
        isLoading = true
        Task {
            do {
                try await APIService.shared.requestVoid(endpoint: "/api/v1/premium/cancel", method: "POST")
                await authManager.fetchCurrentUser()
                await MainActor.run {
                    isLoading = false
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
            Image(systemName: icon).font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.accent).frame(width: 28)
            Text(title).font(.system(size: 15)).foregroundColor(AppTheme.Colors.secondaryText)
            Spacer()
            Text(value).font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.Colors.primaryText)
        }
        .padding(.horizontal, 4).padding(.vertical, 2)
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
                Circle().fill(AppTheme.Colors.accent.opacity(0.15)).frame(width: 48, height: 48)
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(AppTheme.Colors.accent)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.system(size: 16, weight: .semibold)).foregroundColor(AppTheme.Colors.primaryText)
                Text(description).font(.system(size: 14)).foregroundColor(AppTheme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(AppTheme.Colors.secondaryBackground).cornerRadius(20)
    }
}

// MARK: - Loading Overlay
private struct PremiumLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView().tint(.white).controlSize(.large)
                .padding(20).background(AppTheme.Colors.secondaryBackground).cornerRadius(12)
        }
    }
}
