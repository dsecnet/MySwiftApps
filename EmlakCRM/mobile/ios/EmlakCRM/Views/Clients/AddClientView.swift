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
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Basic Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Əsas Məlumat")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Ad Soyad *", text: $name)
                                .textFieldStyle(.roundedBorder)

                            TextField("Email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)

                            TextField("Telefon", text: $phone)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.phonePad)
                        }
                        .padding()
                        .cardStyle()

                        // Client Type
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Müştəri Növü")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            Picker("Müştəri növü", selection: $clientType) {
                                ForEach(ClientType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .cardStyle()

                        // Source
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Mənbə")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            Picker("Mənbə", selection: $source) {
                                ForEach(ClientSource.allCases, id: \.self) { s in
                                    Text(s.displayName).tag(s)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding()
                        .cardStyle()

                        // Status
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Status")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            Picker("Status", selection: $status) {
                                ForEach([ClientStatus.active, ClientStatus.potential, ClientStatus.inactive], id: \.self) { s in
                                    Text(s.displayName).tag(s)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .cardStyle()

                        // Notes
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Qeydlər (İstəyə görə)")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Qeydlər", text: $notes, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
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
                                await createClient()
                            }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Əlavə et")
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(isLoading || !isFormValid)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Müştəri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                }
            }
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

#Preview {
    AddClientView {
        print("Client created")
    }
}
