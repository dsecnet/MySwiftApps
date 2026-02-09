import Foundation

@MainActor
class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMore = true

    private let pageSize = 20

    func loadClients() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await APIService.shared.getClients(page: currentPage, size: pageSize)
            clients = response.items
            hasMore = currentPage < response.pages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMore() async {
        guard !isLoading && hasMore else { return }

        isLoading = true
        currentPage += 1

        do {
            let response = try await APIService.shared.getClients(page: currentPage, size: pageSize)
            clients.append(contentsOf: response.items)
            hasMore = currentPage < response.pages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadClients()
    }

    func deleteClient(id: String) async {
        do {
            try await APIService.shared.deleteClient(id: id)
            clients.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
