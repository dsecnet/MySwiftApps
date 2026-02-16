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
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isPaused = false
    @State private var showSaveDialog = false

    var body: some View {
        ZStack {
            // Map background
            Map(coordinateRegion: $locationManager.region,
                showsUserLocation: true,
                annotationItems: locationManager.routePoints) { point in
                MapMarker(coordinate: point.coordinate, tint: .blue)
            }
            .ignoresSafeArea()

            VStack {
                // Top stats card
                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        StatBox(
                            icon: "figure.run",
                            value: String(format: "%.2f", locationManager.distance),
                            unit: "km",
                            color: .blue
                        )

                        StatBox(
                            icon: "flame.fill",
                            value: "\(locationManager.calories)",
                            unit: "kcal",
                            color: .orange
                        )
                    }

                    HStack(spacing: 20) {
                        StatBox(
                            icon: "timer",
                            value: timeString(from: locationManager.duration),
                            unit: "",
                            color: .green
                        )

                        StatBox(
                            icon: "speedometer",
                            value: String(format: "%.1f", locationManager.speed),
                            unit: "km/h",
                            color: .purple
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()

                Spacer()

                // Bottom controls
                HStack(spacing: 20) {
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
                            .padding()
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
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
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
                .padding()
                .background(.ultraThinMaterial)
            }
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
        // TODO: Backend-ə save et
        print("💾 Saving workout: \(locationManager.distance)km, \(locationManager.calories)kcal")
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

#Preview {
    NavigationStack {
        LiveTrackingView()
    }
}
