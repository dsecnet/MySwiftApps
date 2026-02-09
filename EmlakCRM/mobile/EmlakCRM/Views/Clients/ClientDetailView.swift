//
//  ClientDetailView.swift
//  EmlakCRM
//
//  Client Detail Screen
//

import SwiftUI

struct ClientDetailView: View {
    let client: Client
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection

                // Contact Info
                contactSection

                // Details
                detailsSection

                // Notes
                if let notes = client.notes, !notes.isEmpty {
                    notesSection(notes: notes)
                }

                // Activity Timeline
                activityTimelineSection

                // Timestamps
                timestampsSection
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        // Edit client
                    } label: {
                        Label("Redaktə et", systemImage: "pencil")
                    }

                    Button {
                        // Add activity
                    } label: {
                        Label("Aktivlik əlavə et", systemImage: "calendar.badge.plus")
                    }

                    Divider()

                    Button(role: .destructive) {
                        // Delete client
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AppTheme.primaryColor)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [typeColor.opacity(0.6), typeColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(client.name.prefix(1).uppercased())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(spacing: 8) {
                Text(client.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 12) {
                    // Type Badge
                    HStack(spacing: 4) {
                        Image(systemName: typeIcon)
                        Text(typeText)
                    }
                    .font(AppTheme.caption())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(typeColor)
                    .cornerRadius(8)

                    // Status Badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                        Text(statusText)
                    }
                    .font(AppTheme.caption())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Əlaqə")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)

            // Phone
            if let phone = client.phone {
                HStack(spacing: 12) {
                    Circle()
                        .fill(AppTheme.successColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "phone.fill")
                                .foregroundColor(AppTheme.successColor)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Telefon")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)

                        Text(phone)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Spacer()

                    Link(destination: URL(string: "tel:\(phone)")!) {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.successColor)
                    }
                }
            }

            // Email
            if let email = client.email {
                HStack(spacing: 12) {
                    Circle()
                        .fill(AppTheme.primaryColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "envelope.fill")
                                .foregroundColor(AppTheme.primaryColor)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)

                        Text(email)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Spacer()

                    Link(destination: URL(string: "mailto:\(email)")!) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detallar")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)

            // Source
            DetailRow(
                icon: "link.circle.fill",
                label: "Mənbə",
                value: sourceText,
                color: AppTheme.primaryColor
            )

            // Budget (if available)
            if client.clientType == .buyer || client.clientType == .tenant {
                DetailRow(
                    icon: "dollarsign.circle.fill",
                    label: "Büdcə",
                    value: "Təyin olunmayıb",
                    color: AppTheme.secondaryColor
                )
            }

            // Preferred areas (placeholder)
            DetailRow(
                icon: "mappin.circle.fill",
                label: "Maraq dairəsi",
                value: "Təyin olunmayıb",
                color: AppTheme.warningColor
            )
        }
        .padding()
        .cardStyle()
    }

    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Qeydlər")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)

            Text(notes)
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding()
        .cardStyle()
    }

    private var activityTimelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Son Aktivliklər")
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Button {
                    // View all activities
                } label: {
                    Text("Hamısı")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.primaryColor)
                }
            }

            VStack(spacing: 12) {
                ActivityTimelineItem(
                    icon: "calendar",
                    title: "Görüş təyin edildi",
                    subtitle: "Bu gün, 15:00",
                    color: AppTheme.primaryColor
                )

                ActivityTimelineItem(
                    icon: "phone.fill",
                    title: "Zəng edildi",
                    subtitle: "Dünən, 11:30",
                    color: AppTheme.successColor
                )

                ActivityTimelineItem(
                    icon: "message.fill",
                    title: "Mesaj göndərildi",
                    subtitle: "3 gün əvvəl",
                    color: AppTheme.warningColor
                )
            }
        }
        .padding()
        .cardStyle()
    }

    private var timestampsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Əlavə olundu:")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)

                Text(formatDate(client.createdAt))
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textPrimary)
            }

            HStack {
                Text("Yeniləndi:")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)

                Text(formatDate(client.updatedAt))
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .padding()
    }

    // Computed properties
    private var typeColor: Color {
        switch client.clientType {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.secondaryColor
        case .tenant: return AppTheme.warningColor
        case .landlord: return Color(hex: "8B5CF6")
        }
    }

    private var typeText: String {
        switch client.clientType {
        case .buyer: return "Alıcı"
        case .seller: return "Satıcı"
        case .tenant: return "İcarəçi"
        case .landlord: return "Ev sahibi"
        }
    }

    private var typeIcon: String {
        switch client.clientType {
        case .buyer: return "cart.fill"
        case .seller: return "tag.fill"
        case .tenant: return "key.fill"
        case .landlord: return "house.fill"
        }
    }

    private var statusColor: Color {
        switch client.status {
        case .active: return AppTheme.successColor
        case .inactive: return AppTheme.textSecondary
        case .potential: return AppTheme.warningColor
        }
    }

    private var statusText: String {
        switch client.status {
        case .active: return "Aktiv"
        case .inactive: return "Passiv"
        case .potential: return "Potensial"
        }
    }

    private var sourceText: String {
        switch client.source {
        case .website: return "Vebsayt"
        case .referral: return "Tövsiyə"
        case .directCall: return "Birbaşa zəng"
        case .socialMedia: return "Sosial media"
        case .advertisement: return "Reklam"
        case .other: return "Digər"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)

                Text(value)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()
        }
    }
}

// MARK: - Activity Timeline Item

struct ActivityTimelineItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textPrimary)

                Text(subtitle)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ClientDetailView(client: Client(
            id: "1",
            name: "Vüsal Dadaşov",
            email: "vusal@example.com",
            phone: "+994501234567",
            clientType: .buyer,
            source: .referral,
            status: .active,
            notes: "Nəsimi və ya Yasamal rayonlarında 3 otaqlı mənzil axtarır. Büdcə: 120-150k",
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
