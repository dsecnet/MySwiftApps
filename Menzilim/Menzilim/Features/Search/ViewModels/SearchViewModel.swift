import SwiftUI
import Combine

// MARK: - Search ViewModel
@MainActor
class SearchViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var results: [Listing] = []
    @Published var isLoading: Bool = false
    @Published var showMapView: Bool = false
    @Published var showFilterSheet: Bool = false
    @Published var errorMessage: String?

    // MARK: - Filter State
    @Published var filter: ListingFilter = ListingFilter()

    // Quick filter chips
    @Published var selectedPriceRange: String?
    @Published var selectedRoomFilter: String?
    @Published var selectedAgentLevel: String?

    // MARK: - Results Info
    @Published var totalResults: Int = 0

    // MARK: - Private
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared

    // MARK: - Mock Data
    private static let mockListings: [Listing] = [
        Listing(
            id: "1", userId: "u1", agentId: "a1",
            title: "Yasamal rayonunda 3 otaqli menzil",
            description: "Ela temirli, isiqli menzil",
            listingType: .sale, propertyType: .apartment,
            price: 185000, currency: .AZN,
            city: "Baki", district: "Yasamal",
            address: "Hesen Aliyev kuc. 42",
            latitude: 40.3893, longitude: 49.8471,
            rooms: 3, areaSqm: 95, floor: 7, totalFloors: 16,
            renovation: .excellent, images: [], videoUrl: nil,
            status: .active, viewsCount: 234,
            isBoosted: true, boostType: .vip,
            boostExpiresAt: nil, createdAt: Date(), updatedAt: Date()
        ),
        Listing(
            id: "2", userId: "u2", agentId: "a2",
            title: "Nerimanov rayonunda 2 otaqli menzil",
            description: "Yeni tikili, temirli",
            listingType: .sale, propertyType: .apartment,
            price: 142000, currency: .AZN,
            city: "Baki", district: "Nerimanov",
            address: "Tabriz kuc. 18",
            latitude: 40.4093, longitude: 49.8671,
            rooms: 2, areaSqm: 72, floor: 12, totalFloors: 20,
            renovation: .good, images: [], videoUrl: nil,
            status: .active, viewsCount: 156,
            isBoosted: false, boostType: nil,
            boostExpiresAt: nil, createdAt: Date(), updatedAt: Date()
        ),
        Listing(
            id: "3", userId: "u3", agentId: nil,
            title: "Xetai rayonunda 1 otaqli menzil kiraye",
            description: "Metro yaxinliginda",
            listingType: .rent, propertyType: .apartment,
            price: 650, currency: .AZN,
            city: "Baki", district: "Xetai",
            address: "Semed Vurgun kuc. 5",
            latitude: 40.3793, longitude: 49.8571,
            rooms: 1, areaSqm: 45, floor: 3, totalFloors: 9,
            renovation: .medium, images: [], videoUrl: nil,
            status: .active, viewsCount: 89,
            isBoosted: false, boostType: nil,
            boostExpiresAt: nil, createdAt: Date(), updatedAt: Date()
        ),
        Listing(
            id: "4", userId: "u4", agentId: "a1",
            title: "Nizami rayonunda 4 otaqli villa",
            description: "Hovuzlu, bagca ile",
            listingType: .sale, propertyType: .villa,
            price: 520000, currency: .AZN,
            city: "Baki", district: "Nizami",
            address: "Baki kuc. 112",
            latitude: 40.3993, longitude: 49.8371,
            rooms: 4, areaSqm: 220, floor: 1, totalFloors: 3,
            renovation: .excellent, images: [], videoUrl: nil,
            status: .active, viewsCount: 312,
            isBoosted: true, boostType: .premium,
            boostExpiresAt: nil, createdAt: Date(), updatedAt: Date()
        ),
        Listing(
            id: "5", userId: "u5", agentId: "a3",
            title: "Nasimi rayonunda ofis sahesi",
            description: "Merkezi lokasiya, temirli",
            listingType: .rent, propertyType: .office,
            price: 1800, currency: .AZN,
            city: "Baki", district: "Nasimi",
            address: "Nizami kuc. 200",
            latitude: 40.3693, longitude: 49.8271,
            rooms: 3, areaSqm: 130, floor: 5, totalFloors: 12,
            renovation: .good, images: [], videoUrl: nil,
            status: .active, viewsCount: 78,
            isBoosted: false, boostType: nil,
            boostExpiresAt: nil, createdAt: Date(), updatedAt: Date()
        ),
        Listing(
            id: "6", userId: "u1", agentId: "a2",
            title: "Suraxani rayonunda 2 otaqli menzil",
            description: "Yeni tikili, temirli, avtobus yaxinliginda",
            listingType: .sale, propertyType: .apartment,
            price: 78000, currency: .AZN,
            city: "Baki", district: "Suraxani",
            address: "Hezi Aslanov kuc. 33",
            latitude: 40.4193, longitude: 49.9471,
            rooms: 2, areaSqm: 62, floor: 9, totalFloors: 14,
            renovation: .medium, images: [], videoUrl: nil,
            status: .active, viewsCount: 201,
            isBoosted: false, boostType: nil,
            boostExpiresAt: nil, createdAt: Date(), updatedAt: Date()
        )
    ]

    // MARK: - Init
    init() {
        results = Self.mockListings
        totalResults = results.count

        // Debounced search
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task { [weak self] in
                    await self?.search()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Search
    func search() async {
        isLoading = true

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000)

        var filtered = Self.mockListings

        // Text search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            filtered = filtered.filter { listing in
                listing.title.lowercased().contains(query) ||
                listing.district.lowercased().contains(query) ||
                listing.city.lowercased().contains(query) ||
                listing.address.lowercased().contains(query)
            }
        }

        // Apply filter state
        filtered = applyFilterLogic(to: filtered)

        results = filtered
        totalResults = filtered.count
        isLoading = false
    }

    // MARK: - Apply Filters
    func applyFilters() {
        Task {
            await search()
        }
        showFilterSheet = false
    }

    // MARK: - Reset Filters
    func resetFilters() {
        filter = ListingFilter()
        selectedPriceRange = nil
        selectedRoomFilter = nil
        selectedAgentLevel = nil
        Task {
            await search()
        }
    }

    // MARK: - Toggle Map/List
    func toggleMapView() {
        showMapView.toggle()
    }

    // MARK: - Quick Filter Actions
    func selectPriceRange(_ range: String?) {
        selectedPriceRange = range
        switch range {
        case "0-100K":
            filter.minPrice = 0
            filter.maxPrice = 100000
        case "100K-300K":
            filter.minPrice = 100000
            filter.maxPrice = 300000
        case "300K+":
            filter.minPrice = 300000
            filter.maxPrice = nil
        default:
            filter.minPrice = nil
            filter.maxPrice = nil
        }
        applyFilters()
    }

    func selectRoomFilter(_ rooms: String?) {
        selectedRoomFilter = rooms
        if let rooms = rooms, let count = Int(rooms) {
            filter.rooms = count
        } else {
            filter.rooms = nil
        }
        applyFilters()
    }

    // MARK: - Private Filter Logic
    private func applyFilterLogic(to listings: [Listing]) -> [Listing] {
        var filtered = listings

        // Listing type
        if let listingType = filter.listingType {
            filtered = filtered.filter { $0.listingType == listingType }
        }

        // Property type
        if let propertyType = filter.propertyType {
            filtered = filtered.filter { $0.propertyType == propertyType }
        }

        // Price range
        if let minPrice = filter.minPrice {
            filtered = filtered.filter { $0.price >= minPrice }
        }
        if let maxPrice = filter.maxPrice {
            filtered = filtered.filter { $0.price <= maxPrice }
        }

        // Rooms
        if let rooms = filter.rooms {
            if rooms >= 4 {
                filtered = filtered.filter { $0.rooms >= 4 }
            } else {
                filtered = filtered.filter { $0.rooms == rooms }
            }
        }

        // Area range
        if let minArea = filter.minArea {
            filtered = filtered.filter { $0.areaSqm >= minArea }
        }
        if let maxArea = filter.maxArea {
            filtered = filtered.filter { $0.areaSqm <= maxArea }
        }

        // Renovation
        if let renovation = filter.renovation {
            filtered = filtered.filter { $0.renovation == renovation }
        }

        return filtered
    }
}
