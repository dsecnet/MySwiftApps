import Foundation
import SwiftUI
import os.log

@MainActor
class AnalyticsDashboardViewModel: ObservableObject {
    @Published var dashboard: AnalyticsDashboardResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadDashboard() async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedDashboard: AnalyticsDashboardResponse = try await APIService.shared.request(
                endpoint: "/api/v1/analytics/dashboard",
                method: "GET"
            )

            dashboard = loadedDashboard

        } catch {
            AppLogger.network.error("Load analytics dashboard xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
