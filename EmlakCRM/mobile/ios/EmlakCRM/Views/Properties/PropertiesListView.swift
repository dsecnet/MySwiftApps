import SwiftUI

struct PropertiesListView: View {
    @StateObject private var viewModel = PropertiesViewModel()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var searchText = ""
    @State private var showAddProperty = false
    @State private var showMapView = false
    @State private var filterPropertyType: PropertyType? = nil
    @State private var filterDealType: DealType? = nil
    @State private var filterStatus: PropertyStatus? = nil

    var filteredProperties: [Property] {
        var filtered = viewModel.properties

        // Apply type filters
        if let propertyType = filterPropertyType {
            filtered = filtered.filter { $0.propertyType == propertyType }
        }

        if let dealType = filterDealType {
            filtered = filtered.filter { $0.dealType == dealType }
        }

        if let status = filterStatus {
            filtered = filtered.filter { $0.status == status }
        }

        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.address?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.city.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Network Status Bar
                    NetworkStatusBar()

                    // Stats Header
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            PropertyStatCard(
                                title: "Toplam",
                                value: "\(viewModel.properties.count)",
                                icon: "building.2.fill",
                                color: AppTheme.primaryColor
                            )

                            PropertyStatCard(
                                title: "Satılıq",
                                value: "\(viewModel.properties.filter { $0.dealType == .sale }.count)",
                                icon: "cart.fill",
                                color: AppTheme.successColor
                            )

                            PropertyStatCard(
                                title: "Kirayə",
                                value: "\(viewModel.properties.filter { $0.dealType == .rent }.count)",
                                icon: "key.fill",
                                color: AppTheme.secondaryColor
                            )
                        }
                        .padding()
                    }

                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterPill(title: "Hamısı", isSelected: filterPropertyType == nil && filterDealType == nil && filterStatus == nil) {
                                filterPropertyType = nil
                                filterDealType = nil
                                filterStatus = nil
                            }

                            ForEach(PropertyType.allCases, id: \.self) { type in
                                FilterPill(
                                    title: type.displayName,
                                    icon: iconForPropertyType(type),
                                    isSelected: filterPropertyType == type
                                ) {
                                    filterPropertyType = (filterPropertyType == type) ? nil : type
                                }
                            }

                            Divider()
                                .frame(height: 24)

                            FilterPill(
                                title: "Satılıq",
                                icon: "cart.fill",
                                isSelected: filterDealType == .sale
                            ) {
                                filterDealType = (filterDealType == .sale) ? nil : .sale
                            }

                            FilterPill(
                                title: "Kirayə",
                                icon: "key.fill",
                                isSelected: filterDealType == .rent
                            ) {
                                filterDealType = (filterDealType == .rent) ? nil : .rent
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(AppTheme.cardBackground)

                    if viewModel.isLoading && viewModel.properties.isEmpty {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredProperties.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "building.2.fill",
                            title: "Əmlak yoxdur",
                            message: "Yeni əmlak əlavə edin"
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredProperties) { property in
                                    NavigationLink(destination: PropertyDetailView(property: property)) {
                                        PropertyRowView(property: property)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Task {
                                                await deleteProperty(property)
                                            }
                                        } label: {
                                            Label("Sil", systemImage: "trash")
                                        }
                                    }
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
            }
            .navigationTitle("Əmlaklar")
            .searchable(text: $searchText, prompt: "Axtar...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showMapView = true
                    } label: {
                        Image(systemName: "map.fill")
                            .foregroundColor(AppTheme.primaryColor)
                            .font(.title3)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddProperty = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.primaryGradient)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddProperty) {
                AddPropertyView {
                    await viewModel.refresh()
                }
            }
            .fullScreenCover(isPresented: $showMapView) {
                PropertiesMapView()
            }
            .task {
                await viewModel.loadProperties()
            }
        }
    }

    private func deleteProperty(_ property: Property) async {
        do {
            try await APIService.shared.deleteProperty(id: property.id)
            await viewModel.refresh()
        } catch {
            print("Error deleting property: \(error)")
        }
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

struct PropertyRowView: View {
    let property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder with gradient
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(AppTheme.primaryGradient)
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: iconForPropertyType(property.propertyType))
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.3))
                    )

                // Status badge
                StatusBadge(status: property.status)
                    .padding(12)
            }

            VStack(alignment: .leading, spacing: 12) {
                // Title and Price
                HStack(alignment: .top) {
                    Text(property.title)
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(2)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(property.price.toCurrency())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.primaryColor)

                        if let area = property.areaSqm {
                            Text("\(Int(property.price / area)) ₼/m²")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }

                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)

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
                }

                Divider()

                // Details Row
                HStack(spacing: 16) {
                    // Deal Type
                    HStack(spacing: 4) {
                        Image(systemName: property.dealType == .sale ? "cart.fill" : "key.fill")
                            .font(.caption)
                            .foregroundColor(AppTheme.primaryColor)
                        Text(property.dealType.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    if let area = property.areaSqm {
                        HStack(spacing: 4) {
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(area.toArea())
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }

                    if let rooms = property.rooms {
                        HStack(spacing: 4) {
                            Image(systemName: "bed.double.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("\(rooms)")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }

                    Spacer()

                    // Time ago
                    Text(property.createdAt.timeAgo())
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                }
            }
            .padding()
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
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

struct StatusBadge: View {
    let status: PropertyStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(colorForStatus(status))
            .cornerRadius(12)
    }

    private func colorForStatus(_ status: PropertyStatus) -> Color {
        switch status {
        case .available: return AppTheme.successColor
        case .reserved: return AppTheme.warningColor
        case .sold: return AppTheme.errorColor
        case .rented: return AppTheme.secondaryColor
        case .archived: return AppTheme.textSecondary
        }
    }
}

struct PropertyStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(title)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
    }
}

#Preview {
    PropertiesListView()
}
