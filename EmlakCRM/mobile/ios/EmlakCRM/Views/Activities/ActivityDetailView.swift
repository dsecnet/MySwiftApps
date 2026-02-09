import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(colorForType(activity.activityType).opacity(0.15))
                            .frame(width: 100, height: 100)

                        Image(systemName: activity.activityType.icon)
                            .font(.system(size: 44))
                            .foregroundColor(colorForType(activity.activityType))
                    }

                    Text(activity.activityType.displayName)
                        .font(AppTheme.title2())
                        .foregroundColor(AppTheme.textPrimary)

                    if activity.completedAt != nil {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Tamamlandı")
                        }
                        .font(AppTheme.headline())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppTheme.successGradient)
                        .cornerRadius(20)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                            Text("Gözləyir")
                        }
                        .font(AppTheme.headline())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.accentColor, AppTheme.warningColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardStyle()

                // Title
                VStack(alignment: .leading, spacing: 12) {
                    Text("Başlıq")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    Text(activity.title)
                        .font(AppTheme.body())
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .cardStyle()

                // Description
                if let description = activity.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Təsvir")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)

                        Text(description)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .cardStyle()
                }

                // Schedule Info
                if let scheduledAt = activity.scheduledAt {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Planlaşdırılmış Tarix")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)

                        HStack {
                            Image(systemName: "calendar.circle.fill")
                                .foregroundColor(AppTheme.primaryColor)
                                .font(.title3)

                            Text(formatFullDate(scheduledAt))
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .cardStyle()
                }

                // Completion Info
                if let completedAt = activity.completedAt {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tamamlanma Tarixi")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)

                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.successColor)
                                .font(.title3)

                            Text(formatFullDate(completedAt))
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .cardStyle()
                }

                // Dates
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tarixlər")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Yaradılma:")
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(activity.createdAt))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Divider()

                        HStack {
                            Text("Yenilənmə:")
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(activity.updatedAt))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .font(AppTheme.callout())
                }
                .padding()
                .cardStyle()
            }
            .padding()
        }
        .background(AppTheme.backgroundGradient)
        .navigationTitle("Fəaliyyət Detalları")
        .navigationBarTitleDisplayMode(.inline)
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
