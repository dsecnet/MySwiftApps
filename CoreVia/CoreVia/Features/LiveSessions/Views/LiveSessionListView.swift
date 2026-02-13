import SwiftUI

/// Live Sessions List View
struct LiveSessionListView: View {
    @StateObject private var viewModel = LiveSessionListViewModel()
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showCreateSession = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Tabs
                filterSection

                // Sessions List
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    loadingView
                } else if viewModel.sessions.isEmpty {
                    emptyStateView
                } else {
                    sessionsListView
                }
            }
            .navigationTitle(loc.localized("live_sessions_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Only trainers can create sessions
                    if UserDefaults.standard.string(forKey: "userType") == "trainer" {
                        Button {
                            showCreateSession = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color("PrimaryColor"))
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateSession) {
                CreateLiveSessionView()
            }
            .refreshable {
                await viewModel.loadSessions(refresh: true)
            }
            .task {
                await viewModel.loadSessions()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: loc.localized("live_sessions_all"),
                    isSelected: viewModel.selectedFilter == .all
                ) {
                    viewModel.selectedFilter = .all
                    Task { await viewModel.loadSessions(refresh: true) }
                }

                FilterChip(
                    title: loc.localized("live_sessions_upcoming"),
                    isSelected: viewModel.selectedFilter == .upcoming
                ) {
                    viewModel.selectedFilter = .upcoming
                    Task { await viewModel.loadSessions(refresh: true) }
                }

                FilterChip(
                    title: loc.localized("live_sessions_live"),
                    isSelected: viewModel.selectedFilter == .live
                ) {
                    viewModel.selectedFilter = .live
                    Task { await viewModel.loadSessions(refresh: true) }
                }

                FilterChip(
                    title: loc.localized("live_sessions_completed"),
                    isSelected: viewModel.selectedFilter == .completed
                ) {
                    viewModel.selectedFilter = .completed
                    Task { await viewModel.loadSessions(refresh: true) }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Sessions List

    private var sessionsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.sessions) { session in
                    NavigationLink {
                        LiveSessionDetailView(sessionId: session.id)
                    } label: {
                        LiveSessionCard(session: session)
                    }
                    .buttonStyle(.plain)
                }

                // Load More
                if viewModel.hasMore {
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 70))
                .foregroundColor(.gray)

            Text(loc.localized("live_sessions_no_sessions"))
                .font(.title3)
                .fontWeight(.semibold)

            Text(loc.localized("live_sessions_no_sessions_desc"))
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

// MARK: - Live Session Card

struct LiveSessionCard: View {
    let session: LiveSession
    let loc = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Status Badge
                statusBadge

                Spacer()

                // Difficulty
                Text(session.difficultyLevel.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(difficultyColor)
                    .cornerRadius(8)
            }

            // Title
            Text(session.title)
                .font(.headline)
                .foregroundColor(.primary)

            // Trainer
            if let trainer = session.trainer {
                HStack(spacing: 8) {
                    Image(systemName: "person.circle")
                        .font(.caption)
                    Text(trainer.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            // Time & Duration
            HStack(spacing: 16) {
                Label(
                    session.scheduledStart.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundColor(.gray)

                Label(
                    "\(session.durationMinutes) min",
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundColor(.gray)
            }

            // Participants
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(Color("PrimaryColor"))

                Text("\(session.registeredCount ?? 0)/\(session.maxParticipants)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                // Price
                if session.isPaid {
                    Text("\(String(format: "%.2f", session.price)) \(session.currency)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryColor"))
                } else {
                    Text(loc.localized("common_free"))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(session.status.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }

    private var statusColor: Color {
        switch session.status {
        case "scheduled": return .blue
        case "live": return .red
        case "completed": return .gray
        case "cancelled": return .orange
        default: return .gray
        }
    }

    private var difficultyColor: Color {
        switch session.difficultyLevel {
        case "beginner": return .green
        case "intermediate": return .orange
        case "advanced": return .red
        default: return .gray
        }
    }
}

// MARK: - ViewModel

@MainActor
class LiveSessionListViewModel: ObservableObject {
    @Published var sessions: [LiveSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMore = true
    @Published var selectedFilter: FilterType = .upcoming

    private var currentPage = 1
    private let pageSize = 20

    enum FilterType {
        case all, upcoming, live, completed
    }

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
                URLQueryItem(name: "page_size", value: "\(pageSize)")
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

    func loadMore() async {
        guard hasMore, !isLoading else { return }
        await loadSessions()
    }
}

// #Preview { // iOS 17+ only
//     LiveSessionListView()
// }
