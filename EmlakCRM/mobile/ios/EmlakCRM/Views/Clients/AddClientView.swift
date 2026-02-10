import SwiftUI

struct AddClientView: View {
    @Environment(\.dismiss) var dismiss
    let onSuccess: () async -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var clientType: ClientType = .buyer
    @State private var source: ClientSource = .website
    @State private var status: ClientStatus = .active
    @State private var notes = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header Icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [colorForClientType(clientType), colorForClientType(clientType).opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: colorForClientType(clientType).opacity(0.4), radius: 20, x: 0, y: 10)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }

                            Text("Yeni Müştəri")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        .padding(.top, 20)

                        // Basic Info
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(AppTheme.primaryColor)
                                Text("Əsas Məlumat")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            VStack(spacing: 12) {
                                ClientTextField(icon: "person.fill", placeholder: "Ad Soyad *", text: $name)

                                ClientTextField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                                    .textInputAutocapitalization(.never)

                                ClientTextField(icon: "phone.fill", placeholder: "Telefon", text: $phone, keyboardType: .phonePad)
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)

                        // Client Type
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.circle.fill")
                                    .foregroundColor(colorForClientType(clientType))
                                Text("Müştəri Növü")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Picker("Müştəri növü", selection: $clientType) {
                                ForEach(ClientType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)

                        // Source
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.down.doc.fill")
                                    .foregroundColor(AppTheme.infoColor)
                                Text("Mənbə")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Picker("Mənbə", selection: $source) {
                                ForEach(ClientSource.allCases, id: \.self) { s in
                                    Text(s.displayName).tag(s)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(AppTheme.backgroundColor)
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)

                        // Status
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "flag.circle.fill")
                                    .foregroundColor(AppTheme.successColor)
                                Text("Status")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Picker("Status", selection: $status) {
                                ForEach([ClientStatus.active, ClientStatus.potential, ClientStatus.inactive], id: \.self) { s in
                                    Text(s.displayName).tag(s)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)

                        // Notes
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "note.text")
                                    .foregroundColor(AppTheme.accentColor)
                                Text("Qeydlər")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            ClientTextField(icon: "text.alignleft", placeholder: "Qeydlər", text: $notes, axis: .vertical, lineLimit: 3...6)
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)

                        // Error Message
                        if let error = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppTheme.errorColor)
                                Text(error)
                                    .font(AppTheme.caption())
                                    .foregroundColor(AppTheme.errorColor)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.errorColor.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Save Button
                        Button {
                            Task {
                                await createClient()
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Əlavə et")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [colorForClientType(clientType), colorForClientType(clientType).opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: colorForClientType(clientType).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isLoading || !isFormValid)
                        .opacity((isLoading || !isFormValid) ? 0.6 : 1.0)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Ləğv et")
                        }
                        .foregroundColor(AppTheme.errorColor)
                    }
                }
            }
        }
    }

    private func colorForClientType(_ type: ClientType) -> Color {
        switch type {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.successColor
        case .renter: return AppTheme.warningColor
        case .landlord: return AppTheme.secondaryColor
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty
    }

    private func createClient() async {
        isLoading = true
        errorMessage = nil

        let client = ClientCreate(
            name: name,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            clientType: clientType,
            source: source,
            status: status,
            notes: notes.isEmpty ? nil : notes
        )

        do {
            _ = try await APIService.shared.createClient(client)
            await onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct ClientTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int>? = nil
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 20)

            if axis == .vertical {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(lineLimit ?? 1...10)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .padding()
        .background(AppTheme.backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    AddClientView {
        print("Client created")
    }
}
