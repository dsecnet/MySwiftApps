import Foundation

class CacheManager {
    static let shared = CacheManager()

    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default

    // Cache keys
    private enum CacheKey: String, CaseIterable {
        case properties = "cached_properties"
        case clients = "cached_clients"
        case activities = "cached_activities"
        case deals = "cached_deals"
        case dashboardStats = "cached_dashboard_stats"
        case lastSync = "last_sync_date"
    }

    private init() {}

    // MARK: - Cache Directory
    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDir = paths[0].appendingPathComponent("EmlakCRM")

        if !fileManager.fileExists(atPath: cacheDir.path) {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }

        return cacheDir
    }

    // MARK: - Generic Cache Methods
    func cache<T: Codable>(_ data: T, forKey key: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let encoded = try? encoder.encode(data) {
            let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
            try? encoded.write(to: fileURL)

            // Store last update time
            userDefaults.set(Date(), forKey: "\(key)_timestamp")
        }
    }

    func getCached<T: Codable>(forKey key: String, type: T.Type) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try? decoder.decode(T.self, from: data)
    }

    func getCacheAge(forKey key: String) -> TimeInterval? {
        guard let timestamp = userDefaults.object(forKey: "\(key)_timestamp") as? Date else {
            return nil
        }
        return Date().timeIntervalSince(timestamp)
    }

    func isCacheValid(forKey key: String, maxAge: TimeInterval = 300) -> Bool {
        guard let age = getCacheAge(forKey: key) else { return false }
        return age < maxAge
    }

    func clearCache(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        try? fileManager.removeItem(at: fileURL)
        userDefaults.removeObject(forKey: "\(key)_timestamp")
    }

    func clearAllCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        CacheKey.allCases.forEach { key in
            userDefaults.removeObject(forKey: "\(key.rawValue)_timestamp")
        }
    }

    // MARK: - Specific Cache Methods
    func cacheProperties(_ properties: [Property]) {
        cache(properties, forKey: CacheKey.properties.rawValue)
    }

    func getCachedProperties() -> [Property]? {
        getCached(forKey: CacheKey.properties.rawValue, type: [Property].self)
    }

    func cacheClients(_ clients: [Client]) {
        cache(clients, forKey: CacheKey.clients.rawValue)
    }

    func getCachedClients() -> [Client]? {
        getCached(forKey: CacheKey.clients.rawValue, type: [Client].self)
    }

    func cacheActivities(_ activities: [Activity]) {
        cache(activities, forKey: CacheKey.activities.rawValue)
    }

    func getCachedActivities() -> [Activity]? {
        getCached(forKey: CacheKey.activities.rawValue, type: [Activity].self)
    }

    func cacheDeals(_ deals: [Deal]) {
        cache(deals, forKey: CacheKey.deals.rawValue)
    }

    func getCachedDeals() -> [Deal]? {
        getCached(forKey: CacheKey.deals.rawValue, type: [Deal].self)
    }

    func cacheDashboardStats(_ stats: DashboardStats) {
        cache(stats, forKey: CacheKey.dashboardStats.rawValue)
    }

    func getCachedDashboardStats() -> DashboardStats? {
        getCached(forKey: CacheKey.dashboardStats.rawValue, type: DashboardStats.self)
    }

    // MARK: - Last Sync
    func updateLastSyncDate() {
        userDefaults.set(Date(), forKey: CacheKey.lastSync.rawValue)
    }

    func getLastSyncDate() -> Date? {
        userDefaults.object(forKey: CacheKey.lastSync.rawValue) as? Date
    }

    func getLastSyncText() -> String {
        guard let lastSync = getLastSyncDate() else {
            return "Heç vaxt"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "az")
        return formatter.localizedString(for: lastSync, relativeTo: Date())
    }
}
