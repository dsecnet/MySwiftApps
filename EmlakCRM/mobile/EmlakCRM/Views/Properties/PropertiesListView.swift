//
//  PropertiesListView.swift
//  EmlakCRM
//
//  Properties List Screen
//

import SwiftUI

struct PropertiesListView: View {
    @StateObject private var viewModel = PropertiesViewModel()
    @State private var showAddProperty = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                if viewModel.isLoading && viewModel.properties.isEmpty {
                    ProgressView()
                } else if viewModel.properties.isEmpty {
                    emptyStateView
                } else {
                    propertiesList
                }
            }
            .navigationTitle("Əmlaklar")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Əmlak axtar...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddProperty = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showAddProperty) {
                AddPropertyView()
            }
        }
        .task {
            await viewModel.loadProperties()
        }
    }

    private var propertiesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredProperties) { property in
                    NavigationLink(destination: PropertyDetailView(property: property)) {
                        PropertyRowView(property: property)
                    }
                    .buttonStyle(.plain)
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

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textSecondary)

            Text("Əmlak yoxdur")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)

            Text("Yeni əmlak əlavə etmək üçün + düyməsinə toxunun")
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showAddProperty = true
            } label: {
                Text("Əmlak əlavə et")
            }
            .primaryButtonStyle()
            .padding(.horizontal, 40)
        }
    }

    private var filteredProperties: [Property] {
        if searchText.isEmpty {
            return viewModel.properties
        }
        return viewModel.properties.filter { property in
            property.title.localizedCaseInsensitiveContains(searchText) ||
            property.address.localizedCaseInsensitiveContains(searchText) ||
            property.propertyType.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Property Row View

struct PropertyRowView: View {
    let property: Property

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

    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.primaryColor.opacity(0.1))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: typeIcon)
                        .font(.system(size: 32))
                        .foregroundColor(AppTheme.primaryColor)
                )

            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(property.title)
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                // Type & Status
                HStack(spacing: 8) {
                    Text(propertyTypeText)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)

                    Circle()
                        .fill(AppTheme.textSecondary)
                        .frame(width: 3, height: 3)

                    Text(statusText)
                        .font(AppTheme.caption())
                        .foregroundColor(statusColor)
                }

                // Address
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)

                    Text(property.address)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }

                // Price
                Text("\(String(format: "%.0f", property.price)) ₼")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.primaryColor)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .cardStyle()
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
}

// MARK: - Properties ViewModel

@MainActor
class PropertiesViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMore = true

    private let apiService = APIService.shared
    private let pageSize = 20

    func loadProperties() async {
        guard !isLoading else { return }
        isLoading = true
        currentPage = 1

        do {
            let response = try await apiService.getProperties(page: currentPage, limit: pageSize)
            properties = response.items
            hasMore = response.items.count == pageSize
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadMore() async {
        guard !isLoading && hasMore else { return }
        isLoading = true
        currentPage += 1

        do {
            let response = try await apiService.getProperties(page: currentPage, limit: pageSize)
            properties.append(contentsOf: response.items)
            hasMore = response.items.count == pageSize
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            currentPage -= 1
        }
    }

    func refresh() async {
        await loadProperties()
    }
}

#Preview {
    PropertiesListView()
}
