import SwiftUI

// MARK: - Premium View
struct PremiumView: View {
    @StateObject private var viewModel = PremiumViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppTheme.Spacing.xxl) {
                    // MARK: - Diamond Icon with Glow
                    diamondHeader

                    // MARK: - Title
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("unlock_pro".localized)
                            .font(AppTheme.Fonts.heading1())
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("premium_subtitle".localized)
                            .font(AppTheme.Fonts.caption())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.xl)
                    }

                    // MARK: - Monthly Plan Card
                    monthlyPlanCard

                    // MARK: - Yearly Plan Card
                    yearlyPlanCard

                    // MARK: - One-Time Boosts Section
                    boostSection

                    // MARK: - Subscription Disclaimer
                    disclaimerText

                    Spacer()
                        .frame(height: AppTheme.Spacing.xxxl)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("upgrade_premium".localized)
                        .font(AppTheme.Fonts.title())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.restorePurchases()
                    } label: {
                        Text("restore_purchases".localized)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
            .alert("success".localized, isPresented: $viewModel.showPurchaseSuccess) {
                Button("ok".localized) { }
            } message: {
                Text("Premium abunəliyiniz aktivləşdirildi!")
            }
        }
    }

    // MARK: - Diamond Header with Glow
    private var diamondHeader: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            AppTheme.Colors.accent.opacity(0.3),
                            AppTheme.Colors.accent.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)

            // Diamond icon
            Image(systemName: "diamond.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.Colors.accent, Color(hex: "0099CC")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppTheme.Colors.accent.opacity(0.5), radius: 20, x: 0, y: 4)
        }
        .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: - Monthly Plan Card
    private var monthlyPlanCard: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("monthly".localized)
                        .font(AppTheme.Fonts.heading3())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text("$4.99/\("monthly".localized)")
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                Spacer()
                Text("$4.99")
                    .font(AppTheme.Fonts.price())
                    .foregroundColor(AppTheme.Colors.accent)
            }

            // Features list
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                ForEach(SubscriptionPlan.monthly.features, id: \.self) { feature in
                    featureRow(feature.localized)
                }
            }

            // CTA Button
            Button {
                viewModel.purchasePlan(.monthly)
            } label: {
                HStack {
                    if viewModel.isPurchasing && viewModel.selectedPlan == .monthly {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text("start_monthly".localized)
                        .font(AppTheme.Fonts.bodyBold())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.Colors.accent)
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
            .disabled(viewModel.isPurchasing)
        }
        .padding(AppTheme.Spacing.xl)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
        )
    }

    // MARK: - Yearly Plan Card
    private var yearlyPlanCard: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Header with BEST VALUE badge
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("yearly".localized)
                            .font(AppTheme.Fonts.heading3())
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        // BEST VALUE badge
                        Text("best_value".localized)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(AppTheme.Colors.success)
                            .cornerRadius(AppTheme.CornerRadius.small)
                    }

                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("$39.99/\("yearly".localized)")
                            .font(AppTheme.Fonts.caption())
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        Text("save_percent".localized)
                            .font(AppTheme.Fonts.smallBold())
                            .foregroundColor(AppTheme.Colors.success)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("$39.99")
                        .font(AppTheme.Fonts.price())
                        .foregroundColor(AppTheme.Colors.accent)
                    Text("$3.33/ay")
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }

            // Features list
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                ForEach(SubscriptionPlan.yearly.features, id: \.self) { feature in
                    featureRow(feature.localized)
                }
            }

            // CTA Button
            Button {
                viewModel.purchasePlan(.yearly)
            } label: {
                HStack {
                    if viewModel.isPurchasing && viewModel.selectedPlan == .yearly {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text("start_yearly".localized)
                        .font(AppTheme.Fonts.bodyBold())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.accent, Color(hex: "0099CC")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
            .disabled(viewModel.isPurchasing)
        }
        .padding(AppTheme.Spacing.xl)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(AppTheme.Colors.accent.opacity(0.3), lineWidth: 1.5)
        )
    }

    // MARK: - Feature Row
    private func featureRow(_ text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.success)

            Text(text)
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }

    // MARK: - Boost Section
    private var boostSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            // Section Title
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.gold)
                Text("ONE-TIME BOOSTS")
                    .font(AppTheme.Fonts.smallBold())
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }

            // Boost Cards
            ForEach(viewModel.boostProducts) { product in
                boostCard(product)
            }
        }
    }

    // MARK: - Boost Card
    private func boostCard(_ product: BoostProduct) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                // Boost icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .fill(AppTheme.Colors.gold.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.gold)
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(product.name)
                        .font(AppTheme.Fonts.bodyBold())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(product.description)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Spacer()

                Text(product.price)
                    .font(AppTheme.Fonts.title())
                    .foregroundColor(AppTheme.Colors.gold)
            }

            // Listing Preview (if available)
            if let listing = product.listingPreview {
                HStack(spacing: AppTheme.Spacing.md) {
                    AsyncImage(url: URL(string: listing.mainImage)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Rectangle()
                                .fill(AppTheme.Colors.surfaceBackground)
                        }
                    }
                    .frame(width: 64, height: 64)
                    .cornerRadius(AppTheme.CornerRadius.small)
                    .clipped()

                    VStack(alignment: .leading, spacing: 2) {
                        Text(listing.title)
                            .font(AppTheme.Fonts.captionBold())
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .lineLimit(1)
                        Text(listing.formattedPrice)
                            .font(AppTheme.Fonts.captionBold())
                            .foregroundColor(AppTheme.Colors.accent)
                        Text("\(listing.district), \(listing.city)")
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    Spacer()
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.surfaceBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
            }

            // Boost Button
            Button {
                viewModel.purchaseBoost(product)
            } label: {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                    Text("boost_now".localized)
                        .font(AppTheme.Fonts.bodyBold())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.gold, Color(hex: "D97706")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
        }
        .padding(AppTheme.Spacing.xl)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(AppTheme.Colors.gold.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Disclaimer Text
    private var disclaimerText: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("Abunəlik avtomatik olaraq yenilənir. İstənilən vaxt App Store tənzimləmələrindən ləğv edə bilərsiniz. Pulsuz sınaq müddəti bitdikdən sonra ödəniş alınacaq.")
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            HStack(spacing: AppTheme.Spacing.lg) {
                Button {
                    // Terms
                } label: {
                    Text("Qaydalar")
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.accent)
                        .underline()
                }

                Button {
                    // Privacy
                } label: {
                    Text("Gizlilik Siyasəti")
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.accent)
                        .underline()
                }
            }
        }
        .padding(.top, AppTheme.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    PremiumView()
}
