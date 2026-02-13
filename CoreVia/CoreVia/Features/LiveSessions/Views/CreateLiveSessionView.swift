import SwiftUI

/// Create Live Session View (Trainer only)
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
                Section("Basic Info") {
                    TextField(loc.localized("live_sessions_title"), text: $title)

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Session Type") {
                    Picker("Type", selection: $sessionType) {
                        ForEach(sessionTypes, id: \.self) { type in
                            Text(type.capitalized).tag(type)
                        }
                    }

                    Picker("Difficulty", selection: $difficultyLevel) {
                        ForEach(difficultyLevels, id: \.self) { level in
                            Text(level.capitalized).tag(level)
                        }
                    }
                }

                Section("Capacity & Duration") {
                    Stepper("Max Participants: \(maxParticipants)", value: $maxParticipants, in: 1...100)

                    Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 15...180, step: 15)
                }

                Section("Schedule") {
                    DatePicker("Start Time", selection: $scheduledStart, in: Date()...)
                }

                Section("Pricing") {
                    Toggle("Paid Session", isOn: $isPaid)

                    if isPaid {
                        HStack {
                            Text("$")
                            TextField("Price", value: $price, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                }

                Section("Visibility") {
                    Toggle("Public Session", isOn: $isPublic)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Create Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
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

    private func createSession() async {
        isCreating = true
        errorMessage = nil

        // For now, just simulate success
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // TODO: Call API to create session
        // let request = CreateSessionRequest(...)
        // let session = try await APIService.shared.request(...)

        isCreating = false
        dismiss()
    }
}

// #Preview { // iOS 17+ only
//     CreateLiveSessionView()
// }
