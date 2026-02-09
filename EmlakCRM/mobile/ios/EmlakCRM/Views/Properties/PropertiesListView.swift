import SwiftUI

struct PropertiesListView: View {
    @StateObject private var viewModel = PropertiesViewModel()
    @State private var searchText = ""
    @State private var showAddProperty = false

    var filteredProperties: [Property] {
        if searchText.isEmpty {
            return viewModel.properties
        }
        return viewModel.properties.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                if viewModel.isLoading && viewModel.properties.isEmpty {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredProperties) { property in
                                NavigationLink(destination: PropertyDetailView(property: property)) {
                                    PropertyRowView(property: property)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            if viewModel.hasMore {
                                ProgressView()
                                    .padding()
                                    .task {
                                        await viewModel.loadMore()
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Əmlaklar")
            .searchable(text: $searchText, prompt: "Axtar...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddProperty = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddProperty) {
                AddPropertyView {
                    await viewModel.refresh()
                }
            }
            .task {
                await viewModel.loadProperties()
            }
        }
    }
}

struct PropertyRowView: View {
    let property: Property

    var body: some View {
        HStack(spacing: 12) {
            // Property Type Icon
            Image(systemName: iconForPropertyType(property.propertyType))
                .font(.title2)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 50, height: 50)
                .background(AppTheme.primaryColor.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                Text(property.title)
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)

                if let address = property.address {
                    Text("\(address), \(property.city)")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                } else {
                    Text(property.city)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    StatusBadge(status: property.status)

                    Text(property.dealType.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.primaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.primaryColor.opacity(0.1))
                        .cornerRadius(6)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatPrice(property.price))
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.primaryColor)

                if let area = property.areaSqm {
                    Text("\(Int(area)) m²")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    private func iconForPropertyType(_ type: PropertyType) -> String {
        switch type {
        case .apartment: return "building.2.fill"
        case .house: return "house.fill"
        case .villa: return "house.fill"
        case .office: return "building.fill"
        case .land: return "map.fill"
        case .commercial: return "building.columns.fill"
        }
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price)) ₼"
    }
}

struct StatusBadge: View {
    let status: PropertyStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(colorForStatus(status))
            .cornerRadius(6)
    }

    private func colorForStatus(_ status: PropertyStatus) -> Color {
        switch status {
        case .active: return AppTheme.successColor
        case .pending: return AppTheme.warningColor
        case .sold: return AppTheme.errorColor
        case .rented: return AppTheme.secondaryColor
        }
    }
}

#Preview {
    PropertiesListView()
}
