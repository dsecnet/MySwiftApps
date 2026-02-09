import SwiftUI

struct DealDetailView: View {
    let deal: Deal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Amount Card
                VStack(spacing: 16) {
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppTheme.primaryGradient)

                    Text(formatPrice(deal.agreedPrice))
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(AppTheme.successGradient)

                    DealStatusBadge(status: deal.status)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .cardStyle()

                // Notes
                if let notes = deal.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Qeydlər")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)

                        Text(notes)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .cardStyle()
                }

                // Status Timeline
                VStack(alignment: .leading, spacing: 16) {
                    Text("Status")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    VStack(alignment: .leading, spacing: 12) {
                        StatusTimelineItem(
                            title: "Gözləyir",
                            isActive: deal.status == .pending,
                            isPassed: deal.status != .pending
                        )

                        StatusTimelineItem(
                            title: "Davam edir",
                            isActive: deal.status == .inProgress,
                            isPassed: deal.status == .completed || deal.status == .cancelled
                        )

                        if deal.status == .completed {
                            StatusTimelineItem(
                                title: "Tamamlandı",
                                isActive: true,
                                isPassed: false,
                                color: AppTheme.successColor
                            )
                        } else if deal.status == .cancelled {
                            StatusTimelineItem(
                                title: "Ləğv edildi",
                                isActive: true,
                                isPassed: false,
                                color: AppTheme.errorColor
                            )
                        }
                    }
                }
                .padding()
                .cardStyle()


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
                            Text(formatDate(deal.createdAt))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Divider()

                        HStack {
                            Text("Yenilənmə:")
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(deal.updatedAt))
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
        .navigationTitle("Sövdələşmə Detalları")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price)) ₼"
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

struct StatusTimelineItem: View {
    let title: String
    let isActive: Bool
    let isPassed: Bool
    var color: Color = AppTheme.primaryColor

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isActive ? color : (isPassed ? AppTheme.successColor.opacity(0.3) : AppTheme.textSecondary.opacity(0.2)))
                    .frame(width: 32, height: 32)

                if isActive {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else if isPassed {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(AppTheme.successColor)
                }
            }

            Text(title)
                .font(AppTheme.callout())
                .foregroundColor(isActive ? AppTheme.textPrimary : AppTheme.textSecondary)
                .fontWeight(isActive ? .semibold : .regular)
        }
    }
}

#Preview {
    NavigationStack {
        DealDetailView(deal: Deal(
            id: "1",
            propertyId: "prop1",
            clientId: "client1",
            status: .inProgress,
            agreedPrice: 150000,
            notes: "3 otaqlı mənzil satışı",
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
