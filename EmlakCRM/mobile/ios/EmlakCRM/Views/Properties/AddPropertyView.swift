import SwiftUI

struct AddPropertyView: View {
    @Environment(\.dismiss) var dismiss
    let onSuccess: () async -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var propertyType: PropertyType = .apartment
    @State private var dealType: DealType = .sale
    @State private var status: PropertyStatus = .available
    @State private var price = ""
    @State private var area = ""
    @State private var address = ""
    @State private var city = "Bakı"
    @State private var rooms = ""
    @State private var bathrooms = ""
    @State private var floor = ""

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

                            TextField("Başlıq", text: $title)
                                .textFieldStyle(.roundedBorder)

                            TextField("Təsvir", text: $description, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)

                            Picker("Əmlak növü", selection: $propertyType) {
                                ForEach(PropertyType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)

                            Picker("Sövdələşmə növü", selection: $dealType) {
                                ForEach([DealType.sale, DealType.rent], id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)

                            Picker("Status", selection: $status) {
                                ForEach([PropertyStatus.available, PropertyStatus.reserved], id: \.self) { s in
                                    Text(s.displayName).tag(s)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .cardStyle()

                        // Price & Area
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Qiymət və Sahə")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Qiymət (₼)", text: $price)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)

                            TextField("Sahə (m²)", text: $area)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        .padding()
                        .cardStyle()

                        // Location
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ünvan")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Ünvan", text: $address)
                                .textFieldStyle(.roundedBorder)

                            TextField("Şəhər", text: $city)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding()
                        .cardStyle()

                        // Additional Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Əlavə Məlumat (İstəyə görə)")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Otaq sayı", text: $rooms)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)

                            TextField("Vanna otağı sayı", text: $bathrooms)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)

                            TextField("Mərtəbə", text: $floor)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
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
                                await createProperty()
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
            .navigationTitle("Yeni Əmlak")
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
        !title.isEmpty &&
        !price.isEmpty &&
        !area.isEmpty &&
        !address.isEmpty &&
        !city.isEmpty
    }

    private func createProperty() async {
        isLoading = true
        errorMessage = nil

        guard let priceValue = Double(price),
              let areaValue = Double(area) else {
            errorMessage = "Qiymət və sahə düzgün daxil edilməlidir"
            isLoading = false
            return
        }

        let property = PropertyCreate(
            title: title,
            description: description.isEmpty ? nil : description,
            propertyType: propertyType,
            dealType: dealType,
            status: status,
            price: priceValue,
            areaSqm: areaValue,
            address: address.isEmpty ? nil : address,
            city: city,
            rooms: Int(rooms),
            bathrooms: Int(bathrooms),
            floor: Int(floor)
        )

        do {
            _ = try await APIService.shared.createProperty(property)
            await onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    AddPropertyView {
        print("Property created")
    }
}
