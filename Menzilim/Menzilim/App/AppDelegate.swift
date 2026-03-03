import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Application Lifecycle
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupPushNotifications(application)
        configureAppearance()
        return true
    }

    // MARK: - Push Notifications Setup
    private func setupPushNotifications(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if let error = error {
                print("[Menzilim] Push notification authorization error: \(error.localizedDescription)")
                return
            }

            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
                print("[Menzilim] Push notification permission granted")
            } else {
                print("[Menzilim] Push notification permission denied")
            }
        }

        // Set up notification categories for rich notifications
        setupNotificationCategories(center)
    }

    // MARK: - Notification Categories
    private func setupNotificationCategories(_ center: UNUserNotificationCenter) {
        // Price drop notification actions
        let viewListingAction = UNNotificationAction(
            identifier: "VIEW_LISTING",
            title: "Elana bax",
            options: .foreground
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Bagla",
            options: .destructive
        )

        let priceDropCategory = UNNotificationCategory(
            identifier: "PRICE_DROP",
            actions: [viewListingAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // New listing notification actions
        let newListingCategory = UNNotificationCategory(
            identifier: "NEW_LISTING",
            actions: [viewListingAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Message notification actions
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_MESSAGE",
            title: "Cavab yaz",
            options: [],
            textInputButtonTitle: "Gonder",
            textInputPlaceholder: "Mesajiniz..."
        )

        let messageCategory = UNNotificationCategory(
            identifier: "MESSAGE",
            actions: [replyAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        center.setNotificationCategories([
            priceDropCategory,
            newListingCategory,
            messageCategory
        ])
    }

    // MARK: - Global Appearance
    private func configureAppearance() {
        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(red: 10/255, green: 14/255, blue: 26/255, alpha: 1) // #0A0E1A
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(red: 0, green: 212/255, blue: 255/255, alpha: 1) // #00D4FF

        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(red: 13/255, green: 17/255, blue: 23/255, alpha: 1) // #0D1117
        tabAppearance.shadowColor = .clear

        // Tab bar item colors
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1) // #64748B
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0, green: 212/255, blue: 255/255, alpha: 1) // #00D4FF
        ]

        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1)
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0, green: 212/255, blue: 255/255, alpha: 1)

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Text field tint
        UITextField.appearance().tintColor = UIColor(red: 0, green: 212/255, blue: 255/255, alpha: 1)
    }

    // MARK: - Remote Notification Registration
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[Menzilim] Device token: \(token)")
        // Store token for sending to backend after authentication
        UserDefaults.standard.set(token, forKey: "device_push_token")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[Menzilim] Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("[Menzilim] Foreground notification: \(userInfo)")
        completionHandler([.banner, .badge, .sound])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier

        print("[Menzilim] Notification tapped - action: \(actionIdentifier), userInfo: \(userInfo)")

        switch actionIdentifier {
        case "VIEW_LISTING":
            if let listingId = userInfo["listing_id"] as? String {
                handleDeepLink(to: .listing(id: listingId))
            }

        case "REPLY_MESSAGE":
            if let textResponse = response as? UNTextInputNotificationResponse,
               let chatId = userInfo["chat_id"] as? String {
                handleQuickReply(message: textResponse.userText, chatId: chatId)
            }

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            handleNotificationTap(userInfo: userInfo)

        default:
            break
        }

        completionHandler()
    }

    // MARK: - Deep Link Handling
    private func handleDeepLink(to destination: DeepLinkDestination) {
        // Post notification for the app to handle navigation
        NotificationCenter.default.post(
            name: .deepLinkNotification,
            object: nil,
            userInfo: ["destination": destination]
        )
    }

    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        if let listingId = userInfo["listing_id"] as? String {
            handleDeepLink(to: .listing(id: listingId))
        } else if let chatId = userInfo["chat_id"] as? String {
            handleDeepLink(to: .chat(id: chatId))
        }
    }

    private func handleQuickReply(message: String, chatId: String) {
        print("[Menzilim] Quick reply to chat \(chatId): \(message)")
        // TODO: Send message via API
    }
}

// MARK: - Deep Link Destination
enum DeepLinkDestination {
    case listing(id: String)
    case chat(id: String)
    case profile(id: String)
    case notifications
}

// MARK: - Notification Names
extension Notification.Name {
    static let deepLinkNotification = Notification.Name("deepLinkNotification")
}
