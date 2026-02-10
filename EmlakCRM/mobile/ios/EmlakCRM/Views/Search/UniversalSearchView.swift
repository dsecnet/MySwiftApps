import SwiftUI

struct UniversalSearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedScope: SearchScope = .all
    @State private var isLoading = false

    @StateObject private var propertiesVM = PropertiesViewModel()
    @StateObject private var clientsVM = ClientsViewModel()
    @StateObject private var activitiesVM = ActivitiesViewModel()
    @StateObject private var dealsVM = DealsViewModel()

    enum SearchScope: String, CaseIterable {
        case all = "Hamısı"
        case properties = "Əmlaklar"
        case clients = "Müştərilər"
        case activities = "Fəaliyyətlər"
        case deals = "Sövdələşmələr"
    }

    var filteredProperties: [Property] {
        guard !searchText.isEmpty else { return [] }
        return propertiesVM.properties.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            ($0.address?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            $0.city.localizedCaseInsensitiveContains(searchText)
        }
    }

    var filteredClients: [Client] {
        guard !searchText.isEmpty else { return [] }
        return clientsVM.clients.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            ($0.phone?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var filteredActivities: [Activity] {
        guard !searchText.isEmpty else { return [] }
        return activitiesVM.activities.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var filteredDeals: [Deal] {
        guard !searchText.isEmpty else { return [] }
        return dealsVM.deals.filter {
            ($0.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var totalResults: Int {
        filteredProperties.count + filteredClients.count + filteredActivities.count + filteredDeals.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppTheme.textSecondary)

                            TextField("Axtar...", text: $searchText)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)

                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                    }
                    .padding()

                    // Scope picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(SearchScope.allCases, id: \.self) { scope in
                                Button {
                                    selectedScope = scope
                                    HapticFeedback.light.trigger()
                                } label: {
                                    Text(scope.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(selectedScope == scope ? .white : AppTheme.textPrimary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedScope == scope ?
                                            AppTheme.primaryGradient :
                                            LinearGradient(colors: [AppTheme.backgroundColor], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    .background(AppTheme.cardBackground)

                    // Results
                    if searchText.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.textSecondary.opacity(0.5))

                            Text("Axtarış üçün yazın")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Əmlak, müştəri, fəaliyyət və ya sövdələşmə axtar")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    } else if totalResults == 0 {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.textSecondary.opacity(0.5))

                            Text("Nəticə tapılmadı")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("'\(searchText)' üçün heç nə tapılmadı")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                // Properties
                                if (selectedScope == .all || selectedScope == .properties) && !filteredProperties.isEmpty {
                                    SearchSection(title: "Əmlaklar", icon: "building.2.fill", count: filteredProperties.count) {
                                        ForEach(filteredProperties.prefix(5)) { property in
                                            NavigationLink(destination: PropertyDetailView(property: property)) {
                                                SearchPropertyRow(property: property)
                                            }
                                        }
                                    }
                                }

                                // Clients
                                if (selectedScope == .all || selectedScope == .clients) && !filteredClients.isEmpty {
                                    SearchSection(title: "Müştərilər", icon: "person.2.fill", count: filteredClients.count) {
                                        ForEach(filteredClients.prefix(5)) { client in
                                            NavigationLink(destination: ClientDetailView(client: client)) {
                                                SearchClientRow(client: client)
                                            }
                                        }
                                    }
                                }

                                // Activities
                                if (selectedScope == .all || selectedScope == .activities) && !filteredActivities.isEmpty {
                                    SearchSection(title: "Fəaliyyətlər", icon: "calendar.badge.clock", count: filteredActivities.count) {
                                        ForEach(filteredActivities.prefix(5)) { activity in
                                            NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                                SearchActivityRow(activity: activity)
                                            }
                                        }
                                    }
                                }

                                // Deals
                                if (selectedScope == .all || selectedScope == .deals) && !filteredDeals.isEmpty {
                                    SearchSection(title: "Sövdələşmələr", icon: "briefcase.fill", count: filteredDeals.count) {
                                        ForEach(filteredDeals.prefix(5)) { deal in
                                            NavigationLink(destination: DealDetailView(deal: deal)) {
                                                SearchDealRow(deal: deal)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Axtarış")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .task {
                await loadData()
            }
        }
    }

    private func loadData() async {
        await propertiesVM.loadProperties()
        await clientsVM.loadClients()
        await activitiesVM.loadActivities()
        await dealsVM.loadDeals()
    }
}

struct SearchSection<Content: View>: View {
    let title: String
    let icon: String
    let count: Int
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primaryColor)
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.primaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.primaryColor.opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            content
        }
    }
}

struct SearchPropertyRow: View {
    let property: Property

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 44, height: 44)
                .background(AppTheme.primaryColor.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(property.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                Text("\(property.city) • \(property.propertyType.displayName)")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            Text(property.price.toCurrency())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.successColor)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SearchClientRow: View {
    let client: Client

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.secondaryColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Text(client.name.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.secondaryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                if let email = client.email {
                    Text(email)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                } else if let phone = client.phone {
                    Text(phone)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SearchActivityRow: View {
    let activity: Activity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.activityType.icon)
                .font(.title3)
                .foregroundColor(AppTheme.accentColor)
                .frame(width: 44, height: 44)
                .background(AppTheme.accentColor.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                Text(activity.activityType.displayName)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            if activity.completedAt != nil {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.successColor)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SearchDealRow: View {
    let deal: Deal

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "briefcase.fill")
                .font(.title3)
                .foregroundColor(AppTheme.successColor)
                .frame(width: 44, height: 44)
                .background(AppTheme.successColor.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                if let notes = deal.notes {
                    Text(notes)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                } else {
                    Text("Sövdələşmə")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Text(deal.status.displayName)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            Text(deal.agreedPrice.toCurrency())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.successColor)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    UniversalSearchView()
}
