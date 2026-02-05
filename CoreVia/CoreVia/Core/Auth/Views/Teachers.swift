//
//  Teachers.swift
//  CoreVia
//

import SwiftUI

struct TeachersView: View {

    @ObservedObject private var trainerManager = TrainerManager.shared
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var searchText: String = ""
    @State private var selectedCategory: TrainerCategory? = nil
    @State private var selectedTrainer: TrainerResponse? = nil

    var filteredTrainers: [TrainerResponse] {
        var result = trainerManager.trainers

        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.specialization ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var avgRating: String {
        let ratings = trainerManager.trainers.compactMap { $0.rating }
        guard !ratings.isEmpty else { return "--" }
        return String(format: "%.1f", ratings.reduce(0, +) / Double(ratings.count))
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                searchBar
                categoryFilter

                ScrollView(showsIndicators: false) {
                    if trainerManager.isLoading {
                        ProgressView()
                            .padding(.vertical, 60)
                    } else if filteredTrainers.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredTrainers) { trainer in
                                TrainerCard(trainer: trainer) {
                                    selectedTrainer = trainer
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            Task { await trainerManager.fetchTrainers() }
        }
        .sheet(item: $selectedTrainer) { trainer in
            TrainerDetailView(trainer: trainer)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.localized("teacher_title"))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 16) {
                StatBadge(icon: "person.2.fill", value: "\(trainerManager.trainers.count)", label: loc.localized("login_teacher"))
                StatBadge(icon: "star.fill", value: avgRating, label: loc.localized("teacher_avg_rating"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondaryText)

            TextField(loc.localized("teacher_search"), text: $searchText)
                .foregroundColor(AppTheme.Colors.primaryText)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: loc.localized("common_all"),
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil,
                    color: .gray
                ) {
                    withAnimation { selectedCategory = nil }
                }

                ForEach(TrainerCategory.allCases, id: \.self) { cat in
                    CategoryChip(
                        title: cat.localizedName,
                        icon: cat.icon,
                        isSelected: selectedCategory == cat,
                        color: cat.color
                    ) {
                        withAnimation { selectedCategory = cat }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(loc.localized("teacher_not_found"))
                .font(.headline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(loc.localized("teacher_change_criteria"))
                .font(.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Trainer Card
struct TrainerCard: View {
    let trainer: TrainerResponse
    let action: () -> Void
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                TrainerAvatarView(
                    profileImageUrl: trainer.profileImageUrl,
                    category: trainer.category,
                    size: 64
                )
                .shadow(color: trainer.category.color.opacity(0.3), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(trainer.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        if trainer.verificationStatus == "verified" {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                    }

                    Text(trainer.specialization ?? trainer.category.localizedName)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    HStack(spacing: 12) {
                        if let rating = trainer.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.starFilled)
                                Text(String(format: "%.1f", rating))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                            }
                        }

                        if let exp = trainer.experience {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Text("\(exp) \(loc.localized("trainer_years_short"))")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                        }

                        if let price = trainer.pricePerSession {
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Text(String(format: "%.0f ₼", price))
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(trainer.category.color)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(trainer.category.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Trainer Avatar View
struct TrainerAvatarView: View {
    let profileImageUrl: String?
    let category: TrainerCategory
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [category.color.opacity(0.3), category.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            if let imageUrl = profileImageUrl, !imageUrl.isEmpty {
                let fullURL = imageUrl.hasPrefix("http") ? imageUrl : APIService.shared.baseURL + imageUrl
                AsyncImage(url: URL(string: fullURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: category.icon)
                            .font(.system(size: size * 0.4))
                            .foregroundColor(.white)
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                    @unknown default:
                        Image(systemName: category.icon)
                            .font(.system(size: size * 0.4))
                            .foregroundColor(.white)
                    }
                }
            } else {
                Image(systemName: category.icon)
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? color : AppTheme.Colors.secondaryBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : AppTheme.Colors.separator, lineWidth: 1)
            )
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(10)
    }
}

// MARK: - Trainer Detail View
struct TrainerDetailView: View {
    let trainer: TrainerResponse
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var trainerManager = TrainerManager.shared

    @State private var showPremium = false
    @State private var isAssigning = false
    @State private var showAssignSuccess = false
    @State private var showError = false

    var isAlreadyAssigned: Bool {
        AuthManager.shared.currentUser?.trainerId == trainer.id
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        profilePhotoSection
                        nameAndSpecSection
                        specialtyTagsSection
                        statsCardsSection

                        if let bio = trainer.bio, !bio.isEmpty {
                            bioSection(bio: bio)
                        }

                        if let instagram = trainer.instagramHandle, !instagram.isEmpty {
                            instagramSection(handle: instagram)
                        }

                        // Reviews Section
                        ReviewsSection(trainerId: trainer.id)

                        // Trainer Content Section
                        StudentContentView(trainerId: trainer.id)

                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("teacher_profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
            .alert(loc.localized("teacher_assign_success_title"), isPresented: $showAssignSuccess) {
                Button(loc.localized("teacher_ok")) { dismiss() }
            } message: {
                Text("\(trainer.name) \(loc.localized("teacher_assign_success_msg"))")
            }
            .alert(loc.localized("teacher_error"), isPresented: $showError) {
                Button(loc.localized("teacher_ok"), role: .cancel) {}
            } message: {
                Text(trainerManager.errorMessage ?? loc.localized("teacher_unknown_error"))
            }
        }
    }

    // MARK: - Profile Photo
    private var profilePhotoSection: some View {
        TrainerAvatarView(
            profileImageUrl: trainer.profileImageUrl,
            category: trainer.category,
            size: 120
        )
        .shadow(color: trainer.category.color.opacity(0.4), radius: 20, x: 0, y: 10)
    }

    // MARK: - Name & Specialization
    private var nameAndSpecSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Text(trainer.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                if trainer.verificationStatus == "verified" {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
            }

            if let spec = trainer.specialization, !spec.isEmpty {
                Text(spec)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            if let rating = trainer.rating {
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: starIcon(for: index, rating: rating))
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.starFilled)
                    }
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .padding(.leading, 4)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 12))
                Text(loc.localized("teacher_verified"))
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(AppTheme.Colors.badgeVerified)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(AppTheme.Colors.badgeVerified.opacity(0.12))
            .cornerRadius(10)
        }
    }

    // MARK: - Specialty Tags
    private var specialtyTagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.localized("trainer_specialties"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.secondaryText)

            WrappingHStack(spacing: 8) {
                ForEach(trainer.specialtyTags, id: \.self) { tag in
                    HStack(spacing: 6) {
                        Image(systemName: tag.icon)
                            .font(.system(size: 12))
                        Text(tag.localizedName)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(tag.color)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(tag.color.opacity(0.12))
                    .cornerRadius(20)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }

    // MARK: - Stats Cards
    private var statsCardsSection: some View {
        HStack(spacing: 12) {
            DetailStatCard(
                icon: "graduationcap.fill",
                value: trainer.displayExperience,
                label: loc.localized("teacher_experience"),
                accentColor: AppTheme.Colors.accent
            )
            DetailStatCard(
                icon: "manatsign",
                value: trainer.displayPrice,
                label: loc.localized("trainer_price_per_session"),
                accentColor: AppTheme.Colors.accent
            )
            DetailStatCard(
                icon: "star.fill",
                value: trainer.displayRating,
                label: loc.localized("teacher_rating"),
                accentColor: AppTheme.Colors.starFilled
            )
        }
    }

    // MARK: - Bio
    private func bioSection(bio: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("teacher_about"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(bio)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }

    // MARK: - Instagram
    private func instagramSection(handle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "camera.fill")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(loc.localized("trainer_instagram"))
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                Text("@\(handle)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if isAlreadyAssigned {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.success)
                    Text(loc.localized("teacher_already_joined"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.success)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.Colors.success.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.success.opacity(0.3), lineWidth: 1)
                )
            } else if settingsManager.isPremium {
                Button {
                    isAssigning = true
                    Task {
                        let success = await trainerManager.assignTrainer(trainerId: trainer.id)
                        isAssigning = false
                        if success {
                            showAssignSuccess = true
                        } else {
                            showError = true
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isAssigning {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "person.badge.plus")
                        }
                        Text(loc.localized("trainer_subscribe"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [trainer.category.color, trainer.category.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: trainer.category.color.opacity(0.4), radius: 8)
                }
                .disabled(isAssigning)
            } else {
                Button {
                    showPremium = true
                } label: {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                            Text(loc.localized("trainer_subscribe"))
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)

                        Text(loc.localized("teacher_premium_required"))
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: AppTheme.Colors.premiumGradientStart.opacity(0.4), radius: 8)
                }

                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppTheme.Colors.premiumGradientStart)
                    Text(loc.localized("teacher_premium_feature"))
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Star Helper
    private func starIcon(for index: Int, rating: Double) -> String {
        let threshold = Double(index) + 1.0
        if rating >= threshold {
            return "star.fill"
        } else if rating >= threshold - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Wrapping HStack (horizontal scrollable tags)
struct WrappingHStack<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content

    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                content()
            }
        }
    }
}

// MARK: - Detail Stat Card
struct DetailStatCard: View {
    let icon: String
    let value: String
    let label: String
    var accentColor: Color = AppTheme.Colors.accent

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        TeachersView()
    }
}
