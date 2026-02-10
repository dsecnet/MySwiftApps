import Foundation

@MainActor
class ActivitiesViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMore = true

    private let pageSize = 20
    private let cache = CacheManager.shared
    private let networkMonitor = NetworkMonitor.shared

    func loadActivities() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 1

        // Check if offline
        if !networkMonitor.isConnected {
            if let cachedActivities = cache.getCachedActivities() {
                activities = cachedActivities
                errorMessage = "Offline mode - Cached data"
                isLoading = false
                return
            }
        }

        do {
            let response = try await APIService.shared.getActivities(page: currentPage, size: pageSize)
            activities = response.items
            hasMore = currentPage < response.pages

            // Cache the results
            cache.cacheActivities(activities)
            cache.updateLastSyncDate()
        } catch {
            errorMessage = error.localizedDescription

            // Fallback to cache on error
            if let cachedActivities = cache.getCachedActivities() {
                activities = cachedActivities
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
            let response = try await APIService.shared.getActivities(page: currentPage, size: pageSize)
            activities.append(contentsOf: response.items)
            hasMore = currentPage < response.pages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadActivities()
    }

    func completeActivity(id: String) async {
        do {
            let updatedActivity = try await APIService.shared.completeActivity(id: id)
            if let index = activities.firstIndex(where: { $0.id == id }) {
                activities[index] = updatedActivity
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteActivity(id: String) async {
        do {
            try await APIService.shared.deleteActivity(id: id)
            activities.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
