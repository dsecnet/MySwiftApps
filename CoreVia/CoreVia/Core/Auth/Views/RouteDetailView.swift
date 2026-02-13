//
//  RouteDetailView.swift
//  CoreVia
//
//  Tamamlanmis marsrutu xeritede goster + statistika
//

import SwiftUI
import MapKit

struct RouteDetailView: View {

    let route: RouteResponse
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var region: MKCoordinateRegion = MKCoordinateRegion()

    private var coordinates: [CLLocationCoordinate2D] {
        parseCoordinates()
    }

    private var mapRegion: MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: route.startLatitude, longitude: route.startLongitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        let lats = coordinates.map { $0.latitude }
        let lngs = coordinates.map { $0.longitude }
        guard let minLat = lats.min(),
              let maxLat = lats.max(),
              let minLng = lngs.min(),
              let maxLng = lngs.max() else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: route.startLatitude, longitude: route.startLongitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.005),
            longitudeDelta: max((maxLng - minLng) * 1.4, 0.005)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                mapSection
                statsGrid
                detailsSection
            }
            .padding()
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle(activityTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Map Section
    private var mapSection: some View {
        Group {
            if !coordinates.isEmpty {
                RouteMapView(coordinates: coordinates, region: mapRegion)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            } else if let mapUrl = route.staticMapUrl, let url = URL(string: mapUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .failure:
                        mapPlaceholder
                    default:
                        ProgressView()
                            .frame(height: 300)
                    }
                }

            } else {
                mapPlaceholder
            }
        }
    }

    private var mapPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.Colors.secondaryBackground)
                .frame(height: 200)

            VStack(spacing: 8) {
                Image(systemName: "map")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.Colors.tertiaryText)
                Text(loc.localized("route_no_map"))
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                RouteStatCard(
                    icon: "location.fill",
                    value: String(format: "%.2f", route.distanceKm),
                    unit: "km",
                    label: "Mesafe",
                    color: AppTheme.Colors.accent
                )

                RouteStatCard(
                    icon: "clock.fill",
                    value: formatDuration(route.durationSeconds),
                    unit: "",
                    label: "Muddet",
                    color: AppTheme.Colors.accent
                )
            }

            HStack(spacing: 12) {
                RouteStatCard(
                    icon: "speedometer",
                    value: route.avgPace.map { String(format: "%.1f", $0) } ?? "--",
                    unit: "deq/km",
                    label: "Orta Temp",
                    color: AppTheme.Colors.accent
                )

                RouteStatCard(
                    icon: "flame.fill",
                    value: route.caloriesBurned.map { "\($0)" } ?? "--",
                    unit: "kkal",
                    label: "Kalori",
                    color: AppTheme.Colors.accent
                )
            }

            HStack(spacing: 12) {
                RouteStatCard(
                    icon: "arrow.up.right",
                    value: route.elevationGain.map { String(format: "%.0f", $0) } ?? "--",
                    unit: "m",
                    label: "Yukselis",
                    color: AppTheme.Colors.accent
                )

                RouteStatCard(
                    icon: "hare.fill",
                    value: route.avgSpeedKmh.map { String(format: "%.1f", $0) } ?? "--",
                    unit: "km/s",
                    label: "Orta Suret",
                    color: AppTheme.Colors.accent
                )
            }
        }
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("route_details"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            VStack(spacing: 0) {
                detailRow(label: "Aktivite", value: activityTitle)
                Divider().padding(.horizontal)
                detailRow(label: "Baslama", value: formatDate(route.startedAt))

                if let finished = route.finishedAt {
                    Divider().padding(.horizontal)
                    detailRow(label: "Bitis", value: formatDate(finished))
                }

                if let maxSpeed = route.maxSpeedKmh {
                    Divider().padding(.horizontal)
                    detailRow(label: "Max Suret", value: String(format: "%.1f km/s", maxSpeed))
                }

                if let maxPace = route.maxPace {
                    Divider().padding(.horizontal)
                    detailRow(label: "Max Temp", value: String(format: "%.1f deq/km", maxPace))
                }

                if let elLoss = route.elevationLoss {
                    Divider().padding(.horizontal)
                    detailRow(label: "Enis", value: String(format: "%.0f m", elLoss))
                }
            }
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Helpers

    private var activityTitle: String {
        switch route.activityType {
        case "walking": return "Yerish"
        case "running": return "Qacis"
        case "cycling": return "Velosiped"
        default: return route.activityType.capitalized
        }
    }

    private func parseCoordinates() -> [CLLocationCoordinate2D] {
        guard let json = route.coordinatesJson,
              let data = json.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[Double]] else {
            return []
        }

        return array.compactMap { point in
            guard point.count >= 2 else { return nil }
            return CLLocationCoordinate2D(latitude: point[0], longitude: point[1])
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60

        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Route Stat Card
struct RouteStatCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

// #Preview { // iOS 17+ only
//     NavigationStack {
//         RouteDetailView(route: RouteResponse(
//             id: "preview-1",
//             userId: "user-1",
//             workoutId: nil,
//             name: nil,
//             activityType: "running",
//             startLatitude: 40.4093,
//             startLongitude: 49.8671,
//             endLatitude: 40.4120,
//             endLongitude: 49.8700,
//             coordinatesJson: nil,
//             distanceKm: 3.45,
//             durationSeconds: 1230,
//             avgPace: 5.9,
//             maxPace: 4.8,
//             avgSpeedKmh: 10.1,
//             maxSpeedKmh: 12.5,
//             elevationGain: 45,
//             elevationLoss: 38,
//             caloriesBurned: 287,
//             staticMapUrl: nil,
//             isAssigned: false,
//             isCompleted: true,
//             startedAt: Date(),
//             finishedAt: Date(),
//             createdAt: Date()
//         ))
//     }
// }

// MARK: - iOS 16 Compatible Route Map View
struct RouteMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)

        // Remove old overlays
        mapView.removeOverlays(mapView.overlays)

        // Add polyline
        if coordinates.count > 1 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
        }

        // Remove old annotations
        mapView.removeAnnotations(mapView.annotations)

        // Add start marker
        if let first = coordinates.first {
            let annotation = MKPointAnnotation()
            annotation.coordinate = first
            annotation.title = "Start"
            mapView.addAnnotation(annotation)
        }

        // Add end marker
        if let last = coordinates.last, coordinates.count > 1 {
            let annotation = MKPointAnnotation()
            annotation.coordinate = last
            annotation.title = "End"
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemRed
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "RouteMarker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                view?.annotation = annotation
            }

            // Custom marker view
            let markerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            markerView.backgroundColor = .clear

            let circle = UIView(frame: CGRect(x: 2, y: 2, width: 16, height: 16))
            circle.layer.cornerRadius = 8
            circle.backgroundColor = annotation.title == "Start" ? UIColor.systemGreen : UIColor.systemRed
            circle.layer.borderColor = UIColor.white.cgColor
            circle.layer.borderWidth = 3

            markerView.addSubview(circle)

            UIGraphicsBeginImageContextWithOptions(markerView.bounds.size, false, 0)
            markerView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            view?.image = image
            view?.centerOffset = CGPoint(x: 0, y: -10)

            return view
        }
    }
}
