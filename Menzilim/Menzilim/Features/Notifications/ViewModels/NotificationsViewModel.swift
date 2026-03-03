import SwiftUI
import Combine

// MARK: - Notification Filter
enum NotificationFilter: String, CaseIterable {
    case all
    case priceDrops
    case newListings
    case system

    var displayKey: String {
        switch self {
        case .all: return "all"
        case .priceDrops: return "price_drops"
        case .newListings: return "new_listings_notif"
        case .system: return "system"
        }
    }

    var notificationType: NotificationType? {
        switch self {
        case .all: return nil
        case .priceDrops: return .priceDrop
        case .newListings: return .newListing
        case .system: return .system
        }
    }
}

// MARK: - Grouped Notifications
struct NotificationGroup: Identifiable {
    let id = UUID()
    let title: String
    let notifications: [AppNotification]
}

// MARK: - Notifications ViewModel
@MainActor
class NotificationsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var notifications: [AppNotification] = []
    @Published var filteredNotifications: [AppNotification] = []
    @Published var groupedNotifications: [NotificationGroup] = []
    @Published var selectedFilter: NotificationFilter = .all {
        didSet { applyFilter() }
    }
    @Published var isLoading: Bool = false
    @Published var unreadCount: Int = 3

    // MARK: - Init
    init() {
        loadMockData()
    }

    // MARK: - Actions
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            if !notifications[index].isRead {
                notifications[index].isRead = true
                unreadCount = max(0, unreadCount - 1)
                applyFilter()
            }
        }
    }

    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        unreadCount = 0
        applyFilter()
    }

    func clearAll() {
        notifications.removeAll()
        unreadCount = 0
        applyFilter()
    }

    // MARK: - Apply Filter
    private func applyFilter() {
        var result = notifications

        if let type = selectedFilter.notificationType {
            result = result.filter { $0.type == type }
        }

        filteredNotifications = result
        groupNotifications()
    }

    // MARK: - Group by Date
    private func groupNotifications() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var todayItems: [AppNotification] = []
        var yesterdayItems: [AppNotification] = []
        var olderItems: [AppNotification] = []

        for notification in filteredNotifications {
            guard let date = notification.createdAt else {
                olderItems.append(notification)
                continue
            }
            let notifDay = calendar.startOfDay(for: date)

            if notifDay == today {
                todayItems.append(notification)
            } else if notifDay == yesterday {
                yesterdayItems.append(notification)
            } else {
                olderItems.append(notification)
            }
        }

        var groups: [NotificationGroup] = []
        if !todayItems.isEmpty {
            groups.append(NotificationGroup(title: "today".localized, notifications: todayItems))
        }
        if !yesterdayItems.isEmpty {
            groups.append(NotificationGroup(title: "yesterday".localized, notifications: yesterdayItems))
        }
        if !olderItems.isEmpty {
            groups.append(NotificationGroup(title: "Daha Əvvəl", notifications: olderItems))
        }

        groupedNotifications = groups
    }

    // MARK: - Load Mock Data
    private func loadMockData() {
        let now = Date()
        let calendar = Calendar.current

        notifications = [
            // Today
            AppNotification(
                id: "n1", userId: "user_001",
                title: "Qiymət Endirimi!",
                body: "Nəsimi rayonundakı 3 otaqlı mənzildə qiymət 15% endirildi.",
                type: .priceDrop,
                data: NotificationData(
                    listingId: "l1",
                    imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=200",
                    price: "382,500 ₼",
                    location: "Nəsimi, Bakı"
                ),
                isRead: false,
                createdAt: calendar.date(byAdding: .hour, value: -1, to: now)
            ),
            AppNotification(
                id: "n2", userId: "user_001",
                title: "Yeni Elan Əlavə Olundu",
                body: "Axtardığınız ərazidə yeni 2 otaqlı mənzil elanı yerləşdirildi.",
                type: .newListing,
                data: NotificationData(
                    listingId: "l2",
                    imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=200",
                    price: "95,000 ₼",
                    location: "Xətai, Bakı"
                ),
                isRead: false,
                createdAt: calendar.date(byAdding: .hour, value: -3, to: now)
            ),
            AppNotification(
                id: "n3", userId: "user_001",
                title: "Hesab Təhlükəsizliyi",
                body: "Hesabınıza yeni cihazdan giriş edildi. Əgər siz deyilsinizsə, dərhal parolunuzu dəyişin.",
                type: .accountSecurity,
                data: nil,
                isRead: false,
                createdAt: calendar.date(byAdding: .hour, value: -5, to: now)
            ),

            // Yesterday
            AppNotification(
                id: "n4", userId: "user_001",
                title: "Baxış Xatırlatması",
                body: "Sabah saat 14:00-da Port Baku-da mənzil baxışınız var.",
                type: .viewingReminder,
                data: nil,
                isRead: true,
                createdAt: calendar.date(byAdding: .day, value: -1, to: now)
            ),
            AppNotification(
                id: "n5", userId: "user_001",
                title: "Qiymət Dəyişikliyi",
                body: "İzlədiyiniz villanın qiyməti yeniləndi: 650,000 ₼ -> 580,000 ₼",
                type: .priceDrop,
                data: NotificationData(
                    listingId: "l5",
                    imageUrl: "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=200",
                    price: "580,000 ₼",
                    location: "Bilgəh, Bakı"
                ),
                isRead: true,
                createdAt: calendar.date(byAdding: .day, value: -1, to: now)
            ),
            AppNotification(
                id: "n6", userId: "user_001",
                title: "Yeni Mənzillər",
                body: "Bu həftə Yasamal rayonunda 12 yeni elan əlavə olundu.",
                type: .newListing,
                data: nil,
                isRead: true,
                createdAt: calendar.date(byAdding: .day, value: -1, to: now)
            ),

            // Older
            AppNotification(
                id: "n7", userId: "user_001",
                title: "Şikayət Yeniləndi",
                body: "Bildirdiyiniz #1234 nömrəli şikayət baxılıb və həll olunub.",
                type: .complaintUpdate,
                data: nil,
                isRead: true,
                createdAt: calendar.date(byAdding: .day, value: -3, to: now)
            ),
            AppNotification(
                id: "n8", userId: "user_001",
                title: "Xoş gəldiniz!",
                body: "Mənzilim ailəsinə xoş gəlmisiniz! Profil məlumatlarınızı tamamlayın.",
                type: .system,
                data: nil,
                isRead: true,
                createdAt: calendar.date(byAdding: .day, value: -7, to: now)
            )
        ]

        unreadCount = notifications.filter { !$0.isRead }.count
        applyFilter()
    }
}
