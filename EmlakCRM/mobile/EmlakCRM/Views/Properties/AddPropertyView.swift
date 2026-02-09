//
//  AddPropertyView.swift
//  EmlakCRM
//
//  Add New Property Screen
//

import SwiftUI

struct AddPropertyView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddPropertyViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Image Picker Placeholder
                        imageSection

                        // Basic Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Əsas Məlumat")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            // Title
                            FormField(label: "Başlıq") {
                                TextField("Məsələn: 3 otaqlı mənzil", text: $viewModel.title)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }

                            // Property Type
                            FormField(label: "Əmlak növü") {
                                Menu {
                                    ForEach(PropertyType.allCases, id: \.self) { type in
                                        Button {
                                            viewModel.propertyType = type
                                        } label: {
                                            Text(propertyTypeText(type))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(propertyTypeText(viewModel.propertyType))
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

                            // Listing Type
                            FormField(label: "Elan növü") {
                                HStack(spacing: 12) {
                                    ToggleButton(
                                        title: "Satış",
                                        isSelected: viewModel.listingType == .sale
                                    ) {
                                        viewModel.listingType = .sale
                                    }

                                    ToggleButton(
                                        title: "İcarə",
                                        isSelected: viewModel.listingType == .rent
                                    ) {
                                        viewModel.listingType = .rent
                                    }
                                }
                            }

                            // Price
                            FormField(label: "Qiymət (₼)") {
                                TextField("0", value: $viewModel.price, format: .number)
                                    .textFieldStyle(.plain)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Location
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ünvan")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            FormField(label: "Şəhər") {
                                TextField("Bakı", text: $viewModel.city)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }

                            FormField(label: "Tam ünvan") {
                                TextField("Nəsimi r-nu, Azadlıq pr. 23", text: $viewModel.address)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Property Details
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Təfərrüatlar")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            HStack(spacing: 12) {
                                FormField(label: "Sahə (m²)") {
                                    TextField("0", value: $viewModel.area, format: .number)
                                        .textFieldStyle(.plain)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(AppTheme.cornerRadius)
                                }

                                FormField(label: "Otaq") {
                                    TextField("0", value: $viewModel.bedrooms, format: .number)
                                        .textFieldStyle(.plain)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(AppTheme.cornerRadius)
                                }
                            }

                            HStack(spacing: 12) {
                                FormField(label: "Vanna") {
                                    TextField("0", value: $viewModel.bathrooms, format: .number)
                                        .textFieldStyle(.plain)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(AppTheme.cornerRadius)
                                }

                                FormField(label: "Mərtəbə") {
                                    TextField("0", value: $viewModel.floor, format: .number)
                                        .textFieldStyle(.plain)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(AppTheme.cornerRadius)
                                }
                            }
                        }
                        .padding()
                        .cardStyle()

                        // Description
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Açıqlama")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)

                            TextEditor(text: $viewModel.description)
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
                                let success = await viewModel.saveProperty()
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
            .navigationTitle("Yeni Əmlak")
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

    private var imageSection: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.primaryColor.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.primaryColor)

                        Text("Şəkil əlavə et")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.primaryColor)
                    }
                )
                .padding()
        }
    }

    private func propertyTypeText(_ type: PropertyType) -> String {
        switch type {
        case .apartment: return "Mənzil"
        case .house: return "Ev"
        case .villa: return "Villa"
        case .office: return "Ofis"
        case .land: return "Torpaq"
        case .commercial: return "Kommersiya"
        }
    }
}

// MARK: - Form Field

struct FormField<Content: View>: View {
    let label: String
    let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)

            content
        }
    }
}

// MARK: - Toggle Button

struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.body())
                .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? AppTheme.primaryColor : AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
        }
    }
}

// MARK: - Add Property ViewModel

@MainActor
class AddPropertyViewModel: ObservableObject {
    @Published var title = ""
    @Published var propertyType: PropertyType = .apartment
    @Published var listingType: ListingType = .sale
    @Published var price: Double = 0
    @Published var city = "Bakı"
    @Published var address = ""
    @Published var area: Double = 0
    @Published var bedrooms: Int = 0
    @Published var bathrooms: Int = 0
    @Published var floor: Int = 0
    @Published var description = ""

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    var isValid: Bool {
        !title.isEmpty && !address.isEmpty && price > 0 && area > 0
    }

    func saveProperty() async -> Bool {
        guard isValid else { return false }

        isLoading = true
        errorMessage = nil

        do {
            let propertyData = PropertyCreate(
                title: title,
                description: description.isEmpty ? nil : description,
                propertyType: propertyType,
                listingType: listingType,
                status: .active,
                price: price,
                area: area,
                address: address,
                city: city,
                bedrooms: bedrooms > 0 ? bedrooms : nil,
                bathrooms: bathrooms > 0 ? bathrooms : nil,
                floor: floor > 0 ? floor : nil,
                totalFloors: nil,
                yearBuilt: nil,
                features: nil,
                images: nil,
                ownerId: nil
            )

            _ = try await apiService.createProperty(propertyData)
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
    AddPropertyView()
}
