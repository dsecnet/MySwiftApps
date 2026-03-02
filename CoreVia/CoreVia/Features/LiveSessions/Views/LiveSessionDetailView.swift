import SwiftUI
import StoreKit
import os.log

/// Live Session Detail View
struct LiveSessionDetailView: View {
    let sessionId: String

    @ObservedObject private var loc = LocalizationManager.shared
    @State private var session: LiveSession?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var hasJoined = false
    @State private var showPaymentConfirmation = false
    @State private var isPurchasing = false

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
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Yüklənir...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Sessiya məlumatı yoxdur")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Sessiya tapılmadı və ya silinib")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
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
                                .stroke(Color(.systemBackground), lineWidth: 2)
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
                if session.isPaid {
                    // Pullu sessiya — ode ve qosul
                    Button {
                        showPaymentConfirmation = true
                    } label: {
                        HStack(spacing: 8) {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "creditcard.fill")
                            }
                            Text(loc.localized("live_sessions_pay_join"))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.accent)
                        .cornerRadius(12)
                    }
                    .disabled(isPurchasing)
                    .confirmationDialog(
                        loc.localized("live_sessions_pay_confirm"),
                        isPresented: $showPaymentConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button(loc.localized("live_sessions_pay_join")) {
                            Task { await payAndJoinSession(session) }
                        }
                        Button(loc.localized("common_cancel"), role: .cancel) {}
                    } message: {
                        Text("\(String(format: "%.2f", session.price)) \(session.currency)")
                    }

                    // Qiymet goster
                    Text("\(String(format: "%.2f", session.price)) \(session.currency)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                } else {
                    // Pulsuz sessiya — sadece qosul
                    Button {
                        Task { await joinSession() }
                    } label: {
                        Text(loc.localized("live_sessions_join"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("PrimaryColor"))
                            .cornerRadius(12)
                    }
                }
            } else {
                // Artiq qosulub — Start Workout
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
        errorMessage = nil

        do {
            let loadedSession: LiveSession = try await APIService.shared.request(
                endpoint: "/api/v1/live-sessions/\(sessionId)",
                method: "GET"
            )
            session = loadedSession

            // Qosulub-qosulmadigini yoxla
            await checkJoinStatus()
        } catch {
            AppLogger.training.error("Load session xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func joinSession() async {
        do {
            try await APIService.shared.requestVoid(
                endpoint: "/api/v1/live-sessions/\(sessionId)/join",
                method: "POST"
            )
            hasJoined = true
        } catch {
            AppLogger.training.error("Join session xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    /// Pullu sessiya — StoreKit 2 ile ode, sonra join et
    private func payAndJoinSession(_ session: LiveSession) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            // 1. StoreKit 2 ile ode
            let productIdentifier = "corevia_session_\(sessionId)"
            let products = try await StoreKit.Product.products(for: [productIdentifier])

            if let storeProduct = products.first {
                let result = try await storeProduct.purchase()

                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await transaction.finish()

                        // 2. Backend-e bildir ve join et
                        struct PayJoinRequest: Encodable {
                            let transactionId: String
                            enum CodingKeys: String, CodingKey {
                                case transactionId = "transaction_id"
                            }
                        }

                        try await APIService.shared.requestVoid(
                            endpoint: "/api/v1/live-sessions/\(sessionId)/join",
                            method: "POST",
                            body: PayJoinRequest(transactionId: String(transaction.id))
                        )
                        hasJoined = true

                    case .unverified(_, let error):
                        errorMessage = "Odenis dogrulama ugursuz: \(error.localizedDescription)"
                    }

                case .userCancelled:
                    break // User legv etdi, xeta gosterme

                case .pending:
                    errorMessage = "Odenis gozleyir."

                @unknown default:
                    errorMessage = "Bilinmeyen odenis netices."
                }
            } else {
                // StoreKit product tapilmadisa, backend-den birbaşa join et (test mode)
                try await APIService.shared.requestVoid(
                    endpoint: "/api/v1/live-sessions/\(sessionId)/join",
                    method: "POST"
                )
                hasJoined = true
            }
        } catch {
            AppLogger.training.error("Pay and join session xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    private func checkJoinStatus() async {
        do {
            struct ParticipantsResponse: Codable {
                let participants: [SessionParticipant]
            }
            let response: ParticipantsResponse = try await APIService.shared.request(
                endpoint: "/api/v1/live-sessions/\(sessionId)/participants",
                method: "GET"
            )
            if let userId = AuthManager.shared.currentUser?.id {
                hasJoined = response.participants.contains { $0.userId == userId }
            }
        } catch {
            // Join status yoxlanilmadi — kritik deyil
            AppLogger.training.error("Check join status xetasi: \(error.localizedDescription)")
        }
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

// #Preview { // iOS 17+ only
//     NavigationStack {
//         LiveSessionDetailView(sessionId: "123")
//     }
// }
