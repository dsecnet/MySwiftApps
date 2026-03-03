import Foundation
import UIKit
import UserNotifications

// MARK: - Notification Category
enum MenzilimNotificationCategory: String {
    case priceDrop = "PRICE_DROP"
    case newListing = "NEW_LISTING"
    case message = "MESSAGE"
    case boostExpiry = "BOOST_EXPIRY"
    case systemAlert = "SYSTEM_ALERT"
}

// MARK: - Notification Action
enum MenzilimNotificationAction: String {
    case viewListing = "VIEW_LISTING"
    case dismiss = "DISMISS"
    case replyMessage = "REPLY_MESSAGE"
    case renewBoost = "RENEW_BOOST"
}

// MARK: - Notification Service
@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()

    // MARK: - Published Properties
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var deviceToken: String?
    @Published private(set) var pendingDeepLink: DeepLinkDestination?

    // MARK: - Private Properties
    private let center = UNUserNotificationCenter.current()
    private let api = APIService.shared
    private let deviceTokenKey = "device_push_token"

    // MARK: - Init
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Request Permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted

            if granted {
                await registerForRemoteNotifications()
                setupNotificationCategories()
                AppLogger.log("Push notification permission granted", category: AppLogger.notification)
            } else {
                AppLogger.log("Push notification permission denied", category: AppLogger.notification)
            }

            return granted
        } catch {
            AppLogger.error("Push notification authorization error: \(error.localizedDescription)", category: AppLogger.notification)
            return false
        }
    }

    // MARK: - Check Authorization Status
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Register for Remote Notifications
    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // MARK: - Handle Device Token
    func handleDeviceToken(_ deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = token
        UserDefaults.standard.set(token, forKey: deviceTokenKey)
        AppLogger.log("APNs device token received: \(token.prefix(20))...", category: AppLogger.notification)

        // Send to backend
        Task {
            await sendTokenToBackend(token)
        }
    }

    // MARK: - Handle Registration Failure
    func handleRegistrationFailure(_ error: Error) {
        AppLogger.error("APNs registration failed: \(error.localizedDescription)", category: AppLogger.notification)
    }

    // MARK: - Send Token to Backend
    func sendTokenToBackend(_ token: String? = nil) async {
        let pushToken = token ?? deviceToken ?? UserDefaults.standard.string(forKey: deviceTokenKey)
        guard let pushToken = pushToken else {
            AppLogger.log("No device token available to send to backend", category: AppLogger.notification)
            return
        }

        do {
            struct DeviceTokenRequest: Codable {
                let deviceToken: String
                let platform: String
                let bundleId: String

                enum CodingKeys: String, CodingKey {
                    case deviceToken = "device_token"
                    case platform
                    case bundleId = "bundle_id"
                }
            }

            let request = DeviceTokenRequest(
                deviceToken: pushToken,
                platform: "ios",
                bundleId: Bundle.main.bundleIdentifier ?? "com.menzilim.app"
            )

            struct TokenResponse: Codable {
                let success: Bool
            }

            let _: TokenResponse = try await api.request(
                endpoint: "/notifications/register-device",
                method: .POST,
                body: request
            )

            AppLogger.log("Device token sent to backend successfully", category: AppLogger.notification)
        } catch {
            AppLogger.error("Failed to send device token to backend: \(error.localizedDescription)", category: AppLogger.notification)
        }
    }

    // MARK: - Setup Notification Categories
    func setupNotificationCategories() {
        // View listing action
        let viewListingAction = UNNotificationAction(
            identifier: MenzilimNotificationAction.viewListing.rawValue,
            title: "Elana bax",
            options: .foreground
        )

        // Dismiss action
        let dismissAction = UNNotificationAction(
            identifier: MenzilimNotificationAction.dismiss.rawValue,
            title: "Bağla",
            options: .destructive
        )

        // Reply message action
        let replyAction = UNTextInputNotificationAction(
            identifier: MenzilimNotificationAction.replyMessage.rawValue,
            title: "Cavab yaz",
            options: [],
            textInputButtonTitle: "Göndər",
            textInputPlaceholder: "Mesajınız..."
        )

        // Renew boost action
        let renewBoostAction = UNNotificationAction(
            identifier: MenzilimNotificationAction.renewBoost.rawValue,
            title: "Yeniləmə",
            options: .foreground
        )

        // Price drop category
        let priceDropCategory = UNNotificationCategory(
            identifier: MenzilimNotificationCategory.priceDrop.rawValue,
            actions: [viewListingAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // New listing category
        let newListingCategory = UNNotificationCategory(
            identifier: MenzilimNotificationCategory.newListing.rawValue,
            actions: [viewListingAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Message category
        let messageCategory = UNNotificationCategory(
            identifier: MenzilimNotificationCategory.message.rawValue,
            actions: [replyAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Boost expiry category
        let boostExpiryCategory = UNNotificationCategory(
            identifier: MenzilimNotificationCategory.boostExpiry.rawValue,
            actions: [renewBoostAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // System alert category
        let systemAlertCategory = UNNotificationCategory(
            identifier: MenzilimNotificationCategory.systemAlert.rawValue,
            actions: [dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        center.setNotificationCategories([
            priceDropCategory,
            newListingCategory,
            messageCategory,
            boostExpiryCategory,
            systemAlertCategory
        ])

        AppLogger.log("Notification categories configured", category: AppLogger.notification)
    }

    // MARK: - Handle Notification Response
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        let actionId = response.actionIdentifier

        AppLogger.log("Notification action: \(actionId)", category: AppLogger.notification)

        switch actionId {
        case MenzilimNotificationAction.viewListing.rawValue:
            if let listingId = userInfo["listing_id"] as? String {
                navigateTo(.listing(id: listingId))
            }

        case MenzilimNotificationAction.replyMessage.rawValue:
            if let textResponse = response as? UNTextInputNotificationResponse,
               let chatId = userInfo["chat_id"] as? String {
                handleQuickReply(message: textResponse.userText, chatId: chatId)
            }

        case MenzilimNotificationAction.renewBoost.rawValue:
            if let listingId = userInfo["listing_id"] as? String {
                navigateTo(.listing(id: listingId))
            }

        case UNNotificationDefaultActionIdentifier:
            handleDefaultTap(userInfo: userInfo)

        default:
            break
        }
    }

    // MARK: - Handle Foreground Notification
    func handleForegroundNotification(_ notification: UNNotification) -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        AppLogger.log("Foreground notification received: \(userInfo)", category: AppLogger.notification)
        return [.banner, .badge, .sound]
    }

    // MARK: - Deep Link Navigation
    private func navigateTo(_ destination: DeepLinkDestination) {
        pendingDeepLink = destination
        NotificationCenter.default.post(
            name: .deepLinkNotification,
            object: nil,
            userInfo: ["destination": destination]
        )
    }

    func clearPendingDeepLink() {
        pendingDeepLink = nil
    }

    // MARK: - Handle Default Tap
    private func handleDefaultTap(userInfo: [AnyHashable: Any]) {
        if let listingId = userInfo["listing_id"] as? String {
            navigateTo(.listing(id: listingId))
        } else if let chatId = userInfo["chat_id"] as? String {
            navigateTo(.chat(id: chatId))
        } else if let userId = userInfo["user_id"] as? String {
            navigateTo(.profile(id: userId))
        } else {
            navigateTo(.notifications)
        }
    }

    // MARK: - Handle Quick Reply
    private func handleQuickReply(message: String, chatId: String) {
        AppLogger.log("Quick reply to chat \(chatId): \(message)", category: AppLogger.notification)

        Task {
            do {
                struct QuickReplyRequest: Codable {
                    let chatId: String
                    let message: String

                    enum CodingKeys: String, CodingKey {
                        case chatId = "chat_id"
                        case message
                    }
                }

                struct QuickReplyResponse: Codable {
                    let success: Bool
                }

                let request = QuickReplyRequest(chatId: chatId, message: message)
                let _: QuickReplyResponse = try await api.request(
                    endpoint: "/messages/quick-reply",
                    method: .POST,
                    body: request
                )

                AppLogger.log("Quick reply sent successfully", category: AppLogger.notification)
            } catch {
                AppLogger.error("Failed to send quick reply: \(error.localizedDescription)", category: AppLogger.notification)
            }
        }
    }

    // MARK: - Update Badge Count
    func updateBadgeCount(_ count: Int) {
        Task {
            do {
                try await center.setBadgeCount(count)
            } catch {
                AppLogger.error("Failed to update badge count: \(error.localizedDescription)", category: AppLogger.notification)
            }
        }
    }

    // MARK: - Clear All Notifications
    func clearAllNotifications() {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        updateBadgeCount(0)
    }

    // MARK: - Schedule Local Notification
    func scheduleLocalNotification(
        title: String,
        body: String,
        category: MenzilimNotificationCategory,
        userInfo: [String: Any] = [:],
        delay: TimeInterval = 0
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category.rawValue
        content.userInfo = userInfo

        let trigger: UNNotificationTrigger?
        if delay > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        } else {
            trigger = nil
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                AppLogger.error("Failed to schedule local notification: \(error.localizedDescription)", category: AppLogger.notification)
            }
        }
    }

    // MARK: - Open System Settings
    func openNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        Task { @MainActor in
            UIApplication.shared.open(settingsURL)
        }
    }
}
