import Foundation
import CoreLocation

// MARK: - Location Service
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentCity: String?
    @Published var currentDistrict: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // MARK: - Reverse Geocode
    func reverseGeocode(latitude: Double, longitude: Double) async -> (city: String, district: String, address: String)? {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let city = placemark.locality ?? placemark.administrativeArea ?? ""
                let district = placemark.subLocality ?? placemark.subAdministrativeArea ?? ""
                let address = [placemark.thoroughfare, placemark.subThoroughfare].compactMap { $0 }.joined(separator: " ")
                return (city, district, address)
            }
        } catch {
            AppLogger.error("Geocoding error: \(error.localizedDescription)")
        }
        return nil
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate

        Task {
            if let result = await reverseGeocode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) {
                await MainActor.run {
                    self.currentCity = result.city
                    self.currentDistrict = result.district
                }
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdating()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppLogger.error("Location error: \(error.localizedDescription)")
    }
}
