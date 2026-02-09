import SwiftUI

struct ClientsListView: View {
    @StateObject private var viewModel = ClientsViewModel()
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
                AppTheme.backgroundColor.ignoresSafeArea()

                if viewModel.isLoading && viewModel.clients.isEmpty {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredClients) { client in
                                NavigationLink(destination: ClientDetailView(client: client)) {
                                    ClientRowView(client: client)
                                }
                                .buttonStyle(PlainButtonStyle())
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
            .navigationTitle("Müştərilər")
            .searchable(text: $searchText, prompt: "Axtar...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddClient = true
                    } label: {
                        Image(systemName: "plus")
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
}

struct ClientRowView: View {
    let client: Client

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(colorForClientType(client.clientType).opacity(0.2))
                    .frame(width: 50, height: 50)

                Text(client.name.prefix(1).uppercased())
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(colorForClientType(client.clientType))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(client.name)
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)

                if let email = client.email {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(.caption)
                        Text(email)
                            .font(AppTheme.caption())
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }

                if let phone = client.phone {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(.caption)
                        Text(phone)
                            .font(AppTheme.caption())
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }

                HStack(spacing: 8) {
                    ClientTypeBadge(type: client.clientType)
                    ClientStatusBadge(status: client.status)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.textSecondary)
                .font(.caption)
        }
        .padding()
        .cardStyle()
    }

    private func colorForClientType(_ type: ClientType) -> Color {
        switch type {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.successColor
        case .tenant: return AppTheme.warningColor
        case .landlord: return AppTheme.secondaryColor
        }
    }
}

struct ClientTypeBadge: View {
    let type: ClientType

    var body: some View {
        Text(type.displayName)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(colorForType(type))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(colorForType(type).opacity(0.15))
            .cornerRadius(6)
    }

    private func colorForType(_ type: ClientType) -> Color {
        switch type {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.successColor
        case .tenant: return AppTheme.warningColor
        case .landlord: return AppTheme.secondaryColor
        }
    }
}

struct ClientStatusBadge: View {
    let status: ClientStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(colorForStatus(status))
            .cornerRadius(6)
    }

    private func colorForStatus(_ status: ClientStatus) -> Color {
        switch status {
        case .active: return AppTheme.successColor
        case .inactive: return AppTheme.textSecondary
        case .potential: return AppTheme.warningColor
        }
    }
}

#Preview {
    ClientsListView()
}
