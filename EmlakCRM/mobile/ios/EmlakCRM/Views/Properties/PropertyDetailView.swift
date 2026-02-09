import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Price Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Qiymət")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)

                    Text(formatPrice(property.price))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)

                    HStack {
                        StatusBadge(status: property.status)

                        if let listingType = property.listingType {
                            Text(listingType.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.primaryColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppTheme.primaryColor.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                // Main Info
                VStack(alignment: .leading, spacing: 16) {
                    Text(property.title)
                        .font(AppTheme.title())
                        .foregroundColor(AppTheme.textPrimary)

                    HStack(spacing: 16) {
                        InfoItem(icon: "square.fill", label: "\(Int(property.area)) m²")

                        if let bedrooms = property.bedrooms {
                            InfoItem(icon: "bed.double.fill", label: "\(bedrooms)")
                        }

                        if let bathrooms = property.bathrooms {
                            InfoItem(icon: "shower.fill", label: "\(bathrooms)")
                        }

                        if let floor = property.floor {
                            InfoItem(icon: "building.fill", label: "\(floor)")
                        }
                    }
                }
                .padding()
                .cardStyle()

                // Description
                if let description = property.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Təsvir")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)

                        Text(description)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .cardStyle()
                }

                // Location
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ünvan")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(AppTheme.primaryColor)

                        Text("\(property.address), \(property.city)")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding()
                .cardStyle()

                // Property Type
                VStack(alignment: .leading, spacing: 12) {
                    Text("Əmlak növü")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    Text(property.propertyType.displayName)
                        .font(AppTheme.body())
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .cardStyle()

                // Dates
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tarixlər")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Yaradılma:")
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(property.createdAt))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        HStack {
                            Text("Yenilənmə:")
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(property.updatedAt))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .font(AppTheme.body())
                }
                .padding()
                .cardStyle()
            }
            .padding()
        }
        .background(AppTheme.backgroundColor)
        .navigationTitle("Əmlak Detalları")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price)) ₼"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct InfoItem: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(AppTheme.primaryColor)

            Text(label)
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.primaryColor.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        PropertyDetailView(property: Property(
            id: "1",
            title: "Nümunə Mənzil",
            description: "Gözəl mənzil",
            propertyType: .apartment,
            listingType: .sale,
            status: .active,
            price: 150000,
            area: 85,
            address: "Nizami küçəsi 123",
            city: "Bakı",
            bedrooms: 3,
            bathrooms: 2,
            floor: 5,
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
