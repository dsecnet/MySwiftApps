import SwiftUI

struct AddActivityView: View {
    @Environment(\.dismiss) var dismiss
    let onSuccess: () async -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var activityType: ActivityType = .call
    @State private var scheduledDate = Date()
    @State private var hasSchedule = false

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Activity Type Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Fəaliyyət Növü")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(ActivityType.allCases, id: \.self) { type in
                                    ActivityTypeCard(
                                        type: type,
                                        isSelected: activityType == type
                                    ) {
                                        activityType = type
                                    }
                                }
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Basic Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Əsas Məlumat")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            VStack(spacing: 12) {
                                TextField("Başlıq *", text: $title)
                                    .textFieldStyle(ModernTextFieldStyle())

                                TextField("Təsvir", text: $description, axis: .vertical)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Schedule
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: $hasSchedule) {
                                Text("Planlaşdır")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .tint(AppTheme.primaryColor)

                            if hasSchedule {
                                DatePicker(
                                    "Tarix və Vaxt",
                                    selection: $scheduledDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.graphical)
                                .accentColor(AppTheme.primaryColor)
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.errorColor)
                                .padding()
                        }

                        // Save Button
                        Button {
                            Task {
                                await createActivity()
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Əlavə et")
                                }
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(isLoading || !isFormValid)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Fəaliyyət")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.errorColor)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !title.isEmpty
    }

    private func createActivity() async {
        isLoading = true
        errorMessage = nil

        let activity = ActivityCreate(
            activityType: activityType,
            title: title,
            description: description.isEmpty ? nil : description,
            propertyId: nil,
            clientId: nil,
            scheduledAt: hasSchedule ? scheduledDate : nil
        )

        do {
            _ = try await APIService.shared.createActivity(activity)
            await onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct ActivityTypeCard: View {
    let type: ActivityType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? colorForType(type) : colorForType(type).opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : colorForType(type))
                }

                Text(type.displayName)
                    .font(AppTheme.subheadline())
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                    .fill(isSelected ? colorForType(type).opacity(0.1) : AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                            .stroke(isSelected ? colorForType(type) : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: isSelected ? colorForType(type).opacity(0.3) : .clear, radius: 8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func colorForType(_ type: ActivityType) -> Color {
        switch type {
        case .call: return AppTheme.primaryColor
        case .meeting: return AppTheme.secondaryColor
        case .email: return AppTheme.infoColor
        case .viewing: return AppTheme.accentColor
        case .note: return AppTheme.textSecondary
        }
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppTheme.backgroundColor)
            .cornerRadius(AppTheme.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .stroke(AppTheme.textSecondary.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    AddActivityView {
        print("Activity created")
    }
}
