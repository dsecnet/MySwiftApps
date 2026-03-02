import Foundation
import os.log

/// Centralized logger - print() instead of os.Logger
/// Release build-de log-lar Console.app-da gorunur amma MDM/user-e aciq olmur
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "life.corevia.app"

    static let general = Logger(subsystem: subsystem, category: "general")
    static let network = Logger(subsystem: subsystem, category: "network")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let websocket = Logger(subsystem: subsystem, category: "websocket")
    static let ml = Logger(subsystem: subsystem, category: "ml")
    static let location = Logger(subsystem: subsystem, category: "location")
    static let food = Logger(subsystem: subsystem, category: "food")
    static let training = Logger(subsystem: subsystem, category: "training")
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
