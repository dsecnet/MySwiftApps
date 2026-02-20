//
//  LiveTrackingView.swift
//  CoreVia
//
//  GPS ilə canlı məsafə və kalori izləmə
//

import SwiftUI
import MapKit
import CoreLocation

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
                Text("Canlı İzləmə")
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

                        Text("Kilometr")
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

                        Text("Kalori")
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

                        Text("Vaxt")
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

                        Text("km/s")
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
                                Text("Başla")
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
                                Text(isPaused ? "Davam" : "Pauza")
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
                                Text("Bitir")
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
            }
        }
        .alert("Məşqi saxla", isPresented: $showSaveDialog) {
            Button("Ləğv et", role: .cancel) {
                dismiss()
            }
            Button("Saxla") {
                // TODO: Save to backend
                saveWorkout()
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
            title: "GPS Məşq – \(String(format: "%.2f", locationManager.distance)) km",
            category: .cardio,
            duration: durationMinutes,
            caloriesBurned: locationManager.calories,
            notes: "Məsafə: \(String(format: "%.2f", locationManager.distance)) km | Sürət: \(String(format: "%.1f", locationManager.speed)) km/s",
            date: Date(),
            isCompleted: true
        )
        workoutManager.addWorkout(newWorkout)
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
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Location Manager
class LiveTrackingManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4093, longitude: 49.8671), // Baku
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    @Published var distance: Double = 0.0 // km
    @Published var calories: Int = 0
    @Published var duration: Int = 0 // seconds
    @Published var speed: Double = 0.0 // km/h
    @Published var isTracking = false
    @Published var routePoints: [RoutePoint] = []

    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var timer: Timer?
    private var isPaused = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        isTracking = true
        isPaused = false
        distance = 0
        calories = 0
        duration = 0
        routePoints = []
        lastLocation = nil

        manager.startUpdatingLocation()

        // Timer for duration
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.duration += 1
        }
    }

    func pauseTracking() {
        isPaused = true
        manager.stopUpdatingLocation()
    }

    func resumeTracking() {
        isPaused = false
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        isTracking = false
        isPaused = false
        manager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isPaused else { return }

        // Update region
        region.center = location.coordinate

        // Calculate distance
        if let last = lastLocation {
            let delta = location.distance(from: last) / 1000.0 // Convert to km
            if delta < 0.1 { // Ignore unrealistic jumps
                distance += delta

                // Calculate calories (rough estimate: 60 kcal per km)
                calories = Int(distance * 60)

                // Add point to route
                routePoints.append(RoutePoint(coordinate: location.coordinate))
            }
        }

        lastLocation = location

        // Calculate speed
        if location.speed > 0 {
            speed = location.speed * 3.6 // m/s to km/h
        }
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
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.7)
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
