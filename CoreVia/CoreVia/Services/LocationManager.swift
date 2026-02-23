//
//  LocationManager.swift
//  CoreVia
//
//  Real GPS izleme servisi - CLLocationManager wrapper
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let manager = CLLocationManager()

    // MARK: - Published state
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTracking: Bool = false
    @Published var currentLocation: CLLocation?
    @Published var totalDistanceMeters: Double = 0.0
    @Published var coordinates: [[Double]] = [] // [[lat, lng, alt, timestamp], ...]

    // Internal
    private var lastLocation: CLLocation?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = 10 // minimum 10 metr arasinda update (GPS drift azaldir)
        authorizationStatus = manager.authorizationStatus
    }

    // MARK: - Public API

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        coordinates = []
        totalDistanceMeters = 0.0
        lastLocation = nil
        isTracking = true
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        isTracking = false
    }

    /// Backend ucun JSON string: "[[lat,lng,alt,ts], ...]"
    var coordinatesJSON: String? {
        guard !coordinates.isEmpty else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: coordinates),
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }

    var distanceKm: Double {
        totalDistanceMeters / 1000.0
    }

    var startCoordinate: CLLocationCoordinate2D? {
        guard let first = coordinates.first, first.count >= 2 else { return nil }
        return CLLocationCoordinate2D(latitude: first[0], longitude: first[1])
    }

    var endCoordinate: CLLocationCoordinate2D? {
        guard let last = coordinates.last, last.count >= 2 else { return nil }
        return CLLocationCoordinate2D(latitude: last[0], longitude: last[1])
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }

        for location in locations {
            // Kohne/cached location-lari at (10 saniyeden kohne)
            guard abs(location.timestamp.timeIntervalSinceNow) < 10 else { continue }

            // Keyfiyyetsiz oxunuslari sil (20m-den pis deqiqlik)
            guard location.horizontalAccuracy >= 0,
                  location.horizontalAccuracy < 20 else { continue }

            // GPS drift filteri: minimum 0.3 m/s suret olmalidir
            guard location.speed >= 0.3 else {
                // Hereket yoxdursa koordinat ve location yenile amma mesafe elave etme
                DispatchQueue.main.async {
                    self.currentLocation = location
                }
                lastLocation = location
                continue
            }

            // Mesafe hesabla
            if let last = lastLocation {
                let delta = location.distance(from: last)
                // Minimum 3m (drift filter) ve maximum 100m (teleportasiya filter)
                guard delta > 3 && delta < 100 else { continue }
                DispatchQueue.main.async {
                    self.totalDistanceMeters += delta
                }
            }

            // Koordinat saxla: [lat, lng, altitude, timestamp]
            let point: [Double] = [
                location.coordinate.latitude,
                location.coordinate.longitude,
                location.altitude,
                location.timestamp.timeIntervalSince1970
            ]

            DispatchQueue.main.async {
                self.coordinates.append(point)
                self.currentLocation = location
            }
            lastLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location xetasi: \(error.localizedDescription)")
    }
}
