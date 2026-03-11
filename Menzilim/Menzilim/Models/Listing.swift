import Foundation

// MARK: - Listing Type
enum ListingType: String, Codable, CaseIterable {
    case sale
    case rent
    case dailyRent = "daily_rent"

    var displayKey: String {
        switch self {
        case .sale: return "for_sale"
        case .rent: return "for_rent"
        case .dailyRent: return "daily_rent"
        }
    }

    var icon: String {
        switch self {
        case .sale: return "tag.fill"
        case .rent: return "key.fill"
        case .dailyRent: return "clock.fill"
        }
    }
}

// MARK: - Property Type
enum PropertyType: String, Codable, CaseIterable {
    case oldBuilding = "old_building"
    case newBuilding = "new_building"
    case house
    case office
    case garage
    case land
    case commercial

    var displayKey: String {
        switch self {
        case .oldBuilding: return "old_building"
        case .newBuilding: return "new_building"
        case .house: return "house"
        case .office: return "office"
        case .garage: return "garage"
        case .land: return "land"
        case .commercial: return "commercial"
        }
    }

    var icon: String {
        switch self {
        case .oldBuilding: return "building.2.fill"
        case .newBuilding: return "building.fill"
        case .house: return "house.lodge.fill"
        case .office: return "building.columns.fill"
        case .garage: return "car.fill"
        case .land: return "globe.europe.africa.fill"
        case .commercial: return "storefront.fill"
        }
    }
}

// MARK: - Currency
enum Currency: String, Codable, CaseIterable {
    case AZN, USD, EUR

    var symbol: String {
        switch self {
        case .AZN: return "₼"
        case .USD: return "$"
        case .EUR: return "€"
        }
    }
}

// MARK: - Renovation
enum Renovation: String, Codable, CaseIterable {
    case none
    case medium
    case good
    case excellent

    var displayKey: String {
        switch self {
        case .none: return "renovation_none"
        case .medium: return "renovation_medium"
        case .good: return "renovation_good"
        case .excellent: return "renovation_excellent"
        }
    }
}

// MARK: - Listing Status
enum ListingStatus: String, Codable {
    case active
    case pending
    case sold
    case rented
    case archived
}

// MARK: - Boost Type
enum BoostType: String, Codable, CaseIterable {
    case vip
    case premium
    case standard

    var displayName: String {
        switch self {
        case .vip: return "VIP"
        case .premium: return "Premium"
        case .standard: return "İrəli"
        }
    }

    var color: String {
        switch self {
        case .vip: return "EF4444"
        case .premium: return "8B5CF6"
        case .standard: return "3B82F6"
        }
    }
}

// MARK: - Listing Model
struct Listing: Codable, Identifiable {
    let id: String
    let userId: String
    var agentId: String?
    var title: String
    var description: String
    var listingType: ListingType
    var propertyType: PropertyType
    var price: Double
    var currency: Currency
    var city: String
    var district: String
    var address: String
    var latitude: Double?
    var longitude: Double?
    var rooms: Int
    var areaSqm: Double
    var floor: Int?
    var totalFloors: Int?
    var renovation: Renovation
    var images: [String]
    var videoUrl: String?
    var status: ListingStatus
    var viewsCount: Int
    var isBoosted: Bool
    var boostType: BoostType?
    var boostExpiresAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    // Computed
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let priceStr = formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
        return "\(priceStr) \(currency.symbol)"
    }

    var mainImage: String {
        images.first ?? ""
    }

    var floorInfo: String? {
        guard let floor = floor, let total = totalFloors else { return nil }
        return "\(floor)/\(total)"
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, currency, city, district, address
        case latitude, longitude, rooms, floor, renovation, images, status
        case userId = "user_id"
        case agentId = "agent_id"
        case listingType = "listing_type"
        case propertyType = "property_type"
        case areaSqm = "area_sqm"
        case totalFloors = "total_floors"
        case videoUrl = "video_url"
        case viewsCount = "views_count"
        case isBoosted = "is_boosted"
        case boostType = "boost_type"
        case boostExpiresAt = "boost_expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Listing Filter
struct ListingFilter {
    var listingType: ListingType?
    var propertyType: PropertyType?
    var minPrice: Double?
    var maxPrice: Double?
    var currency: Currency = .AZN
    var rooms: Int?
    var minArea: Double?
    var maxArea: Double?
    var minFloor: Int?
    var maxFloor: Int?
    var renovation: Renovation?
    var city: String?
    var district: String?
    var query: String?
    var sortBy: SortOption = .newest

    var hasActiveFilters: Bool {
        listingType != nil || propertyType != nil || minPrice != nil ||
        maxPrice != nil || rooms != nil || minArea != nil || maxArea != nil ||
        renovation != nil || city != nil || district != nil
    }
}

enum SortOption: String, CaseIterable {
    case newest = "newest"
    case oldest = "oldest"
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case popular = "popular"

    var displayName: String {
        switch self {
        case .newest: return "Ən yeni"
        case .oldest: return "Ən köhnə"
        case .priceAsc: return "Qiymət ↑"
        case .priceDesc: return "Qiymət ↓"
        case .popular: return "Populyar"
        }
    }
}

// MARK: - Paginated Response
struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let total: Int
    let page: Int
    let perPage: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case items, total, page
        case perPage = "per_page"
        case totalPages = "total_pages"
    }
}

// MARK: - Create Listing Request
struct CreateListingRequest: Codable {
    var title: String
    var description: String
    var listingType: String
    var propertyType: String
    var price: Double
    var currency: String
    var city: String
    var district: String
    var address: String
    var latitude: Double?
    var longitude: Double?
    var rooms: Int
    var areaSqm: Double
    var floor: Int?
    var totalFloors: Int?
    var renovation: String
    var images: [String]
    var videoUrl: String?

    enum CodingKeys: String, CodingKey {
        case title, description, price, currency, city, district, address
        case latitude, longitude, rooms, floor, renovation, images
        case listingType = "listing_type"
        case propertyType = "property_type"
        case areaSqm = "area_sqm"
        case totalFloors = "total_floors"
        case videoUrl = "video_url"
    }
}
