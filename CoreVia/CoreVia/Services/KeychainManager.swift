import Foundation
import Security

/// JWT tokenləri Keychain-də saxlamaq üçün manager
class KeychainManager {
    static let shared = KeychainManager()

    private let accessTokenKey = "com.corevia.accessToken"
    private let refreshTokenKey = "com.corevia.refreshToken"
    private let userIdKey = "com.corevia.userId"
    private let userTypeKey = "com.corevia.userType"

    private init() {}

    // MARK: - User ID (Keychain-də saxla)

    var userId: String? {
        get { load(key: userIdKey) }
        set {
            if let value = newValue {
                save(key: userIdKey, value: value)
            } else {
                delete(key: userIdKey)
            }
        }
    }

    // MARK: - User Type (Keychain-də saxla)

    var userType: String? {
        get { load(key: userTypeKey) }
        set {
            if let value = newValue {
                save(key: userTypeKey, value: value)
            } else {
                delete(key: userTypeKey)
            }
        }
    }

    // MARK: - Access Token

    var accessToken: String? {
        get { load(key: accessTokenKey) }
        set {
            if let value = newValue {
                save(key: accessTokenKey, value: value)
            } else {
                delete(key: accessTokenKey)
            }
        }
    }

    var refreshToken: String? {
        get { load(key: refreshTokenKey) }
        set {
            if let value = newValue {
                save(key: refreshTokenKey, value: value)
            } else {
                delete(key: refreshTokenKey)
            }
        }
    }

    /// Bütün session data-nı sil (logout zamanı)
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        userType = nil
    }

    /// İstifadəçi login olubmu yoxla
    var isLoggedIn: Bool {
        accessToken != nil
    }

    // MARK: - Keychain Operations

    func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
