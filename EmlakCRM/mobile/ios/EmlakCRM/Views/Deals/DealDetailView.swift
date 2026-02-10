import SwiftUI

struct DealDetailView: View {
    let deal: Deal
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
                                colors: [colorForStatus(deal.status), colorForStatus(deal.status).opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 220)

                    VStack(spacing: 16) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.9))

                        Text(formatPrice(deal.agreedPrice))
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                        Text(deal.status.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.25))
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 24)
                }

                // Notes
                if let notes = deal.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(AppTheme.primaryColor)
                            Text("Qeydlər")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Text(notes)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
                }

                // Status Timeline
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "arrow.triangle.capsulepath")
                            .foregroundColor(AppTheme.primaryColor)
                        Text("Status")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

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
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)


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
                            Text(formatDate(deal.createdAt))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Divider()

                        HStack {
                            Text("Yenilənmə:")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(deal.updatedAt))
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
        .navigationTitle("Sövdələşmə Detalları")
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
                        .foregroundColor(colorForStatus(deal.status))
                }
            }
        }
        .alert("Sövdələşməni silmək istədiyinizdən əminsiniz?", isPresented: $showDeleteAlert) {
            Button("Ləğv et", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task {
                    await deleteDeal()
                }
            }
        } message: {
            Text("Bu əməliyyat geri qaytarıla bilməz.")
        }
    }

    private func deleteDeal() async {
        isDeleting = true
        do {
            try await APIService.shared.deleteDeal(id: deal.id)
            dismiss()
        } catch {
            print("Error deleting deal: \(error)")
        }
        isDeleting = false
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

    private func colorForStatus(_ status: DealStatus) -> Color {
        switch status {
        case .pending: return AppTheme.warningColor
        case .inProgress: return AppTheme.primaryColor
        case .completed: return AppTheme.successColor
        case .cancelled: return AppTheme.errorColor
        }
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
