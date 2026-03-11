//
//  ExerciseLibraryView.swift
//  CoreVia
//
//  Məşq kitabxanası — əzələ qrupuna görə filter + şəkil siyahısı
//

import SwiftUI

struct ExerciseLibraryView: View {
    @StateObject private var viewModel = ExerciseLibraryViewModel()
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Muscle Group Filter
                muscleGroupFilter

                // MARK: - Search Bar
                searchBar

                // MARK: - Exercise List
                exerciseList
            }
        }
        .navigationTitle(loc.localized("exercise_library_title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Muscle Group Filter Chips
    private var muscleGroupFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                    Button {
                        viewModel.selectedMuscle = muscle
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: muscle.icon)
                                .font(.system(size: 12))
                            Text(muscle.displayName)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(viewModel.selectedMuscle == muscle ? .white : AppTheme.Colors.primaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedMuscle == muscle
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.secondaryBackground
                        )
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .font(.system(size: 14))

            TextField(loc.localized("exercise_search"), text: $viewModel.searchText)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.primaryText)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Exercise List
    private var exerciseList: some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: 14) {
                    Spacer()
                    ProgressView()
                        .controlSize(.large)
                    Text(loc.localized("exercise_loading"))
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Spacer()
                }
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundColor(AppTheme.Colors.tertiaryText)

                    Text(loc.localized("exercise_loading_error"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button {
                        Task { await viewModel.loadExercises() }
                    } label: {
                        Text(loc.localized("exercise_retry"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(AppTheme.Colors.accent)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
            } else if viewModel.filteredExercises.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text(loc.localized("exercise_no_results"))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    // Nəticə sayı
                    HStack {
                        Text("\(viewModel.filteredExercises.count) \(loc.localized("exercise_found_count"))")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.filteredExercises) { exercise in
                            NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                ExerciseRowView(exercise: exercise)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Exercise Row
struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 12) {
            // Şəkil
            ExerciseImageView(
                url: URL(string: exercise.imageUrl ?? ""),
                cornerRadius: 10
            )
            .frame(width: 72, height: 72)
            .clipped()

            // Məlumat
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name.capitalized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Image(systemName: "target")
                            .font(.system(size: 9))
                        Text(exercise.primaryMusclesText)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }

                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 9))
                        Text(exercise.equipmentText)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                    if let level = exercise.level {
                        Text(exercise.levelText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(levelColor(level))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(levelColor(level).opacity(0.12))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.Colors.tertiaryText)
        }
        .padding(12)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
    }

    private func levelColor(_ level: String) -> Color {
        switch level.lowercased() {
        case "beginner":     return .green
        case "intermediate": return .orange
        case "expert":       return .red
        default:             return .gray
        }
    }
}
