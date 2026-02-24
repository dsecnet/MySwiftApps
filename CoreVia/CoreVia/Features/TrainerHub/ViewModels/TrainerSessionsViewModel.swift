//
//  TrainerSessionsViewModel.swift
//  CoreVia
//
//  Trainer sessiya CRUD - movcut APIService pattern-i ile
//

import Foundation

@MainActor
class TrainerSessionsViewModel: ObservableObject {
    @Published var sessions: [LiveSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMore = true
    @Published var selectedFilter: FilterType = .all

    private var currentPage = 1
    private let pageSize = 20

    enum FilterType {
        case all, upcoming, live, completed
    }

    // MARK: - Load Sessions (trainer's own)

    func loadSessions(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            hasMore = true
        }

        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            var queryItems = [
                URLQueryItem(name: "page", value: "\(currentPage)"),
                URLQueryItem(name: "page_size", value: "\(pageSize)"),
                URLQueryItem(name: "my_sessions", value: "true")
            ]

            switch selectedFilter {
            case .all:
                queryItems.append(URLQueryItem(name: "upcoming_only", value: "false"))
            case .upcoming:
                queryItems.append(URLQueryItem(name: "upcoming_only", value: "true"))
            case .live:
                queryItems.append(URLQueryItem(name: "status_filter", value: "live"))
            case .completed:
                queryItems.append(URLQueryItem(name: "status_filter", value: "completed"))
            }

            let response: SessionListResponse = try await APIService.shared.request(
                endpoint: "/api/v1/live-sessions",
                method: "GET",
                queryItems: queryItems
            )

            if refresh {
                sessions = response.sessions
            } else {
                sessions.append(contentsOf: response.sessions)
            }

            hasMore = response.hasMore
            currentPage += 1

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Load More

    func loadMore() async {
        guard hasMore, !isLoading else { return }
        await loadSessions()
    }

    // MARK: - Delete Session

    func deleteSession(_ sessionId: String) async {
        do {
            try await APIService.shared.requestVoid(
                endpoint: "/api/v1/live-sessions/\(sessionId)",
                method: "DELETE"
            )
            sessions.removeAll { $0.id == sessionId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
