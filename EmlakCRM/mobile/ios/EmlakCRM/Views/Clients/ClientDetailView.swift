import SwiftUI

struct ClientDetailView: View {
    let client: Client
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(colorForClientType(client.clientType).opacity(0.2))
                            .frame(width: 80, height: 80)

                        Text(client.name.prefix(1).uppercased())
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(colorForClientType(client.clientType))
                    }

                    Text(client.name)
                        .font(AppTheme.title())
                        .foregroundColor(AppTheme.textPrimary)

                    HStack(spacing: 12) {
                        ClientTypeBadge(type: client.clientType)
                        ClientStatusBadge(status: client.status)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardStyle()

                // Contact Info
                VStack(alignment: .leading, spacing: 16) {
                    Text("Əlaqə Məlumatları")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    if let email = client.email {
                        ContactRow(icon: "envelope.fill", label: "Email", value: email)
                    }

                    if let phone = client.phone {
                        ContactRow(icon: "phone.fill", label: "Telefon", value: phone)
                    }

                    if client.email == nil && client.phone == nil {
                        Text("Əlaqə məlumatı yoxdur")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .italic()
                    }
                }
                .padding()
                .cardStyle()

                // Source
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mənbə")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    HStack {
                        Image(systemName: iconForSource(client.source))
                            .foregroundColor(AppTheme.primaryColor)

                        Text(client.source.displayName)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding()
                .cardStyle()

                // Notes
                if let notes = client.notes, !notes.isEmpty {
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

                // Dates
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tarixlər")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Yaradılma:")
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(client.createdAt))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        HStack {
                            Text("Yenilənmə:")
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(client.updatedAt))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .font(AppTheme.body())
                }
                .padding()
                .cardStyle()
            }
            .padding()
        }
        .background(AppTheme.backgroundColor)
        .navigationTitle("Müştəri Detalları")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func colorForClientType(_ type: ClientType) -> Color {
        switch type {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.successColor
        case .tenant: return AppTheme.warningColor
        case .landlord: return AppTheme.secondaryColor
        }
    }

    private func iconForSource(_ source: ClientSource) -> String {
        switch source {
        case .website: return "globe"
        case .referral: return "person.2.fill"
        case .directCall: return "phone.fill"
        case .socialMedia: return "heart.text.square.fill"
        case .advertisement: return "megaphone.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ContactRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)

            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primaryColor)
                    .font(.body)

                Text(value)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textPrimary)
            }
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
            source: .website,
            status: .active,
            notes: "Çox yaxşı müştəri",
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
