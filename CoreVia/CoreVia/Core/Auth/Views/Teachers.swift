//
//  Teachers.swift
//  CoreVia
//
//  Muellimler siyahisi — Backend API inteqrasiyasi + Premium gate
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
                        title: cat.rawValue,
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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [trainer.category.color.opacity(0.3), trainer.category.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Image(systemName: trainer.category.icon)
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
                .shadow(color: trainer.category.color.opacity(0.3), radius: 8, x: 0, y: 4)

                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(trainer.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(trainer.specialization ?? trainer.category.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    HStack(spacing: 12) {
                        if let rating = trainer.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
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
                                Text("\(exp) il")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                        }

                        if let price = trainer.pricePerSession {
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Text(String(format: "%.0f", price))
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
                .foregroundColor(.red)

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
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [trainer.category.color.opacity(0.3), trainer.category.color],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 110, height: 110)

                            Image(systemName: trainer.category.icon)
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        }
                        .shadow(color: trainer.category.color.opacity(0.4), radius: 20, x: 0, y: 10)

                        // Name & Specialty
                        VStack(spacing: 8) {
                            Text(trainer.name)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            Text(trainer.specialization ?? trainer.category.rawValue)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            if let rating = trainer.rating {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", rating))
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                }
                            }
                        }

                        // Stats
                        HStack(spacing: 12) {
                            DetailStatCard(
                                icon: "graduationcap.fill",
                                value: trainer.displayExperience,
                                label: loc.localized("teacher_experience")
                            )
                            DetailStatCard(
                                icon: "manatsign",
                                value: trainer.displayPrice,
                                label: "Qiymet/seans"
                            )
                            DetailStatCard(
                                icon: "star.fill",
                                value: trainer.displayRating,
                                label: loc.localized("teacher_rating")
                            )
                        }

                        // Bio
                        if let bio = trainer.bio, !bio.isEmpty {
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

                        // Action Buttons
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
            .alert("Ugurlu!", isPresented: $showAssignSuccess) {
                Button("Tamam") { dismiss() }
            } message: {
                Text("\(trainer.name) muellim olaraq teyin olundu!")
            }
            .alert("Xeta", isPresented: $showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(trainerManager.errorMessage ?? "Bilinmeyen xeta")
            }
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if isAlreadyAssigned {
                // Artiq qosulub
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Bu muellime qosulmusunuz")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
            } else if settingsManager.isPremium {
                // Premium — qosul duymesi
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
                        Text("Muellimle Qosul")
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
                // Premium deyil — kilidli
                Button {
                    showPremium = true
                } label: {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                            Text("Muellimle Qosul")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)

                        Text("Premium abuneliq lazimdir")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .indigo.opacity(0.4), radius: 8)
                }

                // Premium info
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.indigo)
                    Text("Muellim secimi Premium funksiyasidir")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Detail Stat Card
struct DetailStatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.red)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
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
