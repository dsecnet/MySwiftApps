import Foundation

// MARK: - Auth Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let fullName: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let role: String
    let subscriptionPlan: String
    let agencyName: String?
    let profileImageUrl: String?
    let city: String
    let totalProperties: Int
    let totalClients: Int
    let totalDeals: Int
    let isActive: Bool
    let isVerified: Bool
    let createdAt: Date
}

// MARK: - Property Models
enum PropertyType: String, Codable, CaseIterable {
    case apartment = "apartment"
    case house = "house"
    case office = "office"
    case land = "land"
    case commercial = "commercial"

    var displayName: String {
        switch self {
        case .apartment: return "Mənzil"
        case .house: return "Ev/Villa"
        case .office: return "Ofis"
        case .land: return "Torpaq"
        case .commercial: return "Kommersiya"
        }
    }
}

enum DealType: String, Codable {
    case sale = "sale"
    case rent = "rent"

    var displayName: String {
        switch self {
        case .sale: return "Satış"
        case .rent: return "Kirayə"
        }
    }
}

enum PropertyStatus: String, Codable {
    case available = "available"
    case reserved = "reserved"
    case sold = "sold"
    case rented = "rented"
    case archived = "archived"

    var displayName: String {
        switch self {
        case .available: return "Mövcud"
        case .reserved: return "Rezerv"
        case .sold: return "Satıldı"
        case .rented: return "Kirayələndi"
        case .archived: return "Arxiv"
        }
    }
}

struct Property: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let propertyType: PropertyType
    let dealType: DealType
    let status: PropertyStatus
    let price: Double
    let areaSqm: Double?
    let address: String?
    let city: String
    let district: String?
    let rooms: Int?
    let bathrooms: Int?
    let floor: Int?

    // Map/Location fields
    let latitude: Double?
    let longitude: Double?
    let nearestMetro: String?
    let metroDistanceM: Int?
    let nearbyLandmarks: [Landmark]?

    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Map Models
struct Landmark: Codable, Identifiable {
    var id: String { name }
    let name: String
    let type: String
    let distanceM: Int
    let distanceKm: Double?
    let coordinates: Coordinates?

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case distanceM = "distance_m"
        case distanceKm = "distance_km"
        case coordinates
    }
}

struct Coordinates: Codable {
    let lat: Double
    let lng: Double
}

struct PropertyCreate: Codable {
    let title: String
    let description: String?
    let propertyType: PropertyType
    let dealType: DealType
    let status: PropertyStatus?
    let price: Double
    let areaSqm: Double?
    let address: String?
    let city: String
    let rooms: Int?
    let bathrooms: Int?
    let floor: Int?
}

// MARK: - Client Models
enum ClientType: String, Codable, CaseIterable {
    case buyer = "buyer"
    case seller = "seller"
    case renter = "renter"
    case landlord = "landlord"

    var displayName: String {
        switch self {
        case .buyer: return "Alıcı"
        case .seller: return "Satıcı"
        case .renter: return "Kirayəçi"
        case .landlord: return "Ev sahibi"
        }
    }
}

enum ClientSource: String, Codable, CaseIterable {
    case website = "website"
    case referral = "referral"
    case directCall = "direct_call"
    case socialMedia = "social_media"
    case advertisement = "advertisement"
    case other = "other"

    var displayName: String {
        switch self {
        case .website: return "Vebsayt"
        case .referral: return "Tövsiyə"
        case .directCall: return "Birbaşa zəng"
        case .socialMedia: return "Sosial media"
        case .advertisement: return "Reklam"
        case .other: return "Digər"
        }
    }
}

enum ClientStatus: String, Codable {
    case active = "active"
    case inactive = "inactive"
    case potential = "potential"

    var displayName: String {
        switch self {
        case .active: return "Aktiv"
        case .inactive: return "Qeyri-aktiv"
        case .potential: return "Potensial"
        }
    }
}

struct Client: Codable, Identifiable {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    let clientType: ClientType
    let source: ClientSource
    let status: ClientStatus
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
}

struct ClientCreate: Codable {
    let name: String
    let email: String?
    let phone: String?
    let clientType: ClientType
    let source: ClientSource
    let status: ClientStatus
    let notes: String?
}

// MARK: - Activity Models
enum ActivityType: String, Codable, CaseIterable {
    case call = "call"
    case meeting = "meeting"
    case viewing = "viewing"
    case message = "message"
    case email = "email"
    case note = "note"

    var displayName: String {
        switch self {
        case .call: return "Zəng"
        case .meeting: return "Görüş"
        case .viewing: return "Baxış"
        case .message: return "Mesaj"
        case .email: return "Email"
        case .note: return "Qeyd"
        }
    }

    var icon: String {
        switch self {
        case .call: return "phone.fill"
        case .meeting: return "person.2.fill"
        case .viewing: return "eye.fill"
        case .message: return "message.fill"
        case .email: return "envelope.fill"
        case .note: return "note.text"
        }
    }
}

struct Activity: Codable, Identifiable {
    let id: String
    let activityType: ActivityType
    let title: String
    let description: String?
    let propertyId: String?
    let clientId: String?
    let scheduledAt: Date?
    let completedAt: Date?
    let createdAt: Date
    let updatedAt: Date
}

struct ActivityCreate: Codable {
    let activityType: ActivityType
    let title: String
    let description: String?
    let propertyId: String?
    let clientId: String?
    let scheduledAt: Date?
}

// MARK: - Deal Models
enum DealStatus: String, Codable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"

    var displayName: String {
        switch self {
        case .pending: return "Gözləyir"
        case .inProgress: return "Davam edir"
        case .completed: return "Tamamlandı"
        case .cancelled: return "Ləğv edildi"
        }
    }
}

struct Deal: Codable, Identifiable {
    let id: String
    let propertyId: String
    let clientId: String
    let status: DealStatus
    let agreedPrice: Double
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
}

struct DealCreate: Codable {
    let propertyId: String
    let clientId: String
    let agreedPrice: Double
    let notes: String?
}

// MARK: - Dashboard Models
struct DashboardStats: Codable {
    let totalProperties: Int
    let totalClients: Int
    let totalActivities: Int
    let totalDeals: Int
}

// MARK: - Pagination
struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let total: Int
    let page: Int
    let size: Int
    let pages: Int
}

// MARK: - Map/Location Models
struct MetroStation: Codable, Identifiable {
    var id: String { name }
    let name: String
    let nameEn: String
    let line: String
    let lineName: String
    let latitude: Double
    let longitude: Double
    let opened: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case nameEn = "name_en"
        case line
        case lineName = "line_name"
        case latitude
        case longitude
        case opened
    }
}

struct MetroStationsResponse: Codable {
    let total: Int
    let stations: [MetroStation]
}

struct NearbyPropertiesResponse: Codable {
    let center: LocationCoordinate
    let radiusKm: Double
    let total: Int
    let properties: [PropertyWithDistance]

    enum CodingKeys: String, CodingKey {
        case center
        case radiusKm = "radius_km"
        case total
        case properties
    }
}

struct PropertyWithDistance: Codable, Identifiable {
    let id: String
    let title: String
    let propertyType: PropertyType
    let dealType: DealType
    let price: Double
    let areaSqm: Double?
    let rooms: Int?
    let district: String?
    let address: String?
    let latitude: Double
    let longitude: Double
    let nearestMetro: String?
    let metroDistanceM: Int?
    let images: [String]?
    let distanceKm: Double
    let distanceM: Int

    enum CodingKeys: String, CodingKey {
        case id, title
        case propertyType = "property_type"
        case dealType = "deal_type"
        case price
        case areaSqm = "area_sqm"
        case rooms, district, address
        case latitude, longitude
        case nearestMetro = "nearest_metro"
        case metroDistanceM = "metro_distance_m"
        case images
        case distanceKm = "distance_km"
        case distanceM = "distance_m"
    }
}

struct LocationCoordinate: Codable {
    let latitude: Double
    let longitude: Double
}

struct LandmarkResponse: Codable {
    let total: Int
    let center: LocationCoordinate?
    let landmarks: [LandmarkFull]
}

struct LandmarkFull: Codable, Identifiable {
    var id: String { name }
    let name: String
    let type: String
    let latitude: Double
    let longitude: Double
    let distanceKm: Double?
    let distanceM: Int?

    enum CodingKeys: String, CodingKey {
        case name, type, latitude, longitude
        case distanceKm = "distance_km"
        case distanceM = "distance_m"
    }
}
