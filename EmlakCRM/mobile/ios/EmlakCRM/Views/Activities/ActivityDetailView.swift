import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity
    @Environment(\.dismiss) var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var isDeleting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero Header with gradient
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [colorForType(activity.activityType), colorForType(activity.activityType).opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 220)

                    VStack(spacing: 16) {
                        Image(systemName: activity.activityType.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.9))

                        Text(activity.activityType.displayName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                        if activity.completedAt != nil {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Tamamlandı")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.25))
                            .cornerRadius(12)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                Text("Gözləyir")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.25))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 24)
                }

                // Title
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(AppTheme.primaryColor)
                        Text("Başlıq")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Text(activity.title)
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)

                // Description
                if let description = activity.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(AppTheme.primaryColor)
                            Text("Təsvir")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Text(description)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
                }

                // Schedule Info
                if let scheduledAt = activity.scheduledAt {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar.circle.fill")
                                .foregroundColor(AppTheme.primaryColor)
                            Text("Planlaşdırılmış Tarix")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(AppTheme.secondaryColor)
                                .frame(width: 32, height: 32)
                                .background(AppTheme.secondaryColor.opacity(0.15))
                                .cornerRadius(8)

                            Text(formatFullDate(scheduledAt))
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
                }

                // Completion Info
                if let completedAt = activity.completedAt {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.successColor)
                            Text("Tamamlanma Tarixi")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppTheme.successColor)
                                .frame(width: 32, height: 32)
                                .background(AppTheme.successColor.opacity(0.15))
                                .cornerRadius(8)

                            Text(formatFullDate(completedAt))
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
                }

                // Dates
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .foregroundColor(AppTheme.primaryColor)
                        Text("Tarixlər")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(spacing: 10) {
                        HStack {
                            Text("Yaradılma:")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(activity.createdAt))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Divider()

                        HStack {
                            Text("Yenilənmə:")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(activity.updatedAt))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
            }
            .padding()
        }
        .background(AppTheme.backgroundGradient)
        .navigationTitle("Fəaliyyət Detalları")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Redaktə et", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundColor(colorForType(activity.activityType))
                }
            }
        }
        .alert("Fəaliyyəti silmək istədiyinizdən əminsiniz?", isPresented: $showDeleteAlert) {
            Button("Ləğv et", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task {
                    await deleteActivity()
                }
            }
        } message: {
            Text("Bu əməliyyat geri qaytarıla bilməz.")
        }
    }

    private func deleteActivity() async {
        isDeleting = true
        do {
            try await APIService.shared.deleteActivity(id: activity.id)
            dismiss()
        } catch {
            print("Error deleting activity: \(error)")
        }
        isDeleting = false
    }

    private func colorForType(_ type: ActivityType) -> Color {
        switch type {
        case .call: return AppTheme.primaryColor
        case .meeting: return AppTheme.secondaryColor
        case .email: return AppTheme.infoColor
        case .viewing: return AppTheme.accentColor
        case .message: return AppTheme.successColor
        case .note: return AppTheme.textSecondary
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ActivityDetailView(activity: Activity(
            id: "1",
            activityType: .meeting,
            title: "Müştəri ilə görüş",
            description: "Yeni mənzil haqqında danışıq",
            propertyId: nil,
            clientId: nil,
            scheduledAt: Date(),
            completedAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
