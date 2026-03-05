import Foundation
import UIKit
import os.log

// iOS-06 fix: Jailbreak detection gücləndirildi
// Qeyd: Hec bir jailbreak detection 100% etibarsiz deyil.
// Frida / Substitute kimi toollar bu yoxlamalari bypass ede biler.
// Bu kod orta seviyyeli mudafie ucun yeterlidir.
// Daha ciddi qoruma ucun: TrustKit, IOSSecuritySuite, ya da backend integrity check.

enum JailbreakDetection {

    static var isJailbroken: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return checkSuspiciousFiles()
            || checkSuspiciousPaths()
            || checkWriteAccess()
            || checkSuspiciousURLSchemes()
            || checkDynamicLibraries()
            || checkForkAbility()
            || checkSandboxViolation()
        #endif
    }

    // MARK: - 1. Bilinen jailbreak fayllarini yoxla
    private static func checkSuspiciousFiles() -> Bool {
        let paths = [
            "/Applications/Cydia.app",
            "/Applications/checkra1n.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/usr/libexec/sftp-server",
            "/var/cache/apt",
            "/var/lib/apt",
            "/var/lib/cydia",
            "/var/tmp/cydia.log",
            "/bin/bash",
            "/bin/sh",
            "/etc/apt",
            "/etc/ssh/sshd_config",
            "/private/var/lib/apt",
            "/private/var/stash",
            "/private/etc/dpkg/info",
            "/var/jb",           // Dopamine / Unc0ver yeni versiyalari
            "/.bootstrapped",    // Unc0ver
            "/private/preboot/procursus"  // Palera1n
        ]

        for path in paths {
            // Direkt yoxla (bezi jailbreak toollar FileManager-i hook edir)
            if FileManager.default.fileExists(atPath: path) {
                AppLogger.general.warning("Jailbreak: suspicious file found")
                return true
            }
            // C seviyyesinde yoxla (hook-lara daha az həssas)
            if access(path, F_OK) == 0 {
                AppLogger.general.warning("Jailbreak: suspicious path accessible via access()")
                return true
            }
        }
        return false
    }

    // MARK: - 2. Sistem yollarini yoxla
    private static func checkSuspiciousPaths() -> Bool {
        let dirs = [
            "/private/var/lib/apt",
            "/private/var/stash",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/Library/MobileSubstrate",
            "/private/var/tmp/cydia.log",
        ]
        for dir in dirs {
            if FileManager.default.fileExists(atPath: dir) {
                return true
            }
        }
        return false
    }

    // MARK: - 3. Sistem qovluqlarina yazma icazesini yoxla
    private static func checkWriteAccess() -> Bool {
        let testPath = "/private/jb_detect_\(UUID().uuidString)"
        do {
            try "x".write(toFile: testPath, atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: testPath)
            AppLogger.general.warning("Jailbreak: write access to /private succeeded")
            return true
        } catch {
            return false
        }
    }

    // MARK: - 4. Jailbreak URL sxemlerini yoxla
    private static func checkSuspiciousURLSchemes() -> Bool {
        let schemes = [
            "cydia://package/com.example.package",
            "sileo://package/com.example.package",
            "zbra://package/com.example.package",
            "filza://",
            "undecimus://",
        ]
        for scheme in schemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                AppLogger.general.warning("Jailbreak: suspicious URL scheme openable")
                return true
            }
        }
        return false
    }

    // MARK: - 5. Inject edilmish dinamik kutubxanalari yoxla
    private static func checkDynamicLibraries() -> Bool {
        let suspiciousLibs = [
            "MobileSubstrate",
            "SubstrateLoader",
            "cycript",
            "cynject",
            "libhooker",
            "SubstrateInserter",
            "SubstrateBootstrap",
            "ABypass",
            "FlyJB",
            "Substitute",
            "libsubstitute",
            "SSLKillSwitch",
            "Frida",
            "frida-gadget",
        ]

        let imageCount = _dyld_image_count()
        for i in 0..<imageCount {
            if let name = _dyld_get_image_name(i) {
                let imageName = String(cString: name).lowercased()
                for lib in suspiciousLibs {
                    if imageName.contains(lib.lowercased()) {
                        AppLogger.general.warning("Jailbreak: suspicious dylib loaded")
                        return true
                    }
                }
            }
        }
        return false
    }

    // MARK: - 6. posix_spawn() ile proses yaratma imkanini yoxla (jailbroken cihazlarda mumkundur)
    private static func checkForkAbility() -> Bool {
        var pid: pid_t = 0
        let argv: [UnsafeMutablePointer<CChar>?] = [nil]
        let status = posix_spawn(&pid, "", nil, nil, argv, nil)
        if status == 0 {
            // posix_spawn ugurlu oldu - sandbox pozulub, jailbreak var
            waitpid(pid, nil, 0)
            AppLogger.general.warning("Jailbreak: posix_spawn() succeeded - device is jailbroken")
            return true
        }
        // posix_spawn ugursuz oldu - normal sandboxed cihaz
        return false
    }

    // MARK: - 7. Sandbox ihlalini yoxla
    private static func checkSandboxViolation() -> Bool {
        // Sandbox-dan kenarda bir fayla yazma cehdi et
        let outOfSandboxPaths = [
            "/etc/test_corevia",
            "/private/test_corevia",
        ]
        for path in outOfSandboxPaths {
            do {
                try "test".write(toFile: path, atomically: true, encoding: .utf8)
                // Eger bura catdiqsa - sandbox ihlali var
                try? FileManager.default.removeItem(atPath: path)
                AppLogger.general.warning("Jailbreak: sandbox violation at \(path)")
                return true
            } catch {
                // Gozlenilen: qeyd olunmur
            }
        }
        return false
    }
}
