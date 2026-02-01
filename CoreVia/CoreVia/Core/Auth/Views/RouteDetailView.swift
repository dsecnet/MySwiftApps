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

    // Parsed coordinates
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
                Map {
                    MapPolyline(coordinates: coordinates)
                        .stroke(.red, lineWidth: 4)

                    // Start marker (green)
                    if let first = coordinates.first {
                        Annotation("", coordinate: first) {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 16, height: 16)
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }

                    // End marker (red)
                    if let last = coordinates.last, coordinates.count > 1 {
                        Annotation("", coordinate: last) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 16, height: 16)
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            } else if let mapUrl = route.staticMapUrl, let url = URL(string: mapUrl) {
                // Fallback: static map from backend
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
                Text("Xerite melumati yoxdur")
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
                    color: .red
                )

                RouteStatCard(
                    icon: "clock.fill",
                    value: formatDuration(route.durationSeconds),
                    unit: "",
                    label: "Muddet",
                    color: .blue
                )
            }

            HStack(spacing: 12) {
                RouteStatCard(
                    icon: "speedometer",
                    value: route.avgPace.map { String(format: "%.1f", $0) } ?? "--",
                    unit: "deq/km",
                    label: "Orta Temp",
                    color: .orange
                )

                RouteStatCard(
                    icon: "flame.fill",
                    value: route.caloriesBurned.map { "\($0)" } ?? "--",
                    unit: "kkal",
                    label: "Kalori",
                    color: .green
                )
            }

            HStack(spacing: 12) {
                RouteStatCard(
                    icon: "arrow.up.right",
                    value: route.elevationGain.map { String(format: "%.0f", $0) } ?? "--",
                    unit: "m",
                    label: "Yukselis",
                    color: .purple
                )

                RouteStatCard(
                    icon: "hare.fill",
                    value: route.avgSpeedKmh.map { String(format: "%.1f", $0) } ?? "--",
                    unit: "km/s",
                    label: "Orta Suret",
                    color: .teal
                )
            }
        }
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detallar")
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

#Preview {
    NavigationStack {
        RouteDetailView(route: RouteResponse(
            id: "preview-1",
            userId: "user-1",
            workoutId: nil,
            name: nil,
            activityType: "running",
            startLatitude: 40.4093,
            startLongitude: 49.8671,
            endLatitude: 40.4120,
            endLongitude: 49.8700,
            coordinatesJson: nil,
            distanceKm: 3.45,
            durationSeconds: 1230,
            avgPace: 5.9,
            maxPace: 4.8,
            avgSpeedKmh: 10.1,
            maxSpeedKmh: 12.5,
            elevationGain: 45,
            elevationLoss: 38,
            caloriesBurned: 287,
            staticMapUrl: nil,
            isAssigned: false,
            isCompleted: true,
            startedAt: Date(),
            finishedAt: Date(),
            createdAt: Date()
        ))
    }
}
