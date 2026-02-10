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
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header Icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: AppTheme.primaryColor.opacity(0.4), radius: 20, x: 0, y: 10)

                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }

                            Text("Yeni Əmlak")
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
                                ModernTextField(icon: "tag.fill", placeholder: "Başlıq *", text: $title)

                                ModernTextField(icon: "text.alignleft", placeholder: "Təsvir", text: $description, axis: .vertical, lineLimit: 3...6)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Əmlak növü")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)

                                Picker("Əmlak növü", selection: $propertyType) {
                                    ForEach(PropertyType.allCases, id: \.self) { type in
                                        Text(type.displayName).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sövdələşmə növü")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)

                                Picker("Sövdələşmə növü", selection: $dealType) {
                                    ForEach([DealType.sale, DealType.rent], id: \.self) { type in
                                        Text(type.displayName).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Status")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)

                                Picker("Status", selection: $status) {
                                    ForEach([PropertyStatus.available, PropertyStatus.reserved], id: \.self) { s in
                                        Text(s.displayName).tag(s)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)

                        // Price & Area
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(AppTheme.successColor)
                                Text("Qiymət və Sahə")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            VStack(spacing: 12) {
                                ModernTextField(icon: "manat.sign.circle.fill", placeholder: "Qiymət (₼) *", text: $price, keyboardType: .decimalPad)

                                ModernTextField(icon: "square.fill", placeholder: "Sahə (m²) *", text: $area, keyboardType: .decimalPad)
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)

                        // Location
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.circle.fill")
                                    .foregroundColor(AppTheme.infoColor)
                                Text("Ünvan")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            VStack(spacing: 12) {
                                ModernTextField(icon: "map.fill", placeholder: "Ünvan *", text: $address)

                                ModernTextField(icon: "building.2.fill", placeholder: "Şəhər *", text: $city)
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)

                        // Additional Info
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "list.bullet.circle.fill")
                                    .foregroundColor(AppTheme.accentColor)
                                Text("Əlavə Məlumat")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            VStack(spacing: 12) {
                                ModernTextField(icon: "door.left.hand.open", placeholder: "Otaq sayı", text: $rooms, keyboardType: .numberPad)

                                ModernTextField(icon: "shower.fill", placeholder: "Vanna otağı sayı", text: $bathrooms, keyboardType: .numberPad)

                                ModernTextField(icon: "building.columns.fill", placeholder: "Mərtəbə", text: $floor, keyboardType: .numberPad)
                            }
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
                                await createProperty()
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
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(12)
                            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
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

struct ModernTextField: View {
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
                    .textContentType(.none)
                    .lineLimit(lineLimit ?? 1...10)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(.none)
            }
        }
        .padding()
        .background(AppTheme.backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    AddPropertyView {
        print("Property created")
    }
}
