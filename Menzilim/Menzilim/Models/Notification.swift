import Foundation

// MARK: - Notification Type
enum NotificationType: String, Codable {
    case newListing = "new_listing"
    case priceDrop = "price_drop"
    case complaintUpdate = "complaint_update"
    case system = "system"
    case viewingReminder = "viewing_reminder"
    case accountSecurity = "account_security"

    var icon: String {
        switch self {
        case .newListing: return "house.fill"
        case .priceDrop: return "arrow.down.circle.fill"
        case .complaintUpdate: return "exclamationmark.bubble.fill"
        case .system: return "bell.fill"
        case .viewingReminder: return "calendar.badge.clock"
        case .accountSecurity: return "lock.shield.fill"
        }
    }

    var iconColor: String {
        switch self {
        case .newListing: return "3B82F6"
        case .priceDrop: return "10B981"
        case .complaintUpdate: return "F59E0B"
        case .system: return "8B5CF6"
        case .viewingReminder: return "06B6D4"
        case .accountSecurity: return "EF4444"
        }
    }
}

// MARK: - App Notification Model
struct AppNotification: Codable, Identifiable {
    let id: String
    let userId: String
    var title: String
    var body: String
    var type: NotificationType
    var data: NotificationData?
    var isRead: Bool
    var createdAt: Date?

    var timeAgo: String {
        guard let date = createdAt else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    enum CodingKeys: String, CodingKey {
        case id, title, body, type, data
        case userId = "user_id"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

// MARK: - Notification Data
struct NotificationData: Codable {
    var listingId: String?
    var imageUrl: String?
    var price: String?
    var location: String?

    enum CodingKeys: String, CodingKey {
        case listingId = "listing_id"
        case imageUrl = "image_url"
        case price, location
    }
}
