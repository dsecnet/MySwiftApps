import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var stats: DashboardStats?
    @Published var recentActivities: [RecentActivity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadStats() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIService.shared.getDashboardStats()
            stats = response.stats
            recentActivities = response.recentActivities
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
