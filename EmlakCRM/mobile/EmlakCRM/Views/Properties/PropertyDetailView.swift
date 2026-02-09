//
//  PropertyDetailView.swift
//  EmlakCRM
//
//  Property Detail Screen
//

import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Images Gallery
                imageGallery

                // Main Info
                VStack(alignment: .leading, spacing: 16) {
                    // Title & Status
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(property.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text(propertyTypeText)
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        Spacer()

                        statusBadge
                    }

                    // Price
                    HStack {
                        Text("\(String(format: "%.0f", property.price)) ₼")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.primaryColor)

                        if let listingType = property.listingType {
                            Text(listingType == .sale ? "/ Satış" : "/ İcarə")
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }

                    Divider()

                    // Address
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppTheme.primaryColor)

                        Text(property.address)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .padding()
                .cardStyle()

                // Property Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Təfərrüatlar")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        DetailItem(
                            icon: "square.split.2x2",
                            label: "Sahə",
                            value: "\(String(format: "%.0f", property.area)) m²"
                        )

                        DetailItem(
                            icon: "bed.double",
                            label: "Otaqlar",
                            value: "\(property.bedrooms ?? 0)"
                        )

                        DetailItem(
                            icon: "shower",
                            label: "Vanna",
                            value: "\(property.bathrooms ?? 0)"
                        )

                        DetailItem(
                            icon: "building.2",
                            label: "Mərtəbə",
                            value: property.floor.map { "\($0)" } ?? "-"
                        )
                    }
                }
                .padding()
                .cardStyle()

                // Description
                if let description = property.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Açıqlama")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)

                        Text(description)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .cardStyle()
                }

                // Features
                if let features = property.features, !features.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Xüsusiyyətlər")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(features, id: \.self) { feature in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.successColor)
                                        .font(.system(size: 14))

                                    Text(feature)
                                        .font(AppTheme.caption())
                                        .foregroundColor(AppTheme.textPrimary)

                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .cardStyle()
                }

                // Owner Info
                if let owner = property.owner {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Əlaqə")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)

                        HStack(spacing: 12) {
                            Circle()
                                .fill(AppTheme.primaryColor.opacity(0.15))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(owner.name.prefix(1).uppercased())
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryColor)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(owner.name)
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)

                                if let phone = owner.phone {
                                    Text(phone)
                                        .font(AppTheme.caption())
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }

                            Spacer()

                            if let phone = owner.phone {
                                Link(destination: URL(string: "tel:\(phone)")!) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(AppTheme.successColor)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding()
                    .cardStyle()
                }

                // Timestamps
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Əlavə olundu:")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)

                        Text(formatDate(property.createdAt))
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    HStack {
                        Text("Yeniləndi:")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)

                        Text(formatDate(property.updatedAt))
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        // Edit property
                    } label: {
                        Label("Redaktə et", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        // Delete property
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AppTheme.primaryColor)
                }
            }
        }
    }

    private var imageGallery: some View {
        TabView {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 0)
                    .fill(AppTheme.primaryColor.opacity(0.1))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: typeIcon)
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.primaryColor)
                    )
            }
        }
        .frame(height: 300)
        .tabViewStyle(.page)
    }

    private var statusBadge: some View {
        Text(statusText)
            .font(AppTheme.caption())
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor)
            .cornerRadius(8)
    }

    private var statusColor: Color {
        switch property.status {
        case .active: return AppTheme.successColor
        case .pending: return AppTheme.warningColor
        case .sold: return AppTheme.errorColor
        case .rented: return AppTheme.primaryColor
        }
    }

    private var statusText: String {
        switch property.status {
        case .active: return "Aktiv"
        case .pending: return "Gözləmədə"
        case .sold: return "Satıldı"
        case .rented: return "İcarəyə verildi"
        }
    }

    private var typeIcon: String {
        switch property.propertyType {
        case .apartment: return "building.2"
        case .house: return "house"
        case .villa: return "house.lodge"
        case .office: return "building"
        case .land: return "leaf"
        case .commercial: return "cart"
        }
    }

    private var propertyTypeText: String {
        switch property.propertyType {
        case .apartment: return "Mənzil"
        case .house: return "Ev"
        case .villa: return "Villa"
        case .office: return "Ofis"
        case .land: return "Torpaq"
        case .commercial: return "Kommersiya"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Detail Item

struct DetailItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)

                Text(value)
                    .font(AppTheme.body())
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        PropertyDetailView(property: Property(
            id: "1",
            title: "Nəsimi rayonu, Azadlıq prospekti",
            description: "Yaşayış kompleksində 3 otaqlı təmirli mənzil",
            propertyType: .apartment,
            listingType: .sale,
            status: .active,
            price: 150000,
            area: 120,
            address: "Nəsimi r-nu, Azadlıq prospekti 23",
            city: "Bakı",
            bedrooms: 3,
            bathrooms: 2,
            floor: 5,
            totalFloors: 12,
            yearBuilt: 2020,
            features: ["Təmirli", "Lift", "Mebel", "Parkinq"],
            images: [],
            owner: Client(
                id: "1",
                name: "Vüsal Dadaşov",
                email: "vusal@emlak.az",
                phone: "+994501234567",
                clientType: .buyer,
                source: .referral,
                status: .active,
                notes: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            createdBy: "1",
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
