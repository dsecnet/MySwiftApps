import Foundation
import os.log

// iOS-07 fix: Sensitive melumatlar (email, user ID, token) log-larda
// %{private} format specifier ile maskelenib.
// Release build-lerde bu degerler Console.app-da "redacted" gorunur.

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "life.corevia.app"

    static let general  = Logger(subsystem: subsystem, category: "general")
    static let network  = Logger(subsystem: subsystem, category: "network")
    static let auth     = Logger(subsystem: subsystem, category: "auth")
    static let websocket = Logger(subsystem: subsystem, category: "websocket")
    static let ml       = Logger(subsystem: subsystem, category: "ml")
    static let location = Logger(subsystem: subsystem, category: "location")
    static let food     = Logger(subsystem: subsystem, category: "food")
    static let training = Logger(subsystem: subsystem, category: "training")
    static let ui       = Logger(subsystem: subsystem, category: "ui")
}

// MARK: - Secure Log Helpers
// Bu extension-u email, user ID ve digər həssas məlumatları
// log-a yazmadan önce maskəlemek üçün istifade et.
extension Logger {

    /// Email-i maskeleyerək log-a yaz.
    /// Nümunə: "u***@example.com"
    func secureEmail(_ email: String, level: OSLogType = .debug, message: String) {
        let masked = maskEmail(email)
        self.log(level: level, "\(message): \(masked, privacy: .public)")
    }

    /// User ID-nin ilk 8 simvolunu log-a yaz, qalanini gizlet.
    func secureUserId(_ userId: String, level: OSLogType = .debug, message: String) {
        let preview = userId.count > 8 ? String(userId.prefix(8)) + "..." : userId
        self.log(level: level, "\(message): \(preview, privacy: .public)")
    }

    /// Sensitive string-i tamamilə gizlet (token, şifrə və s.)
    func redacted(_ message: String) {
        self.log(level: .debug, "\(message, privacy: .private)")
    }

    // MARK: - Private Helpers
    private func maskEmail(_ email: String) -> String {
        guard let atIndex = email.firstIndex(of: "@") else {
            return "***"
        }
        let localPart = String(email[email.startIndex..<atIndex])
        let domain = String(email[atIndex...])
        if localPart.count <= 1 {
            return "*\(domain)"
        }
        let first = String(localPart.prefix(1))
        return "\(first)***\(domain)"
    }
}
