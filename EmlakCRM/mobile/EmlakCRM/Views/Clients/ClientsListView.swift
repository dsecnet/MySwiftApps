//
//  ClientsListView.swift
//  EmlakCRM
//
//  Clients List Screen
//

import SwiftUI

struct ClientsListView: View {
    @StateObject private var viewModel = ClientsViewModel()
    @State private var showAddClient = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                if viewModel.isLoading && viewModel.clients.isEmpty {
                    ProgressView()
                } else if viewModel.clients.isEmpty {
                    emptyStateView
                } else {
                    clientsList
                }
            }
            .navigationTitle("Müştərilər")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Müştəri axtar...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddClient = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showAddClient) {
                AddClientView()
            }
        }
        .task {
            await viewModel.loadClients()
        }
    }

    private var clientsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredClients) { client in
                    NavigationLink(destination: ClientDetailView(client: client)) {
                        ClientRowView(client: client)
                    }
                    .buttonStyle(.plain)
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

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textSecondary)

            Text("Müştəri yoxdur")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)

            Text("Yeni müştəri əlavə etmək üçün + düyməsinə toxunun")
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showAddClient = true
            } label: {
                Text("Müştəri əlavə et")
            }
            .primaryButtonStyle()
            .padding(.horizontal, 40)
        }
    }

    private var filteredClients: [Client] {
        if searchText.isEmpty {
            return viewModel.clients
        }
        return viewModel.clients.filter { client in
            client.name.localizedCaseInsensitiveContains(searchText) ||
            (client.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (client.phone?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
}

// MARK: - Client Row View

struct ClientRowView: View {
    let client: Client

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

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(typeColor.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(client.name.prefix(1).uppercased())
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(typeColor)
                )

            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(client.name)
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                // Type & Status
                HStack(spacing: 8) {
                    Text(typeText)
                        .font(AppTheme.caption())
                        .foregroundColor(typeColor)

                    Circle()
                        .fill(AppTheme.textSecondary)
                        .frame(width: 3, height: 3)

                    Text(statusText)
                        .font(AppTheme.caption())
                        .foregroundColor(statusColor)
                }

                // Contact
                if let phone = client.phone {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)

                        Text(phone)
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                } else if let email = client.email {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)

                        Text(email)
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Clients ViewModel

@MainActor
class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMore = true

    private let apiService = APIService.shared
    private let pageSize = 20

    func loadClients() async {
        guard !isLoading else { return }
        isLoading = true
        currentPage = 1

        do {
            let response = try await apiService.getClients(page: currentPage, limit: pageSize)
            clients = response.items
            hasMore = response.items.count == pageSize
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadMore() async {
        guard !isLoading && hasMore else { return }
        isLoading = true
        currentPage += 1

        do {
            let response = try await apiService.getClients(page: currentPage, limit: pageSize)
            clients.append(contentsOf: response.items)
            hasMore = response.items.count == pageSize
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            currentPage -= 1
        }
    }

    func refresh() async {
        await loadClients()
    }
}

#Preview {
    ClientsListView()
}
