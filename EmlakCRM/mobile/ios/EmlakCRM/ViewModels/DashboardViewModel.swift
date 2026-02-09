import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var stats: DashboardStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadStats() async {
        isLoading = true
        errorMessage = nil

        do {
            stats = try await APIService.shared.getDashboardStats()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
