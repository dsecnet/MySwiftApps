import Foundation

@MainActor
class PropertiesViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMore = true

    private let pageSize = 20

    func loadProperties() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await APIService.shared.getProperties(page: currentPage, size: pageSize)
            properties = response.items
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
            let response = try await APIService.shared.getProperties(page: currentPage, size: pageSize)
            properties.append(contentsOf: response.items)
            hasMore = currentPage < response.pages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadProperties()
    }

    func deleteProperty(id: String) async {
        do {
            try await APIService.shared.deleteProperty(id: id)
            properties.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
