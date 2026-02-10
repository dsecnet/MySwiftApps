import SwiftUI

struct WhatsAppShareSheet: View {
    let property: Property
    @Environment(\.dismiss) var dismiss
    @State private var phoneNumber = ""
    @State private var customMessage = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var whatsappLink: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Müştəri Telefonu") {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(AppTheme.primaryColor)

                        TextField("+994501234567", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    }

                    Text("Azərbaycan format: +994501234567 və ya 0501234567")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Əlavə Qeyd (Optional)") {
                    TextEditor(text: $customMessage)
                        .frame(height: 80)
                }

                Section("Mesaj Önizləməsi") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🏢 \(property.title)")
                            .font(.headline)

                        Text("📍 \(property.address ?? property.district ?? "Bakı")")
                            .font(.subheadline)

                        Text("💰 \(property.price.toCurrency())")
                            .font(.title3)
                            .foregroundColor(AppTheme.primaryColor)

                        if let area = property.areaSqm {
                            Text("📏 \(area.toArea())")
                        }

                        if let rooms = property.rooms {
                            Text("🛏️ \(rooms) otaq")
                        }

                        if let metro = property.nearestMetro {
                            Text("🚇 \(metro)")
                                .foregroundColor(AppTheme.primaryColor)
                        }

                        if !customMessage.isEmpty {
                            Divider()
                            Text("📝 \(customMessage)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("WhatsApp ilə Paylaş")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Bağla") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        sendToWhatsApp()
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(phoneNumber.isEmpty ? .gray : AppTheme.primaryColor)
                        }
                    }
                    .disabled(phoneNumber.isEmpty || isLoading)
                }
            }
        }
    }

    private func sendToWhatsApp() {
        guard !phoneNumber.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await WhatsAppService.shared.sendPropertyToClient(
                    propertyId: property.id,
                    clientPhone: phoneNumber,
                    customMessage: customMessage.isEmpty ? nil : customMessage
                )

                whatsappLink = response.whatsappLink

                // Open WhatsApp
                await MainActor.run {
                    WhatsAppService.shared.openWhatsApp(url: response.whatsappLink)

                    // Close sheet after 1 second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dismiss()
                    }
                }

            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    WhatsAppShareSheet(property: Property(
        id: "1",
        title: "3 otaqlı mənzil",
        description: "Test",
        propertyType: .apartment,
        dealType: .sale,
        status: .available,
        price: 150000,
        areaSqm: 85,
        address: "Nəsimi rayonu",
        city: "Bakı",
        district: "Nəsimi",
        rooms: 3,
        bathrooms: 2,
        floor: 5,
        latitude: 40.4093,
        longitude: 49.8671,
        nearestMetro: "28 May",
        metroDistanceM: 350,
        nearbyLandmarks: nil,
        createdAt: Date(),
        updatedAt: Date()
    ))
}
