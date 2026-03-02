//
//  LiveTrackingView.swift
//  CoreVia
//
//  GPS ilə canlı məsafə və kalori izləmə
//

import SwiftUI
import MapKit
import CoreLocation
import CoreMotion

struct LiveTrackingView: View {

    @StateObject private var locationManager = LiveTrackingManager()
    @StateObject private var workoutManager = WorkoutManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isPaused = false
    @State private var showSaveDialog = false

    var body: some View {
        // FIX D: ZStack + GeometryReader - düymə həmişə görünür
        GeometryReader { geometry in
            
        ZStack(alignment: .bottom) {
            // FIX 7: NEW LAYOUT - Map in top 40%, Stats card in bottom 60%
            VStack(spacing: 0) {
                // FIX 7: Map section (40% of AVAILABLE height) - windowed at top
                ZStack {
                    // FIX 6: Map with route polyline overlay
                    MapViewWithRoute(
                        region: $locationManager.region,
                        routePoints: locationManager.routePoints
                    )
                    .frame(
                        height: (geometry.size.height
                                 - geometry.safeAreaInsets.top
                                 - geometry.safeAreaInsets.bottom) * 0.35
                    )

                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding()
                }
                .background(AppTheme.Colors.background)

            // FIX 7: Large stats card section (60% of screen)
            VStack(spacing: 10) {
                Text(loc.localized("tracking_live"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                // Distance & Calories
                HStack(spacing: 10) {
                    VStack(spacing: 4) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)

                        Text(String(format: "%.2f", locationManager.distance))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(loc.localized("tracking_kilometer"))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(14)

                    VStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.orange)

                        Text("\(locationManager.calories)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(loc.localized("tracking_calorie"))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(14)
                }

                // Time & Speed
                HStack(spacing: 10) {
                    VStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 22))
                            .foregroundColor(.green)

                        Text(timeString(from: locationManager.duration))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(loc.localized("tracking_time"))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(14)

                    VStack(spacing: 4) {
                        Image(systemName: "speedometer")
                            .font(.system(size: 22))
                            .foregroundColor(.purple)

                        Text(String(format: "%.1f", locationManager.speed))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text("km/h")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(14)
                }

                // Steps
                HStack(spacing: 10) {
                    VStack(spacing: 4) {
                        Image(systemName: "shoeprints.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.cyan)

                        Text("\(locationManager.steps)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(loc.localized("tracking_steps"))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(14)
                }

                Spacer()

                // Buttons inside stats section
                HStack(spacing: 16) {
                    if !locationManager.isTracking {
                        // Start button
                        Button {
                            locationManager.startTracking()
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text(loc.localized("tracking_start"))
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .padding(.bottom, 30)
                            .background(Color.green)
                            .cornerRadius(16)
                        }
                    } else {
                        // Pause/Resume button
                        Button {
                            if isPaused {
                                locationManager.resumeTracking()
                            } else {
                                locationManager.pauseTracking()
                            }
                            isPaused.toggle()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                    .font(.system(size: 24))
                                Text(isPaused ? loc.localized("tracking_resume") : loc.localized("tracking_pause"))
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.orange)
                            .clipShape(Circle())
                        }

                        // Stop button
                        Button {
                            locationManager.stopTracking()
                            showSaveDialog = true
                        } label: {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text(loc.localized("tracking_stop"))
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(
                height: (geometry.size.height
                         - geometry.safeAreaInsets.top
                         - geometry.safeAreaInsets.bottom) * 0.6
            )
            .background(AppTheme.Colors.secondaryBackground)
            }
            .background(AppTheme.Colors.background)
        } // ZStack end
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if locationManager.isTracking {
                        locationManager.stopTracking()
                    }
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(AppTheme.Colors.primaryText)
                }
                .accessibilityLabel("Close")
            }
        }
        .alert(loc.localized("tracking_save_workout"), isPresented: $showSaveDialog) {
            Button(loc.localized("common_cancel"), role: .cancel) {
                dismiss()
            }
            Button(loc.localized("common_save")) {
                saveWorkout()
                saveRouteToBackend()
                dismiss()
            }
        } message: {
            Text("\(String(format: "%.2f", locationManager.distance)) km, \(locationManager.calories) kcal")
        }
    }

    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    private func saveWorkout() {
        let durationMinutes = max(1, locationManager.duration / 60)
        let newWorkout = Workout(
            id: UUID().uuidString,
            userId: nil,
            title: "\(loc.localized("tracking_gps_workout")) – \(String(format: "%.2f", locationManager.distance)) km",
            category: .cardio,
            duration: durationMinutes,
            caloriesBurned: locationManager.calories,
            notes: "\(loc.localized("tracking_distance")): \(String(format: "%.2f", locationManager.distance)) km | \(loc.localized("tracking_speed")): \(String(format: "%.1f", locationManager.speed)) km/h",
            date: Date(),
            isCompleted: true
        )
        workoutManager.addWorkout(newWorkout)
    }

    /// Save route data to backend via RouteManager (mirrors ActivitiesView.stopTracking pattern)
    private func saveRouteToBackend() {
        guard locationManager.duration > 10 else { return }

        // Build coordinates JSON from route points
        let coordsArray = locationManager.routePoints.map { [$0.coordinate.latitude, $0.coordinate.longitude] }
        let coordinatesJson: String? = {
            guard !coordsArray.isEmpty,
                  let data = try? JSONSerialization.data(withJSONObject: coordsArray),
                  let json = String(data: data, encoding: .utf8) else { return nil }
            return json
        }()

        let startCoord = locationManager.routePoints.first?.coordinate
        let endCoord = locationManager.routePoints.last?.coordinate

        let request = RouteCreateRequest(
            activityType: "walking",
            startLatitude: startCoord?.latitude ?? locationManager.region.center.latitude,
            startLongitude: startCoord?.longitude ?? locationManager.region.center.longitude,
            endLatitude: endCoord?.latitude,
            endLongitude: endCoord?.longitude,
            coordinatesJson: coordinatesJson,
            distanceKm: locationManager.distance,
            durationSeconds: locationManager.duration,
            startedAt: Date().addingTimeInterval(-Double(locationManager.duration)),
            finishedAt: Date()
        )

        RouteManager.shared.saveRoute(request)
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Location Manager
class LiveTrackingManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Config Defaults
    private enum Defaults {
        static let weight: Double = 70.0          // kg - fallback if profile not loaded
        static let defaultLatitude: Double = 40.4093  // Baku center
        static let defaultLongitude: Double = 49.8671
        static let mapSpanDelta: Double = 0.01
        static let distanceFilter: Double = 10.0  // meters between GPS updates
        static let maxLocationAge: TimeInterval = 10.0  // seconds
        static let maxAccuracy: Double = 20.0     // meters
        static let minSpeed: Double = 0.3         // m/s (~1 km/h)
        static let minDelta: Double = 0.003       // km (3m drift filter)
        static let maxDelta: Double = 0.1         // km (100m teleport filter)
    }

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: Defaults.defaultLatitude, longitude: Defaults.defaultLongitude),
        span: MKCoordinateSpan(latitudeDelta: Defaults.mapSpanDelta, longitudeDelta: Defaults.mapSpanDelta)
    )

    @Published var distance: Double = 0.0 // km
    @Published var calories: Int = 0
    @Published var duration: Int = 0 // seconds
    @Published var speed: Double = 0.0 // km/h
    @Published var isTracking = false
    @Published var routePoints: [RoutePoint] = []
    @Published var steps: Int = 0
    @Published var userWeight: Double = Defaults.weight

    private let manager = CLLocationManager()
    private let pedometer = CMPedometer()
    private var lastLocation: CLLocation?
    private var timer: Timer?
    private var isPaused = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = Defaults.distanceFilter
        manager.activityType = .fitness
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        isTracking = true
        isPaused = false
        distance = 0
        calories = 0
        duration = 0
        steps = 0
        routePoints = []
        lastLocation = nil

        // Load user weight from AuthManager if available
        if let weight = AuthManager.shared.currentUser?.weight, weight > 0 {
            userWeight = weight
        }

        manager.startUpdatingLocation()

        // Start pedometer for step counting
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                DispatchQueue.main.async {
                    self.steps = data.numberOfSteps.intValue
                }
            }
        }

        // Timer for duration
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.duration += 1
        }
    }

    func pauseTracking() {
        isPaused = true
        manager.stopUpdatingLocation()
        pedometer.stopUpdates()
    }

    func resumeTracking() {
        isPaused = false
        manager.startUpdatingLocation()

        // Restart pedometer from current point (accumulates with existing steps)
        if CMPedometer.isStepCountingAvailable() {
            let currentSteps = steps
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                DispatchQueue.main.async {
                    self.steps = currentSteps + data.numberOfSteps.intValue
                }
            }
        }
    }

    func stopTracking() {
        isTracking = false
        isPaused = false
        manager.stopUpdatingLocation()
        pedometer.stopUpdates()
        timer?.invalidate()
        timer = nil
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isPaused else { return }

        // Kohne/cached location-lari at
        guard abs(location.timestamp.timeIntervalSinceNow) < Defaults.maxLocationAge else { return }

        // Keyfiyyetsiz GPS oxunuslarini at
        guard location.horizontalAccuracy >= 0,
              location.horizontalAccuracy < Defaults.maxAccuracy else { return }

        // Update region
        region.center = location.coordinate

        // Calculate speed
        if location.speed >= 0 {
            speed = location.speed * 3.6 // m/s to km/h
        }

        // GPS drift filteri: istifadeci minimum speed suretde hereket etmelidir
        guard location.speed >= Defaults.minSpeed else {
            lastLocation = location
            return
        }

        // Calculate distance
        if let last = lastLocation {
            let delta = location.distance(from: last) / 1000.0 // Convert to km
            // Drift filter ve teleportasiya filter
            if delta > Defaults.minDelta && delta < Defaults.maxDelta {
                distance += delta

                // Calculate calories using MET formula
                let hours = Double(duration) / 3600.0
                let speedKmH = hours > 0 ? distance / hours : 0.0

                // Dynamic MET based on speed
                let metValue: Double
                if speedKmH < 3.0 {
                    metValue = 2.0  // slow walk
                } else if speedKmH < 5.0 {
                    metValue = 3.5  // normal walk
                } else if speedKmH < 6.5 {
                    metValue = 4.3  // brisk walk
                } else if speedKmH < 8.0 {
                    metValue = 5.0  // very brisk walk
                } else if speedKmH < 10.0 {
                    metValue = 8.3  // jogging
                } else {
                    metValue = 9.8  // running
                }

                let metCalories = Int(metValue * userWeight * hours)
                let stepCalories = Int(Double(steps) * 0.04)
                calories = max(metCalories, stepCalories)

                // Add point to route
                routePoints.append(RoutePoint(coordinate: location.coordinate))
            }
        }

        lastLocation = location
    }
}

struct RoutePoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// FIX 6: NEW - MapView with Route Polyline Overlay
struct MapViewWithRoute: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let routePoints: [RoutePoint]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)

        // FIX 6: Remove old overlays
        mapView.removeOverlays(mapView.overlays)

        // FIX 6: Add route polyline if we have points
        if routePoints.count > 1 {
            let coordinates = routePoints.map { $0.coordinate }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // FIX 6: Coordinator to handle polyline rendering
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(AppTheme.Colors.accent).withAlphaComponent(0.7)
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

#Preview {
    NavigationStack {
        LiveTrackingView()
    }
}
