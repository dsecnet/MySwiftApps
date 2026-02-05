import SwiftUI

/// Live Session Detail View
struct LiveSessionDetailView: View {
    let sessionId: String

    @ObservedObject private var loc = LocalizationManager.shared
    @State private var session: LiveSession?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var hasJoined = false

    var body: some View {
        ScrollView {
            if let session = session {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image/Status
                    headerSection(session)

                    VStack(alignment: .leading, spacing: 16) {
                        // Title & Trainer
                        titleSection(session)

                        Divider()

                        // Info Grid
                        infoGrid(session)

                        Divider()

                        // Description
                        if let description = session.description {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)

                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Divider()

                        // Participants
                        participantsSection(session)

                        // Join/Start Button
                        if session.status == "scheduled" {
                            actionButton(session)
                        }
                    }
                    .padding()
                }
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Session not found")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadSession()
        }
    }

    // MARK: - Header

    private func headerSection(_ session: LiveSession) -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color("PrimaryColor").gradient)
                .frame(height: 150)

            HStack {
                // Status Badge
                Text(session.status.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(session.status))
                    .cornerRadius(8)

                Spacer()

                // Difficulty
                Text(session.difficultyLevel.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            .padding()
        }
    }

    // MARK: - Title Section

    private func titleSection(_ session: LiveSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.title)
                .font(.title2)
                .fontWeight(.bold)

            if let trainer = session.trainer {
                HStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Color("PrimaryColor"))
                    Text(trainer.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Info Grid

    private func infoGrid(_ session: LiveSession) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            InfoCell(
                icon: "calendar",
                title: "Date",
                value: session.scheduledStart.formatted(date: .abbreviated, time: .omitted)
            )

            InfoCell(
                icon: "clock",
                title: "Time",
                value: session.scheduledStart.formatted(date: .omitted, time: .shortened)
            )

            InfoCell(
                icon: "hourglass",
                title: "Duration",
                value: "\(session.durationMinutes) min"
            )

            InfoCell(
                icon: "person.2",
                title: "Capacity",
                value: "\(session.registeredCount ?? 0)/\(session.maxParticipants)"
            )
        }
    }

    // MARK: - Participants

    private func participantsSection(_ session: LiveSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loc.localized("live_sessions_participants"))
                    .font(.headline)

                Spacer()

                Text("\(session.registeredCount ?? 0) joined")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Placeholder for participant list
            HStack(spacing: -10) {
                ForEach(0..<min(session.registeredCount ?? 0, 5), id: \.self) { _ in
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        }
                }

                if (session.registeredCount ?? 0) > 5 {
                    Text("+\((session.registeredCount ?? 0) - 5)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
            }
        }
    }

    // MARK: - Action Button

    private func actionButton(_ session: LiveSession) -> some View {
        VStack(spacing: 12) {
            if !hasJoined {
                Button {
                    Task {
                        await joinSession()
                    }
                } label: {
                    Text(loc.localized("live_sessions_join"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryColor"))
                        .cornerRadius(12)
                }
            } else {
                // Show "Joined" or "Start Workout" button
                NavigationLink {
                    LiveWorkoutView(sessionId: sessionId)
                } label: {
                    Text("Start Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }

            if session.isPaid {
                Text("Price: \(String(format: "%.2f", session.price)) \(session.currency)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "live": return .red
        case "scheduled": return .blue
        case "completed": return .gray
        default: return .orange
        }
    }

    // MARK: - API Calls

    private func loadSession() async {
        isLoading = true

        // TODO: Load session from API
        // let session = try await APIService.shared.request(...)

        // Simulate loading
        try? await Task.sleep(nanoseconds: 500_000_000)

        isLoading = false
    }

    private func joinSession() async {
        // TODO: Join session API call
        hasJoined = true
    }
}

// MARK: - Info Cell

struct InfoCell: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        LiveSessionDetailView(sessionId: "123")
    }
}
