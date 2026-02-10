import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @Environment(\.dismiss) var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var showShareSheet = false
    @State private var showWhatsAppSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero Image/Header
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(AppTheme.primaryGradient)
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: iconForPropertyType(property.propertyType))
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.3))
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        StatusBadge(status: property.status)

                        Text(formatPrice(property.price))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding()
                }

                // Title and Type
                VStack(alignment: .leading, spacing: 12) {
                    Text(property.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: property.dealType == .sale ? "cart.fill" : "key.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.primaryColor)
                            Text(property.dealType.displayName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.primaryColor)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryColor.opacity(0.15))
                        .cornerRadius(10)

                        HStack(spacing: 6) {
                            Image(systemName: iconForPropertyType(property.propertyType))
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(property.propertyType.displayName)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)

                // Property Features Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    if let area = property.areaSqm {
                        PropertyFeatureCard(icon: "square.grid.3x3.fill", label: "Sahə", value: "\(Int(area)) m²")
                    }

                    if let rooms = property.rooms {
                        PropertyFeatureCard(icon: "bed.double.fill", label: "Otaq", value: "\(rooms)")
                    }

                    if let bathrooms = property.bathrooms {
                        PropertyFeatureCard(icon: "shower.fill", label: "Hamam", value: "\(bathrooms)")
                    }

                    if let floor = property.floor {
                        PropertyFeatureCard(icon: "building.fill", label: "Mərtəbə", value: "\(floor)")
                    }
                }
                .padding(.horizontal)

                // Location
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(AppTheme.primaryColor)
                        Text("Ünvan")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
                        if let address = property.address {
                            Text("\(address), \(property.city)")
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                        } else {
                            Text(property.city)
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)

                // Description
                if let description = property.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(AppTheme.primaryColor)
                            Text("Təsvir")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Text(description)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
                }

                // Dates
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .foregroundColor(AppTheme.primaryColor)
                        Text("Tarixlər")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(spacing: 10) {
                        HStack {
                            Text("Yaradılma:")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(property.createdAt))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Divider()

                        HStack {
                            Text("Yenilənmə:")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(formatDate(property.updatedAt))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
            }
            .padding()
        }
        .background(AppTheme.backgroundGradient)
        .navigationTitle("Əmlak Detalları")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showWhatsAppSheet = true
                    } label: {
                        Label("WhatsApp ilə paylaş", systemImage: "message.fill")
                    }

                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Paylaş", systemImage: "square.and.arrow.up")
                    }

                    Divider()

                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Redaktə et", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.primaryColor)
                }
            }
        }
        .shareSheet(isPresented: $showShareSheet, items: [ShareHelper.shareProperty(property)])
        .sheet(isPresented: $showWhatsAppSheet) {
            WhatsAppShareSheet(property: property)
        }
        .alert("Əmlakı silmək istədiyinizdən əminsiniz?", isPresented: $showDeleteAlert) {
            Button("Ləğv et", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task {
                    await deleteProperty()
                }
            }
        } message: {
            Text("Bu əməliyyat geri qaytarıla bilməz.")
        }
    }

    private func deleteProperty() async {
        isDeleting = true
        do {
            try await APIService.shared.deleteProperty(id: property.id)
            dismiss()
        } catch {
            print("Error deleting property: \(error)")
        }
        isDeleting = false
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

    private func iconForPropertyType(_ type: PropertyType) -> String {
        switch type {
        case .apartment: return "building.2.fill"
        case .house: return "house.fill"
        case .office: return "building.fill"
        case .land: return "map.fill"
        case .commercial: return "building.columns.fill"
        }
    }
}

struct PropertyFeatureCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 44, height: 44)
                .background(AppTheme.primaryColor.opacity(0.15))
                .cornerRadius(12)

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
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
            dealType: .sale,
            status: .available,
            price: 150000,
            areaSqm: 85,
            address: "Nizami küçəsi 123",
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
}
