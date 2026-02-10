import Foundation
import CoreLocation

class MapService {
    static let shared = MapService()
    private let baseURL = "http://localhost:8001"

    private init() {}

    // MARK: - Nearby Properties
    func getNearbyProperties(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 2.0,
        limit: Int = 50
    ) async throws -> NearbyPropertiesResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MapAPIError.unauthorized
        }

        let urlString = "\(baseURL)/map/properties/nearby?latitude=\(latitude)&longitude=\(longitude)&radius_km=\(radiusKm)&limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw MapAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MapAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MapAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(NearbyPropertiesResponse.self, from: data)
    }

    // MARK: - Properties by Metro
    func getPropertiesByMetro(
        metroName: String,
        radiusKm: Double = 1.5,
        limit: Int = 50
    ) async throws -> NearbyPropertiesResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MapAPIError.unauthorized
        }

        let encodedMetro = metroName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? metroName
        let urlString = "\(baseURL)/map/properties/by-metro?metro_name=\(encodedMetro)&radius_km=\(radiusKm)&limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw MapAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MapAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MapAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(NearbyPropertiesResponse.self, from: data)
    }

    // MARK: - Metro Stations
    func getMetroStations() async throws -> [MetroStation] {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MapAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/map/metro/stations") else {
            throw MapAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MapAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MapAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let result = try decoder.decode(MetroStationsResponse.self, from: data)
        return result.stations
    }

    // MARK: - Landmarks
    func getLandmarks(
        latitude: Double? = nil,
        longitude: Double? = nil
    ) async throws -> [LandmarkFull] {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MapAPIError.unauthorized
        }

        var urlString = "\(baseURL)/map/landmarks"
        if let lat = latitude, let lng = longitude {
            urlString += "?latitude=\(lat)&longitude=\(lng)"
        }

        guard let url = URL(string: urlString) else {
            throw MapAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MapAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MapAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let result = try decoder.decode(LandmarkResponse.self, from: data)
        return result.landmarks
    }

    // MARK: - Enrich Property Location
    func enrichPropertyLocation(propertyId: String) async throws {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MapAPIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/map/property/\(propertyId)/enrich") else {
            throw MapAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MapAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MapAPIError.serverError(httpResponse.statusCode)
        }
    }

    // MARK: - Radius Search with Filters
    func radiusSearch(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 3.0,
        propertyType: PropertyType? = nil,
        dealType: DealType? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        minRooms: Int? = nil,
        limit: Int = 50
    ) async throws -> NearbyPropertiesResponse {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw MapAPIError.unauthorized
        }

        var urlString = "\(baseURL)/map/search/radius?latitude=\(latitude)&longitude=\(longitude)&radius_km=\(radiusKm)&limit=\(limit)"

        if let propertyType = propertyType {
            urlString += "&property_type=\(propertyType.rawValue)"
        }
        if let dealType = dealType {
            urlString += "&deal_type=\(dealType.rawValue)"
        }
        if let minPrice = minPrice {
            urlString += "&min_price=\(minPrice)"
        }
        if let maxPrice = maxPrice {
            urlString += "&max_price=\(maxPrice)"
        }
        if let minRooms = minRooms {
            urlString += "&min_rooms=\(minRooms)"
        }

        guard let url = URL(string: urlString) else {
            throw MapAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MapAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MapAPIError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(NearbyPropertiesResponse.self, from: data)
    }
}

// MARK: - Helper Extensions
extension CLLocationCoordinate2D {
    static let bakuCenter = CLLocationCoordinate2D(latitude: 40.4093, longitude: 49.8671)

    func distance(to other: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return location1.distance(from: location2) // meters
    }
}

enum MapAPIError: Error {
    case invalidURL
    case unauthorized
    case invalidResponse
    case serverError(Int)
}
