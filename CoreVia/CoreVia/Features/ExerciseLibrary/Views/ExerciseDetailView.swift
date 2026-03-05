//
//  ExerciseDetailView.swift
//  CoreVia
//
//  Tək məşqin detallarını göstərir: şəkillər + təlimatlar
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var showSecondImage = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // MARK: - Şəkillər
                    imageSection

                    // MARK: - Detallar
                    detailsSection

                    // MARK: - Təlimatlar
                    if let instructions = exercise.instructions, !instructions.isEmpty {
                        instructionsSection(instructions)
                    }

                    // MARK: - İkinci əzələlər
                    if let muscles = exercise.secondaryMusclesTranslated, !muscles.isEmpty {
                        secondaryMusclesSection(muscles)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(exercise.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Şəkil Bölməsi
    private var imageSection: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                ExerciseImageView(
                    url: URL(string: showSecondImage ? (exercise.imageUrl2 ?? exercise.imageUrl ?? "") : (exercise.imageUrl ?? "")),
                    cornerRadius: 16
                )
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(16)

                // Səviyyə badge
                if let level = exercise.level {
                    Text(exercise.levelText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(levelColor(level).opacity(0.9))
                        .cornerRadius(8)
                        .padding(12)
                }
            }

            // Başlanğıc/Son toggle
            if exercise.imageUrl2 != nil {
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showSecondImage = false
                        }
                    } label: {
                        Text("Başlanğıc")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(!showSecondImage ? .white : AppTheme.Colors.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(!showSecondImage ? AppTheme.Colors.accent : AppTheme.Colors.secondaryBackground)
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showSecondImage = true
                        }
                    } label: {
                        Text("Son pozisiya")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(showSecondImage ? .white : AppTheme.Colors.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(showSecondImage ? AppTheme.Colors.accent : AppTheme.Colors.secondaryBackground)
                    }
                }
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.Colors.accent.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Detallar Bölməsi
    private var detailsSection: some View {
        VStack(spacing: 0) {
            detailRow(
                icon: "target",
                title: "Hədəf əzələ",
                value: exercise.primaryMusclesText,
                color: AppTheme.Colors.accent
            )

            Divider().padding(.horizontal, 16)

            detailRow(
                icon: "dumbbell.fill",
                title: "Avadanlıq",
                value: exercise.equipmentText,
                color: .orange
            )

            Divider().padding(.horizontal, 16)

            detailRow(
                icon: "flame.fill",
                title: "Kateqoriya",
                value: exercise.categoryText,
                color: .blue
            )

            if exercise.level != nil {
                Divider().padding(.horizontal, 16)

                detailRow(
                    icon: "chart.bar.fill",
                    title: "Səviyyə",
                    value: exercise.levelText,
                    color: levelColor(exercise.level ?? "")
                )
            }

            if let forceText = exercise.forceText {
                Divider().padding(.horizontal, 16)

                detailRow(
                    icon: "arrow.left.arrow.right",
                    title: "Hərəkət növü",
                    value: forceText,
                    color: .purple
                )
            }
        }
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }

    private func detailRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }

    // MARK: - Təlimatlar Bölməsi
    private func instructionsSection(_ instructions: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "list.number")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.accent)
                Text("Təlimatlar")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(AppTheme.Colors.accent)
                            .clipShape(Circle())

                        Text(instruction)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(2)
                    }
                }
            }
            .padding(14)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(14)
        }
    }

    // MARK: - İkinci Əzələlər Bölməsi
    private func secondaryMusclesSection(_ muscles: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "figure.flexibility")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.accent)
                Text("İkinci əzələlər")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(muscles, id: \.self) { muscle in
                        Text(muscle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.Colors.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(AppTheme.Colors.accent.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    // MARK: - Səviyyə Rəngi
    private func levelColor(_ level: String) -> Color {
        switch level.lowercased() {
        case "beginner":     return .green
        case "intermediate": return .orange
        case "expert":       return .red
        default:             return .gray
        }
    }
}
