import Foundation
import Security

// MARK: - Keychain Manager
class KeychainManager {
    static let shared = KeychainManager()

    private let accessTokenKey = "com.menzilim.accessToken"
    private let refreshTokenKey = "com.menzilim.refreshToken"
    private let userIdKey = "com.menzilim.userId"

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

    // MARK: - Refresh Token
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

    // MARK: - User ID
    var userId: String? {
        get { read(key: userIdKey) }
        set {
            if let value = newValue {
                save(key: userIdKey, value: value)
            } else {
                delete(key: userIdKey)
            }
        }
    }

    // MARK: - Clear All
    func clearAll() {
        accessToken = nil
        refreshToken = nil
        userId = nil
    }

    // MARK: - Keychain Operations
    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
