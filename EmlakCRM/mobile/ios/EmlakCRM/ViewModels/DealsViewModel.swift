import Foundation

@MainActor
class DealsViewModel: ObservableObject {
    @Published var deals: [Deal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMore = true

    private let pageSize = 20
    private let cache = CacheManager.shared
    private let networkMonitor = NetworkMonitor.shared

    var totalAmount: Double {
        deals.filter { $0.status == .completed }.reduce(0) { $0 + $1.agreedPrice }
    }

    var activeDeals: Int {
        deals.filter { $0.status == .inProgress || $0.status == .pending }.count
    }

    func loadDeals() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 1

        // Check if offline
        if !networkMonitor.isConnected {
            if let cachedDeals = cache.getCachedDeals() {
                deals = cachedDeals
                errorMessage = "Offline mode - Cached data"
                isLoading = false
                return
            }
        }

        do {
            let response = try await APIService.shared.getDeals(page: currentPage, size: pageSize)
            deals = response.items
            hasMore = currentPage < response.pages

            // Cache the results
            cache.cacheDeals(deals)
            cache.updateLastSyncDate()
        } catch {
            errorMessage = error.localizedDescription

            // Fallback to cache on error
            if let cachedDeals = cache.getCachedDeals() {
                deals = cachedDeals
                errorMessage = "Using cached data - \(error.localizedDescription)"
            }
        }

        isLoading = false
    }

    func loadMore() async {
        guard !isLoading && hasMore else { return }

        isLoading = true
        currentPage += 1

        do {
            let response = try await APIService.shared.getDeals(page: currentPage, size: pageSize)
            deals.append(contentsOf: response.items)
            hasMore = currentPage < response.pages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadDeals()
    }

    func deleteDeal(id: String) async {
        do {
            try await APIService.shared.deleteDeal(id: id)
            deals.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
