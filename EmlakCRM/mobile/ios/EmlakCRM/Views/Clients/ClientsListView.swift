import SwiftUI

struct ClientsListView: View {
    @StateObject private var viewModel = ClientsViewModel()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var searchText = ""
    @State private var showAddClient = false

    var filteredClients: [Client] {
        if searchText.isEmpty {
            return viewModel.clients
        }
        return viewModel.clients.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            ($0.phone?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Network Status Bar
                    NetworkStatusBar()

                    // Stats Header
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ClientStatCard(
                                title: "Toplam",
                                value: "\(viewModel.clients.count)",
                                icon: "person.3.fill",
                                color: AppTheme.primaryColor
                            )

                            ClientStatCard(
                                title: "Aktiv",
                                value: "\(viewModel.clients.filter { $0.status == .active }.count)",
                                icon: "checkmark.circle.fill",
                                color: AppTheme.successColor
                            )

                            ClientStatCard(
                                title: "Potensial",
                                value: "\(viewModel.clients.filter { $0.status == .potential }.count)",
                                icon: "star.fill",
                                color: AppTheme.warningColor
                            )
                        }
                        .padding()
                    }

                    if viewModel.isLoading && viewModel.clients.isEmpty {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredClients.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "person.3.fill",
                            title: "Müştəri yoxdur",
                            message: "Yeni müştəri əlavə edin"
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredClients) { client in
                                    NavigationLink(destination: ClientDetailView(client: client)) {
                                        ClientRowView(client: client)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Task {
                                                await deleteClient(client)
                                            }
                                        } label: {
                                            Label("Sil", systemImage: "trash")
                                        }
                                    }
                                }

                                if viewModel.hasMore {
                                    ProgressView()
                                        .padding()
                                        .task {
                                            await viewModel.loadMore()
                                        }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.refresh()
                        }
                    }
                }
            }
            .navigationTitle("Müştərilər")
            .searchable(text: $searchText, prompt: "Axtar...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddClient = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.primaryGradient)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddClient) {
                AddClientView {
                    await viewModel.refresh()
                }
            }
            .task {
                await viewModel.loadClients()
            }
        }
    }

    private func deleteClient(_ client: Client) async {
        do {
            try await APIService.shared.deleteClient(id: client.id)
            await viewModel.refresh()
        } catch {
            print("Error deleting client: \(error)")
        }
    }
}

struct ClientRowView: View {
    let client: Client

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Modern Avatar with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [colorForClientType(client.clientType), colorForClientType(client.clientType).opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Text(client.name.prefix(1).uppercased())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(client.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    HStack(spacing: 8) {
                        ClientTypeBadge(type: client.clientType)
                        ClientStatusBadge(status: client.status)
                    }
                }

                Spacer()
            }
            .padding()

            Divider()
                .padding(.horizontal)

            VStack(spacing: 8) {
                if let email = client.email {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .font(.caption)
                            .foregroundColor(AppTheme.primaryColor)
                            .frame(width: 20)
                        Text(email)
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                }

                if let phone = client.phone {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.caption)
                            .foregroundColor(AppTheme.primaryColor)
                            .frame(width: 20)
                        Text(phone)
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                }
            }
            .padding()
            .padding(.top, -8)
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
    }

    private func colorForClientType(_ type: ClientType) -> Color {
        switch type {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.successColor
        case .renter: return AppTheme.warningColor
        case .landlord: return AppTheme.secondaryColor
        }
    }
}

struct ClientTypeBadge: View {
    let type: ClientType

    var body: some View {
        Text(type.displayName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(colorForType(type))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(colorForType(type).opacity(0.15))
            .cornerRadius(8)
    }

    private func colorForType(_ type: ClientType) -> Color {
        switch type {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.successColor
        case .renter: return AppTheme.warningColor
        case .landlord: return AppTheme.secondaryColor
        }
    }
}

struct ClientStatusBadge: View {
    let status: ClientStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(colorForStatus(status))
            .cornerRadius(8)
    }

    private func colorForStatus(_ status: ClientStatus) -> Color {
        switch status {
        case .active: return AppTheme.successColor
        case .inactive: return AppTheme.textSecondary
        case .potential: return AppTheme.warningColor
        }
    }
}

struct ClientStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(title)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
    }
}

#Preview {
    ClientsListView()
}
