import SwiftUI

/// Create Live Session View (Trainer only)
/// // MARK: - Request Model
struct CreateLiveSessionRequest: Encodable {
    let title: String
    let description: String
    let session_type: String
    let max_participants: Int
    let difficulty_level: String
    let duration_minutes: Int
    let scheduled_start: String
    let is_public: Bool
    let is_paid: Bool
    let price: Double
}

struct CreateLiveSessionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var title = ""
    @State private var description = ""
    @State private var sessionType = "group"
    @State private var maxParticipants = 10
    @State private var difficultyLevel = "beginner"
    @State private var durationMinutes = 60
    @State private var scheduledStart = Date().addingTimeInterval(3600) // 1 hour from now
    @State private var isPublic = true
    @State private var isPaid = false
    @State private var price: Double = 0.0

    @State private var isCreating = false
    @State private var errorMessage: String?

    let sessionTypes = ["group", "one_on_one", "open"]
    let difficultyLevels = ["beginner", "intermediate", "advanced"]

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.localized("create_session_basic_info")) {
                    TextField(loc.localized("live_sessions_title"), text: $title)

                    TextField(loc.localized("live_session_description"), text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(loc.localized("create_session_type")) {
                    Picker(loc.localized("create_session_type_label"), selection: $sessionType) {
                        ForEach(sessionTypes, id: \.self) { type in
                            Text(type.capitalized).tag(type)
                        }
                    }

                    Picker(loc.localized("create_session_difficulty"), selection: $difficultyLevel) {
                        ForEach(difficultyLevels, id: \.self) { level in
                            Text(level.capitalized).tag(level)
                        }
                    }
                }

                Section(loc.localized("create_session_capacity")) {
                    Stepper("\(loc.localized("create_session_max_participants")): \(maxParticipants)", value: $maxParticipants, in: 1...100)

                    Stepper("\(loc.localized("create_session_duration_label")): \(durationMinutes) \(loc.localized("common_min"))", value: $durationMinutes, in: 15...180, step: 15)
                }

                Section(loc.localized("create_session_schedule")) {
                    DatePicker(loc.localized("create_session_start_time"), selection: $scheduledStart, in: Date()...)
                }

                Section(loc.localized("create_session_pricing")) {
                    Toggle(loc.localized("create_session_paid"), isOn: $isPaid)

                    if isPaid {
                        HStack {
                            Text("$")
                            TextField(loc.localized("create_session_price"), value: $price, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                }

                Section(loc.localized("create_session_visibility")) {
                    Toggle(loc.localized("create_session_public"), isOn: $isPublic)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(loc.localized("create_session_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.localized("common_cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.localized("common_create")) {
                        Task {
                            await createSession()
                        }
                    }
                    .disabled(title.isEmpty || isCreating)
                }
            }
            .overlay {
                if isCreating {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }

    // FIX 9: NEW - Real API integration with error handling
    private func createSession() async {
        isCreating = true
        errorMessage = nil

        do {
            // Prepare session request
            let request = CreateLiveSessionRequest(
                title: title,
                description: description,
                session_type: sessionType,
                max_participants: maxParticipants,
                difficulty_level: difficultyLevel,
                duration_minutes: durationMinutes,
                scheduled_start: ISO8601DateFormatter().string(from: scheduledStart),
                is_public: isPublic,
                is_paid: isPaid,
                price: isPaid ? price : 0.0
            )

            // FIX 9: Call backend API to create live session
            let _: [String: String] = try await APIService.shared.request(
                endpoint: "/api/v1/live-sessions",
                method: "POST",
                body: request
            )

            // Success - dismiss view
            await MainActor.run {
                isCreating = false
                dismiss()
            }

        } catch let error as APIError {
            // FIX 9: Handle API errors with Azerbaijani message
            await MainActor.run {
                isCreating = false
                errorMessage = error.errorDescription ?? loc.localized("common_error_retry")
            }
        } catch {
            // FIX 9: Handle other errors with Azerbaijani message
            await MainActor.run {
                isCreating = false
                errorMessage = loc.localized("common_error_retry")
            }
        }
    }
}

// #Preview { // iOS 17+ only
//     CreateLiveSessionView()
// }
