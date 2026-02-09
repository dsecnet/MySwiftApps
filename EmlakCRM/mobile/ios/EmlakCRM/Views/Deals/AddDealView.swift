import SwiftUI

struct AddDealView: View {
    @Environment(\.dismiss) var dismiss
    let onSuccess: () async -> Void

    @State private var notes = ""
    @State private var amount = ""
    @State private var propertyId = ""
    @State private var clientId = ""
    @State private var status: DealStatus = .pending

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Amount Input (Featured)
                        VStack(spacing: 16) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(AppTheme.successGradient)

                            Text("Məbləğ")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("0", text: $amount)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppTheme.primaryColor)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(AppTheme.backgroundColor)
                                .cornerRadius(AppTheme.mediumCornerRadius)

                            Text("AZN")
                                .font(AppTheme.callout())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding()
                        .cardStyle()

                        // Basic Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Əsas Məlumat")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            VStack(spacing: 12) {
                                TextField("Qeydlər", text: $notes, axis: .vertical)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .lineLimit(3...6)

                                TextField("Əmlak ID *", text: $propertyId)
                                    .textFieldStyle(ModernTextFieldStyle())

                                TextField("Müştəri ID *", text: $clientId)
                                    .textFieldStyle(ModernTextFieldStyle())
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Status Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Status")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            VStack(spacing: 12) {
                                ForEach([DealStatus.pending, .inProgress], id: \.self) { dealStatus in
                                    StatusOptionCard(
                                        status: dealStatus,
                                        isSelected: status == dealStatus
                                    ) {
                                        status = dealStatus
                                    }
                                }
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
                                await createDeal()
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
            .navigationTitle("Yeni Sövdələşmə")
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
        !propertyId.isEmpty && !clientId.isEmpty && !amount.isEmpty && Double(amount) != nil
    }

    private func createDeal() async {
        isLoading = true
        errorMessage = nil

        guard let amountValue = Double(amount) else {
            errorMessage = "Məbləğ düzgün daxil edilməlidir"
            isLoading = false
            return
        }

        let deal = DealCreate(
            propertyId: propertyId,
            clientId: clientId,
            agreedPrice: amountValue,
            notes: notes.isEmpty ? nil : notes
        )

        do {
            _ = try await APIService.shared.createDeal(deal)
            await onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct StatusOptionCard: View {
    let status: DealStatus
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? colorForStatus(status) : AppTheme.textSecondary)

                Text(status.displayName)
                    .font(AppTheme.callout())
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(isSelected ? colorForStatus(status).opacity(0.1) : AppTheme.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .stroke(isSelected ? colorForStatus(status) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func colorForStatus(_ status: DealStatus) -> Color {
        switch status {
        case .pending: return AppTheme.warningColor
        case .inProgress: return AppTheme.primaryColor
        case .completed: return AppTheme.successColor
        case .cancelled: return AppTheme.errorColor
        }
    }
}

#Preview {
    AddDealView {
        print("Deal created")
    }
}
