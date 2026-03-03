import SwiftUI
import Combine

// MARK: - Favorites Filter
enum FavoritesFilter: String, CaseIterable {
    case all
    case apartments
    case villas
    case land

    var displayKey: String {
        switch self {
        case .all: return "all"
        case .apartments: return "apartment"
        case .villas: return "villa"
        case .land: return "land"
        }
    }

    var propertyType: PropertyType? {
        switch self {
        case .all: return nil
        case .apartments: return .apartment
        case .villas: return .villa
        case .land: return .land
        }
    }
}

// MARK: - Favorites ViewModel
@MainActor
class FavoritesViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var favorites: [Listing] = []
    @Published var filteredFavorites: [Listing] = []
    @Published var searchText: String = "" {
        didSet { applyFilters() }
    }
    @Published var selectedFilter: FavoritesFilter = .all {
        didSet { applyFilters() }
    }
    @Published var isLoading: Bool = false
    @Published var favoriteIds: Set<String> = []

    // MARK: - Init
    init() {
        loadMockData()
    }

    // MARK: - Toggle Favorite
    func toggleFavorite(_ listing: Listing) {
        if favoriteIds.contains(listing.id) {
            favoriteIds.remove(listing.id)
            favorites.removeAll { $0.id == listing.id }
        } else {
            favoriteIds.insert(listing.id)
            favorites.append(listing)
        }
        applyFilters()
    }

    func isFavorite(_ listing: Listing) -> Bool {
        favoriteIds.contains(listing.id)
    }

    // MARK: - Apply Filters
    private func applyFilters() {
        var result = favorites

        // Apply property type filter
        if let propertyType = selectedFilter.propertyType {
            result = result.filter { $0.propertyType == propertyType }
        }

        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.district.localizedCaseInsensitiveContains(searchText) ||
                $0.city.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }

        filteredFavorites = result
    }

    // MARK: - Load Mock Data
    private func loadMockData() {
        favorites = [
            Listing(
                id: "fav1", userId: "user_001", agentId: "agent_001",
                title: "Dəniz mənzərəli 3 otaqlı mənzil",
                description: "Port Baku Residence-da lüks mənzil",
                listingType: .sale, propertyType: .apartment,
                price: 450000, currency: .AZN,
                city: "Bakı", district: "Nəsimi", address: "Port Baku Towers",
                latitude: 40.3725, longitude: 49.8431,
                rooms: 3, areaSqm: 145, floor: 14, totalFloors: 22,
                renovation: .excellent,
                images: ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600"],
                videoUrl: nil, status: .active, viewsCount: 1245,
                isBoosted: true, boostType: .vip
            ),
            Listing(
                id: "fav2", userId: "user_002", agentId: "agent_002",
                title: "Villa Bilgəh",
                description: "Bilgəhdə dənizə yaxın villa",
                listingType: .sale, propertyType: .villa,
                price: 650000, currency: .AZN,
                city: "Bakı", district: "Bilgəh", address: "Sahil yolu, 22",
                latitude: 40.5512, longitude: 50.0734,
                rooms: 5, areaSqm: 380, floor: 2, totalFloors: 2,
                renovation: .excellent,
                images: ["https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=600"],
                videoUrl: nil, status: .active, viewsCount: 892,
                isBoosted: false
            ),
            Listing(
                id: "fav3", userId: "user_003", agentId: "agent_001",
                title: "Yeni tikili 2 otaqlı",
                description: "Xətai rayonunda yeni tikili mənzil",
                listingType: .sale, propertyType: .apartment,
                price: 135000, currency: .AZN,
                city: "Bakı", district: "Xətai", address: "Babək pr., 78",
                latitude: 40.3880, longitude: 49.8692,
                rooms: 2, areaSqm: 85, floor: 10, totalFloors: 18,
                renovation: .good,
                images: ["https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600"],
                videoUrl: nil, status: .active, viewsCount: 567,
                isBoosted: false
            ),
            Listing(
                id: "fav4", userId: "user_004", agentId: "agent_003",
                title: "Torpaq sahəsi Mərdəkan",
                description: "Tikintiyə yararlı torpaq sahəsi",
                listingType: .sale, propertyType: .land,
                price: 120000, currency: .AZN,
                city: "Bakı", district: "Mərdəkan", address: "Mərdəkan qəsəbəsi",
                latitude: 40.4956, longitude: 50.1487,
                rooms: 0, areaSqm: 800, floor: nil, totalFloors: nil,
                renovation: .none,
                images: ["https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=600"],
                videoUrl: nil, status: .active, viewsCount: 234,
                isBoosted: false
            ),
            Listing(
                id: "fav5", userId: "user_002", agentId: "agent_002",
                title: "Penthouse White City",
                description: "Ağ Şəhər layihəsində penthouse",
                listingType: .sale, propertyType: .apartment,
                price: 980000, currency: .AZN,
                city: "Bakı", district: "Nəsimi", address: "Ağ Şəhər, Blok A",
                latitude: 40.3745, longitude: 49.8510,
                rooms: 4, areaSqm: 260, floor: 20, totalFloors: 22,
                renovation: .excellent,
                images: ["https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600"],
                videoUrl: nil, status: .active, viewsCount: 1823,
                isBoosted: true, boostType: .premium
            )
        ]

        favoriteIds = Set(favorites.map { $0.id })
        applyFilters()
    }
}
