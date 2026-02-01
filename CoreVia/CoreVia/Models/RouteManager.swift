//
//  RouteManager.swift
//  CoreVia
//
//  Marsrut modelleri ve API manager - Backend ile
//

import Foundation

// MARK: - Route Create Request
struct RouteCreateRequest: Encodable {
    let activityType: String
    let startLatitude: Double
    let startLongitude: Double
    let endLatitude: Double?
    let endLongitude: Double?
    let coordinatesJson: String?
    let distanceKm: Double
    let durationSeconds: Int
    let startedAt: Date
    let finishedAt: Date?

    enum CodingKeys: String, CodingKey {
        case activityType = "activity_type"
        case startLatitude = "start_latitude"
        case startLongitude = "start_longitude"
        case endLatitude = "end_latitude"
        case endLongitude = "end_longitude"
        case coordinatesJson = "coordinates_json"
        case distanceKm = "distance_km"
        case durationSeconds = "duration_seconds"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
    }
}

// MARK: - Route Response
struct RouteResponse: Codable, Identifiable {
    let id: String
    let userId: String
    let workoutId: String?
    let name: String?
    let activityType: String
    let startLatitude: Double
    let startLongitude: Double
    let endLatitude: Double?
    let endLongitude: Double?
    let coordinatesJson: String?
    let distanceKm: Double
    let durationSeconds: Int
    let avgPace: Double?
    let maxPace: Double?
    let avgSpeedKmh: Double?
    let maxSpeedKmh: Double?
    let elevationGain: Double?
    let elevationLoss: Double?
    let caloriesBurned: Int?
    let staticMapUrl: String?
    let isAssigned: Bool?
    let isCompleted: Bool?
    let startedAt: Date
    let finishedAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name
        case userId = "user_id"
        case workoutId = "workout_id"
        case activityType = "activity_type"
        case startLatitude = "start_latitude"
        case startLongitude = "start_longitude"
        case endLatitude = "end_latitude"
        case endLongitude = "end_longitude"
        case coordinatesJson = "coordinates_json"
        case distanceKm = "distance_km"
        case durationSeconds = "duration_seconds"
        case avgPace = "avg_pace"
        case maxPace = "max_pace"
        case avgSpeedKmh = "avg_speed_kmh"
        case maxSpeedKmh = "max_speed_kmh"
        case elevationGain = "elevation_gain"
        case elevationLoss = "elevation_loss"
        case caloriesBurned = "calories_burned"
        case staticMapUrl = "static_map_url"
        case isAssigned = "is_assigned"
        case isCompleted = "is_completed"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
        case createdAt = "created_at"
    }
}

// MARK: - Route Stats Response
struct RouteStatsResponse: Codable {
    let totalRoutes: Int
    let totalDistanceKm: Double
    let totalDurationSeconds: Int
    let totalCalories: Int
    let avgPace: Double?
    let avgSpeedKmh: Double?
    let longestRouteKm: Double
    let activityBreakdown: [String: Int]

    enum CodingKeys: String, CodingKey {
        case totalRoutes = "total_routes"
        case totalDistanceKm = "total_distance_km"
        case totalDurationSeconds = "total_duration_seconds"
        case totalCalories = "total_calories"
        case avgPace = "avg_pace"
        case avgSpeedKmh = "avg_speed_kmh"
        case longestRouteKm = "longest_route_km"
        case activityBreakdown = "activity_breakdown"
    }
}

// MARK: - Route Manager
class RouteManager: ObservableObject {

    static let shared = RouteManager()

    @Published var routes: [RouteResponse] = []
    @Published var weeklyStats: RouteStatsResponse?
    @Published var isLoading: Bool = false

    private let api = APIService.shared

    init() {
        loadRoutes()
        loadWeeklyStats()
    }

    // MARK: - Backend-den marsrutlari yukle
    func loadRoutes() {
        guard KeychainManager.shared.isLoggedIn else { return }

        isLoading = true
        Task {
            do {
                let fetched: [RouteResponse] = try await api.request(
                    endpoint: "/api/v1/routes/"
                )
                await MainActor.run {
                    self.routes = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
                print("Routes yukleme xetasi: \(error)")
            }
        }
    }

    // MARK: - Heftelik statistika yukle
    func loadWeeklyStats() {
        guard KeychainManager.shared.isLoggedIn else { return }

        Task {
            do {
                let stats: RouteStatsResponse = try await api.request(
                    endpoint: "/api/v1/routes/stats?days=7"
                )
                await MainActor.run {
                    self.weeklyStats = stats
                }
            } catch {
                print("Route stats xetasi: \(error)")
            }
        }
    }

    // MARK: - Tamamlanmis marsrutu backend-e gonder
    func saveRoute(_ request: RouteCreateRequest) {
        Task {
            do {
                let created: RouteResponse = try await api.request(
                    endpoint: "/api/v1/routes/",
                    method: "POST",
                    body: request
                )
                await MainActor.run {
                    self.routes.insert(created, at: 0)
                }
                loadWeeklyStats()
            } catch {
                print("Route saxlama xetasi: \(error)")
            }
        }
    }

    // MARK: - Marsrut sil
    func deleteRoute(_ route: RouteResponse) {
        routes.removeAll { $0.id == route.id }

        Task {
            do {
                try await api.requestVoid(endpoint: "/api/v1/routes/\(route.id)")
            } catch {
                print("Route silme xetasi: \(error)")
            }
        }
    }

    func clearAllRoutes() {
        routes = []
        weeklyStats = nil
    }
}
