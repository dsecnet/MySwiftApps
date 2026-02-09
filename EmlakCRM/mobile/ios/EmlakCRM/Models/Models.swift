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
    let user: User
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String
    let isActive: Bool
    let isSuperuser: Bool
    let createdAt: Date
}

// MARK: - Property Models
enum PropertyType: String, Codable, CaseIterable {
    case apartment = "apartment"
    case house = "house"
    case villa = "villa"
    case office = "office"
    case land = "land"
    case commercial = "commercial"

    var displayName: String {
        switch self {
        case .apartment: return "Mənzil"
        case .house: return "Ev"
        case .villa: return "Villa"
        case .office: return "Ofis"
        case .land: return "Torpaq"
        case .commercial: return "Kommersiya"
        }
    }
}

enum ListingType: String, Codable {
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
    case active = "active"
    case pending = "pending"
    case sold = "sold"
    case rented = "rented"

    var displayName: String {
        switch self {
        case .active: return "Aktiv"
        case .pending: return "Gözləyir"
        case .sold: return "Satıldı"
        case .rented: return "Kirayələndi"
        }
    }
}

struct Property: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let propertyType: PropertyType
    let listingType: ListingType?
    let status: PropertyStatus
    let price: Double
    let area: Double
    let address: String
    let city: String
    let bedrooms: Int?
    let bathrooms: Int?
    let floor: Int?
    let createdAt: Date
    let updatedAt: Date
}

struct PropertyCreate: Codable {
    let title: String
    let description: String?
    let propertyType: PropertyType
    let listingType: ListingType
    let status: PropertyStatus
    let price: Double
    let area: Double
    let address: String
    let city: String
    let bedrooms: Int?
    let bathrooms: Int?
    let floor: Int?
}

// MARK: - Client Models
enum ClientType: String, Codable, CaseIterable {
    case buyer = "buyer"
    case seller = "seller"
    case tenant = "tenant"
    case landlord = "landlord"

    var displayName: String {
        switch self {
        case .buyer: return "Alıcı"
        case .seller: return "Satıcı"
        case .tenant: return "Kirayəçi"
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
    case email = "email"
    case visit = "visit"
    case other = "other"

    var displayName: String {
        switch self {
        case .call: return "Zəng"
        case .meeting: return "Görüş"
        case .email: return "Email"
        case .visit: return "Baxış"
        case .other: return "Digər"
        }
    }

    var icon: String {
        switch self {
        case .call: return "phone.fill"
        case .meeting: return "person.2.fill"
        case .email: return "envelope.fill"
        case .visit: return "eye.fill"
        case .other: return "ellipsis.circle.fill"
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
    case active = "active"
    case won = "won"
    case lost = "lost"

    var displayName: String {
        switch self {
        case .pending: return "Gözləyir"
        case .active: return "Aktiv"
        case .won: return "Qazanıldı"
        case .lost: return "İtirildi"
        }
    }
}

struct Deal: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let amount: Double
    let status: DealStatus
    let propertyId: String?
    let clientId: String?
    let closedAt: Date?
    let createdAt: Date
    let updatedAt: Date
}

struct DealCreate: Codable {
    let title: String
    let description: String?
    let amount: Double
    let status: DealStatus
    let propertyId: String?
    let clientId: String?
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
