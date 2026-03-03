import SwiftUI
import Combine

// MARK: - Listings ViewModel
@MainActor
class ListingsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var similarListings: [Listing] = []
    @Published var favoriteListingIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var isReporting: Bool = false
    @Published var reportSuccess: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Mock Data Flag
    private let useMockData: Bool = true

    // MARK: - Fetch Listing Detail (from API)
    func fetchListingDetail(id: String) async -> Listing? {
        if useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            return HomeViewModel.mockListings.first { $0.id == id }
        }

        do {
            let listing: Listing = try await APIService.shared.request(
                endpoint: "/listings/\(id)"
            )
            return listing
        } catch {
            errorMessage = error.localizedDescription
            print("[ListingsViewModel] fetchListingDetail error: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Load Similar Listings
    func loadSimilarListings(for listing: Listing) {
        if useMockData {
            // Filter mock listings by same property type, excluding current listing
            similarListings = HomeViewModel.mockListings.filter {
                $0.id != listing.id && $0.propertyType == listing.propertyType
            }
            // If not enough similar by type, add others
            if similarListings.count < 3 {
                let additional = HomeViewModel.mockListings.filter { item in
                    item.id != listing.id && !similarListings.contains(where: { s in s.id == item.id })
                }
                similarListings.append(contentsOf: additional.prefix(3 - similarListings.count))
            }
            return
        }

        Task {
            await fetchSimilarListings(for: listing)
        }
    }

    private func fetchSimilarListings(for listing: Listing) async {
        do {
            let params: [String: String] = [
                "property_type": listing.propertyType.rawValue,
                "listing_type": listing.listingType.rawValue,
                "city": listing.city,
                "per_page": "5",
                "page": "1"
            ]
            let response: PaginatedResponse<Listing> = try await APIService.shared.request(
                endpoint: "/listings",
                queryParams: params
            )
            similarListings = response.items.filter { $0.id != listing.id }
        } catch {
            print("[ListingsViewModel] fetchSimilarListings error: \(error.localizedDescription)")
            // Fall back to mock data
            similarListings = HomeViewModel.mockListings.filter {
                $0.id != listing.id
            }.prefix(4).map { $0 }
        }
    }

    // MARK: - Toggle Favorite
    func toggleFavorite(listing: Listing) {
        if favoriteListingIds.contains(listing.id) {
            favoriteListingIds.remove(listing.id)
        } else {
            favoriteListingIds.insert(listing.id)
        }

        if !useMockData {
            Task {
                await syncFavorite(listingId: listing.id)
            }
        }
    }

    func isFavorited(listing: Listing) -> Bool {
        favoriteListingIds.contains(listing.id)
    }

    private func syncFavorite(listingId: String) async {
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/listings/\(listingId)/favorite",
                method: .POST
            )
        } catch {
            print("[ListingsViewModel] syncFavorite error: \(error.localizedDescription)")
        }
    }

    // MARK: - Report Listing
    func reportListing(listingId: String, reason: String, description: String) async {
        isReporting = true
        reportSuccess = false
        errorMessage = nil

        if useMockData {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            reportSuccess = true
            isReporting = false
            return
        }

        do {
            struct ReportRequest: Codable {
                let reason: String
                let description: String
            }
            let body = ReportRequest(reason: reason, description: description)
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/listings/\(listingId)/report",
                method: .POST,
                body: body
            )
            reportSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            print("[ListingsViewModel] reportListing error: \(error.localizedDescription)")
        }

        isReporting = false
    }

    // MARK: - Fetch Favorites
    func fetchFavorites() async -> [Listing] {
        if useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            return HomeViewModel.mockListings.filter { favoriteListingIds.contains($0.id) }
        }

        do {
            let response: PaginatedResponse<Listing> = try await APIService.shared.request(
                endpoint: "/user/favorites"
            )
            favoriteListingIds = Set(response.items.map { $0.id })
            return response.items
        } catch {
            print("[ListingsViewModel] fetchFavorites error: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Search Listings
    func searchListings(query: String, filter: ListingFilter? = nil) async -> [Listing] {
        if useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            let lowercased = query.lowercased()
            return HomeViewModel.mockListings.filter {
                $0.title.lowercased().contains(lowercased) ||
                $0.district.lowercased().contains(lowercased) ||
                $0.address.lowercased().contains(lowercased) ||
                $0.city.lowercased().contains(lowercased)
            }
        }

        do {
            var params: [String: String] = [
                "q": query,
                "page": "1",
                "per_page": "20"
            ]

            if let filter = filter {
                if let listingType = filter.listingType {
                    params["listing_type"] = listingType.rawValue
                }
                if let propertyType = filter.propertyType {
                    params["property_type"] = propertyType.rawValue
                }
                if let minPrice = filter.minPrice {
                    params["min_price"] = "\(minPrice)"
                }
                if let maxPrice = filter.maxPrice {
                    params["max_price"] = "\(maxPrice)"
                }
                if let rooms = filter.rooms {
                    params["rooms"] = "\(rooms)"
                }
                if let city = filter.city {
                    params["city"] = city
                }
                if let district = filter.district {
                    params["district"] = district
                }
            }

            let response: PaginatedResponse<Listing> = try await APIService.shared.request(
                endpoint: "/listings/search",
                queryParams: params
            )
            return response.items
        } catch {
            errorMessage = error.localizedDescription
            print("[ListingsViewModel] searchListings error: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - Empty Response Helper
struct EmptyResponse: Codable {}
