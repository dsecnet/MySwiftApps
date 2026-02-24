//
//  CreateProductView.swift
//  CoreVia
//
//  Mehsul yaratma formu — movcut CreateContentSheet dizayn uslubu ile
//

import SwiftUI

struct CreateProductView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var title = ""
    @State private var description = ""
    @State private var productType = "workout_plan"
    @State private var price: Double = 1.0
    @State private var currency = "AZN"
    @State private var isPublished = true

    @State private var isCreating = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    let productTypes = ["workout_plan", "meal_plan", "training_program", "ebook", "video_course"]
    let currencies = ["AZN", "USD", "EUR", "TRY"]

    /// Form validation — backend tələbləri: title>=3, description>=10, price>0
    private var isFormValid: Bool {
        title.count >= 3 && description.count >= 10 && price > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Product Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("product_type"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(productTypes, id: \.self) { type in
                                        FilterChip(
                                            title: loc.localized("marketplace_\(type)"),
                                            isSelected: productType == type
                                        ) {
                                            productType = type
                                        }
                                    }
                                }
                            }
                        }

                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(loc.localized("content_field_title"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Spacer()
                                if !title.isEmpty && title.count < 3 {
                                    Text("Min 3 simvol")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.Colors.error)
                                }
                            }

                            TextField(loc.localized("product_title_placeholder"), text: $title)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(AppTheme.CornerRadius.md)
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(loc.localized("product_description"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Spacer()
                                if !description.isEmpty && description.count < 10 {
                                    Text("Min 10 simvol")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.Colors.error)
                                }
                            }

                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(8)
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(AppTheme.CornerRadius.md)
                                .foregroundColor(AppTheme.Colors.primaryText)
                        }

                        // Price & Currency
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(loc.localized("product_price"))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                    Spacer()
                                    if price <= 0 {
                                        Text("0-dan böyük olmalı")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppTheme.Colors.error)
                                    }
                                }

                                TextField("1.00", value: $price, format: .number)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(AppTheme.Colors.secondaryBackground)
                                    .cornerRadius(AppTheme.CornerRadius.md)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text(loc.localized("product_currency"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                Picker("", selection: $currency) {
                                    ForEach(currencies, id: \.self) { cur in
                                        Text(cur).tag(cur)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(AppTheme.Colors.accent)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(AppTheme.CornerRadius.md)
                            }
                            .frame(width: 100)
                        }

                        // Active Toggle
                        Toggle(isOn: $isPublished) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.Colors.success)
                                Text(loc.localized("product_is_active"))
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                            }
                        }
                        .tint(AppTheme.Colors.accent)
                        .padding()
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(AppTheme.CornerRadius.md)

                        // Error
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.error)
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 20)

                        // Submit
                        Button {
                            Task { await createProduct() }
                        } label: {
                            HStack {
                                if isCreating {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                    Text(loc.localized("trainer_hub_create_product"))
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? AppTheme.Colors.accent : AppTheme.Colors.separator)
                            .cornerRadius(AppTheme.CornerRadius.md)
                        }
                        .disabled(!isFormValid || isCreating)
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("trainer_hub_create_product"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) { dismiss() }
                }
            }
            .alert(loc.localized("common_success"), isPresented: $showSuccess) {
                Button(loc.localized("common_ok")) { dismiss() }
            }
        }
    }

    // MARK: - Create Product API

    private func createProduct() async {
        isCreating = true
        errorMessage = nil

        do {
            let request = CreateProductRequest(
                productType: productType,
                title: title,
                description: description,
                price: price,
                currency: currency,
                isPublished: isPublished
            )

            let _: MarketplaceProduct = try await APIService.shared.request(
                endpoint: "/api/v1/marketplace/products",
                method: "POST",
                body: request
            )

            isCreating = false
            showSuccess = true

        } catch {
            isCreating = false
            errorMessage = error.localizedDescription
        }
    }
}
