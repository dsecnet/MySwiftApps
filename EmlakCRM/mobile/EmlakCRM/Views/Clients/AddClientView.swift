//
//  AddClientView.swift
//  EmlakCRM
//
//  Add New Client Screen
//

import SwiftUI

struct AddClientView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddClientViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Basic Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Əsas Məlumat")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            // Name
                            FormField(label: "Ad Soyad *") {
                                TextField("Məsələn: Rəşad Məmmədov", text: $viewModel.name)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }

                            // Phone
                            FormField(label: "Telefon *") {
                                TextField("+994501234567", text: $viewModel.phone)
                                    .textFieldStyle(.plain)
                                    .keyboardType(.phonePad)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }

                            // Email
                            FormField(label: "Email") {
                                TextField("example@mail.com", text: $viewModel.email)
                                    .textFieldStyle(.plain)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Client Type & Status
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Kateqoriya")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            // Client Type
                            FormField(label: "Müştəri növü *") {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ClientTypeButton(
                                        icon: "cart.fill",
                                        title: "Alıcı",
                                        type: .buyer,
                                        selected: viewModel.clientType,
                                        action: { viewModel.clientType = .buyer }
                                    )

                                    ClientTypeButton(
                                        icon: "tag.fill",
                                        title: "Satıcı",
                                        type: .seller,
                                        selected: viewModel.clientType,
                                        action: { viewModel.clientType = .seller }
                                    )

                                    ClientTypeButton(
                                        icon: "key.fill",
                                        title: "İcarəçi",
                                        type: .tenant,
                                        selected: viewModel.clientType,
                                        action: { viewModel.clientType = .tenant }
                                    )

                                    ClientTypeButton(
                                        icon: "house.fill",
                                        title: "Ev sahibi",
                                        type: .landlord,
                                        selected: viewModel.clientType,
                                        action: { viewModel.clientType = .landlord }
                                    )
                                }
                            }

                            // Source
                            FormField(label: "Mənbə") {
                                Menu {
                                    ForEach(ClientSource.allCases, id: \.self) { source in
                                        Button {
                                            viewModel.source = source
                                        } label: {
                                            Text(sourceText(source))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(sourceText(viewModel.source))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                                }
                            }

                            // Status
                            FormField(label: "Status") {
                                HStack(spacing: 12) {
                                    ForEach([ClientStatus.potential, .active], id: \.self) { status in
                                        ToggleButton(
                                            title: statusText(status),
                                            isSelected: viewModel.status == status
                                        ) {
                                            viewModel.status = status
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Notes
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Qeydlər")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextEditor(text: $viewModel.notes)
                                .frame(height: 120)
                                .padding(8)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                        .padding()
                        .cardStyle()

                        // Error message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.errorColor)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.errorColor.opacity(0.1))
                                .cornerRadius(AppTheme.cornerRadius)
                                .padding(.horizontal)
                        }

                        // Save Button
                        Button {
                            Task {
                                let success = await viewModel.saveClient()
                                if success {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Yadda saxla")
                                }
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(!viewModel.isValid || viewModel.isLoading)
                        .opacity((!viewModel.isValid || viewModel.isLoading) ? 0.6 : 1.0)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Yeni Müştəri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Ləğv et")
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
        }
    }

    private func sourceText(_ source: ClientSource) -> String {
        switch source {
        case .website: return "Vebsayt"
        case .referral: return "Tövsiyə"
        case .directCall: return "Birbaşa zəng"
        case .socialMedia: return "Sosial media"
        case .advertisement: return "Reklam"
        case .other: return "Digər"
        }
    }

    private func statusText(_ status: ClientStatus) -> String {
        switch status {
        case .active: return "Aktiv"
        case .inactive: return "Passiv"
        case .potential: return "Potensial"
        }
    }
}

// MARK: - Client Type Button

struct ClientTypeButton: View {
    let icon: String
    let title: String
    let type: ClientType
    let selected: ClientType
    let action: () -> Void

    private var isSelected: Bool {
        type == selected
    }

    private var color: Color {
        switch type {
        case .buyer: return AppTheme.primaryColor
        case .seller: return AppTheme.secondaryColor
        case .tenant: return AppTheme.warningColor
        case .landlord: return Color(hex: "8B5CF6")
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : color)

                Text(title)
                    .font(AppTheme.caption())
                    .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? color : AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
}

// MARK: - Add Client ViewModel

@MainActor
class AddClientViewModel: ObservableObject {
    @Published var name = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var clientType: ClientType = .buyer
    @Published var source: ClientSource = .website
    @Published var status: ClientStatus = .potential
    @Published var notes = ""

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    var isValid: Bool {
        !name.isEmpty && !phone.isEmpty
    }

    func saveClient() async -> Bool {
        guard isValid else { return false }

        isLoading = true
        errorMessage = nil

        do {
            let clientData = ClientCreate(
                name: name,
                email: email.isEmpty ? nil : email,
                phone: phone.isEmpty ? nil : phone,
                clientType: clientType,
                source: source,
                status: status,
                notes: notes.isEmpty ? nil : notes
            )

            _ = try await apiService.createClient(clientData)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

#Preview {
    AddClientView()
}
