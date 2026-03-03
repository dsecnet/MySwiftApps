import Foundation
import os.log

// MARK: - App Logger
struct AppLogger {
    private static let subsystem = "com.menzilim.app"

    static let auth = Logger(subsystem: subsystem, category: "Auth")
    static let api = Logger(subsystem: subsystem, category: "API")
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let storage = Logger(subsystem: subsystem, category: "Storage")
    static let payment = Logger(subsystem: subsystem, category: "Payment")
    static let notification = Logger(subsystem: subsystem, category: "Notification")

    static func log(_ message: String, category: Logger = api) {
        category.info("\(message)")
    }

    static func error(_ message: String, category: Logger = api) {
        category.error("\(message)")
    }

    static func debug(_ message: String, category: Logger = api) {
        #if DEBUG
        category.debug("\(message)")
        #endif
    }
}
