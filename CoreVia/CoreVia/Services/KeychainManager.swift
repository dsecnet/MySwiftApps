import Foundation
import Security

/// JWT tokenləri Keychain-də saxlamaq üçün manager
class KeychainManager {
    static let shared = KeychainManager()

    private let accessTokenKey = "com.corevia.accessToken"
    private let refreshTokenKey = "com.corevia.refreshToken"

    private init() {}

    // MARK: - Access Token

    var accessToken: String? {
        get { read(key: accessTokenKey) }
        set {
            if let value = newValue {
                save(key: accessTokenKey, value: value)
            } else {
                delete(key: accessTokenKey)
            }
        }
    }

    var refreshToken: String? {
        get { read(key: refreshTokenKey) }
        set {
            if let value = newValue {
                save(key: refreshTokenKey, value: value)
            } else {
                delete(key: refreshTokenKey)
            }
        }
    }

    /// Hər iki tokeni sil (logout zamanı)
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }

    /// İstifadəçi login olubmu yoxla
    var isLoggedIn: Bool {
        accessToken != nil
    }

    // MARK: - Keychain Operations

    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Əvvəlcə köhnəni sil
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
