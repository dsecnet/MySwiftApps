import Foundation
import UIKit
import os.log

enum JailbreakDetection {

    /// Check if device is jailbroken
    static var isJailbroken: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return checkSuspiciousFiles() || checkSuspiciousPaths() || checkWriteAccess() || checkSuspiciousApps()
        #endif
    }

    // MARK: - Check suspicious files
    private static func checkSuspiciousFiles() -> Bool {
        let suspiciousFiles = [
            "/Applications/Cydia.app",
            "/Applications/checkra1n.app",
            "/Applications/Sileo.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/var/cache/apt",
            "/var/lib/apt",
            "/var/lib/cydia",
            "/var/tmp/cydia.log",
            "/bin/bash",
            "/usr/libexec/sftp-server",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]

        return suspiciousFiles.contains { FileManager.default.fileExists(atPath: $0) }
    }

    // MARK: - Check URL schemes
    private static func checkSuspiciousApps() -> Bool {
        let suspiciousSchemes = [
            "cydia://package/com.example.package",
            "sileo://package/com.example.package",
            "filza://",
            "undecimus://"
        ]

        return suspiciousSchemes.contains { scheme in
            guard let url = URL(string: scheme) else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }

    // MARK: - Check suspicious paths
    private static func checkSuspiciousPaths() -> Bool {
        let paths = ["/private/var/lib/apt", "/private/var/stash"]
        return paths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    // MARK: - Check write access to system directories
    private static func checkWriteAccess() -> Bool {
        let testPath = "/private/jailbreak_test_\(UUID().uuidString)"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true // Should not be writable on non-jailbroken device
        } catch {
            AppLogger.general.error("Jailbreak write access check xetasi: \(error.localizedDescription)")
            return false
        }
    }
}
