import SwiftUI

struct ClientDetailView: View {
    let client: Client
    @Environment(\.dismiss) var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var isDeleting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero Header with Gradient
                ZStack(alignment: .bottom) {
                    // Gradient Background
                    LinearGradient(
                        colors: [colorForClientType(client.clientType), colorForClientType(client.clientType).opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 200)

                    // Avatar and Info
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 100, height: 100)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                            Text(client.name.prefix(1).uppercased())
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(colorForClientType(client.clientType))
                        }

                        Text(client.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                        HStack(spacing: 12) {
                            Text(client.clientType.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.25))
                                .cornerRadius(10)

                            Text(client.status.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.25))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)
                }

                // Contact Info
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(AppTheme.primaryColor)
                        Text("Əlaqə Məlumatları")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(spacing: 12) {
                        if let email = client.email {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(AppTheme.primaryColor)
                                    .frame(width: 32, height: 32)
                                    .background(AppTheme.primaryColor.opacity(0.15))
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Email")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text(email)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                }

                                Spacer()
                            }
                        }

                        if let phone = client.phone {
                            HStack(spacing: 12) {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(AppTheme.successColor)
                                    .frame(width: 32, height: 32)
                                    .background(AppTheme.successColor.opacity(0.15))
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Telefon")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text(phone)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                }

                                Spacer()
                            }
                        }

                        if client.email == nil && client.phone == nil {
                            Text("Əlaqə məlumatı yoxdur")
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                                .italic()
                        }
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)

                // Source
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .foregroundColor(AppTheme.primaryColor)
                        Text("Mənbə")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: iconForSource(client.source))
                            .foregroundColor(AppTheme.secondaryColor)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.secondaryColor.opacity(0.15))
                            .cornerRadius(8)

                        Text(client.source.displayName)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)

                        Spacer()
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)

                // Notes
                if let notes = client.notes, !notes.isEmpty {
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
                            Text(formatDate(client.createdAt))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Divider()

                        HStack {
                            Text("Yenilənmə:")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(client.updatedAt))
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
        .navigationTitle("Müştəri Detalları")
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
                        .foregroundColor(colorForClientType(client.clientType))
                }
            }
        }
        .alert("Müştərini silmək istədiyinizdən əminsiniz?", isPresented: $showDeleteAlert) {
            Button("Ləğv et", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task {
                    await deleteClient()
                }
            }
        } message: {
            Text("Bu əməliyyat geri qaytarıla bilməz.")
        }
    }

    private func deleteClient() async {
        isDeleting = true
        do {
            try await APIService.shared.deleteClient(id: client.id)
            dismiss()
        } catch {
            print("Error deleting client: \(error)")
        }
        isDeleting = false
    }

    private func colorForClientType(_ type: ClientType) -> Color {
        switch type {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.successColor
        case .renter: return AppTheme.warningColor
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
