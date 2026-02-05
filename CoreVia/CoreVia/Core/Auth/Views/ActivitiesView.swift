//
//  ActivitiesView.swift
//  CoreVia
//

import SwiftUI
import CoreLocation

// MARK: - Activity Type
enum ActivityType: String, CaseIterable {
    case walking = "walking"
    case running = "running"
    case cycling = "cycling"

    var icon: String {
        switch self {
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        }
    }

    var color: Color {
        switch self {
        case .walking: return AppTheme.Colors.actWalking
        case .running: return AppTheme.Colors.actRunning
        case .cycling: return AppTheme.Colors.actCycling
        }
    }

    var displayName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .walking: return loc.localized("activities_walking")
        case .running: return loc.localized("activities_running")
        case .cycling: return loc.localized("activities_cycling")
        }
    }
}

// MARK: - Activities View
struct ActivitiesView: View {

    @ObservedObject private var routeManager = RouteManager.shared
    @ObservedObject private var locationManager = LocationManager.shared
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var selectedFilter: ActivityType? = nil
    @State private var showPremium = false
    @State private var showStartActivity = false
    @State private var isTracking = false
    @State private var activeType: ActivityType = .running
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer? = nil
    @State private var trackingStartTime: Date?
    @State private var showLocationDenied = false
    @State private var pendingActivityType: ActivityType? = nil

    var filteredRoutes: [RouteResponse] {
        if let filter = selectedFilter {
            return routeManager.routes.filter { $0.activityType == filter.rawValue }
        }
        return routeManager.routes
    }

    var weekDistance: Double {
        routeManager.weeklyStats?.totalDistanceKm ?? 0
    }

    var weekDuration: Int {
        routeManager.weeklyStats?.totalDurationSeconds ?? 0
    }

    var weekCalories: Int {
        routeManager.weeklyStats?.totalCalories ?? 0
    }

    var livePace: String {
        let dist = locationManager.distanceKm
        guard dist > 0.01, elapsedSeconds > 0 else { return "--:--" }
        let paceMinPerKm = (Double(elapsedSeconds) / 60.0) / dist
        let mins = Int(paceMinPerKm)
        let secs = Int((paceMinPerKm - Double(mins)) * 60)
        return String(format: "%d:%02d /km", mins, secs)
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            if settingsManager.isPremium {
                premiumActivitiesContent
            } else {
                lockedActivitiesContent
            }
        }
        .sheet(isPresented: $showPremium) {
            PremiumView()
        }
    }

    // MARK: - Premium Activities Content (aciq)
    private var premiumActivitiesContent: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    weeklyStatsSection
                    if isTracking { activeTrackingSection }
                    filterSection
                    activityListSection
                }
                .padding()
            }

            if !isTracking {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showStartActivity = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)
                                    .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 12, x: 0, y: 6)

                                Image(systemName: "play.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            routeManager.loadRoutes()
            routeManager.loadWeeklyStats()
        }
        .sheet(isPresented: $showStartActivity) {
            StartActivitySheet(
                onStart: { type in
                    startTracking(type: type)
                }
            )
            .presentationDetents([.medium])
        }
        .alert("Lokasiya icazesi lazimdir", isPresented: $showLocationDenied) {
            Button("Ayarlar") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Bagla", role: .cancel) {}
        } message: {
            Text("Marsrut izlemek ucun lokasiya icazesi verin.")
        }
        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
            if let pending = pendingActivityType,
               (newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways) {
                pendingActivityType = nil
                beginTracking(type: pending)
            }
        }
    }

    // MARK: - Locked Activities Content (premium lazimdir)
    private var lockedActivitiesContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection

                weeklyStatsSection
                    .blur(radius: 3)
                    .allowsHitTesting(false)

                Button {
                    showPremium = true
                } label: {
                    ZStack {
                        VStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { _ in
                                HStack(spacing: 14) {
                                    Circle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 48, height: 48)
                                    VStack(alignment: .leading, spacing: 6) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(width: 120, height: 14)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 180, height: 12)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(14)
                            }
                        }
                        .blur(radius: 2)

                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.Colors.accentDark, AppTheme.Colors.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)

                                Image(systemName: "lock.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            }

                            Text(loc.localized("activities_gps_tracking"))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            Text(loc.localized("activities_gps_desc"))
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                                Text(loc.localized("activities_premium_go"))
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.Colors.accentDark, AppTheme.Colors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: AppTheme.Colors.accentDark.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
            }
            .padding()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(loc.localized("activities_title"))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(loc.localized("activities_subtitle"))
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Weekly Stats
    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("activities_this_week"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 12) {
                ActivityStatCard(
                    icon: "location.fill",
                    value: String(format: "%.1f km", weekDistance),
                    label: loc.localized("activities_distance"),
                    color: AppTheme.Colors.accent
                )

                ActivityStatCard(
                    icon: "clock.fill",
                    value: formatMinutes(weekDuration / 60),
                    label: loc.localized("activities_duration"),
                    color: AppTheme.Colors.accent
                )

                ActivityStatCard(
                    icon: "flame.fill",
                    value: "\(weekCalories)",
                    label: loc.localized("activities_calorie"),
                    color: AppTheme.Colors.accent
                )
            }
        }
    }

    // MARK: - Active Tracking
    private var activeTrackingSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: activeType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(activeType.color)
                Text(activeType.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                Spacer()
                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 10, height: 10)
                Text(loc.localized("activities_active"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.accent)
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text(formatElapsedTime(elapsedSeconds))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text(loc.localized("activities_time"))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                VStack(spacing: 4) {
                    Text(String(format: "%.2f", locationManager.distanceKm))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text("km")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                VStack(spacing: 4) {
                    Text(livePace)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text(loc.localized("activities_pace"))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }

            Button {
                stopTracking()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                    Text(loc.localized("activities_stop"))
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.Colors.accent)
                .cornerRadius(14)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.Colors.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(activeType.color.opacity(0.5), lineWidth: 2)
                )
        )
    }

    // MARK: - Filter
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("activities_history"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(
                        title: loc.localized("activities_all"),
                        isSelected: selectedFilter == nil,
                        color: AppTheme.Colors.accent
                    ) {
                        withAnimation { selectedFilter = nil }
                    }

                    ForEach(ActivityType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.displayName,
                            icon: type.icon,
                            isSelected: selectedFilter == type,
                            color: type.color
                        ) {
                            withAnimation { selectedFilter = type }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Activity List
    private var activityListSection: some View {
        VStack(spacing: 12) {
            if routeManager.isLoading {
                ProgressView()
                    .padding(.vertical, 40)
            } else if filteredRoutes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Text(loc.localized("activities_not_found"))
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Text(loc.localized("activities_start_hint"))
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.7))
                }
                .padding(.vertical, 40)
            } else {
                ForEach(filteredRoutes) { route in
                    NavigationLink(destination: RouteDetailView(route: route)) {
                        RouteActivityCard(route: route)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Tracking Logic

    private func startTracking(type: ActivityType) {
        if locationManager.authorizationStatus == .notDetermined {
            pendingActivityType = type
            locationManager.requestPermission()
            return
        }

        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            showLocationDenied = true
            return
        }

        beginTracking(type: type)
    }

    private func beginTracking(type: ActivityType) {
        activeType = type
        isTracking = true
        elapsedSeconds = 0
        trackingStartTime = Date()

        locationManager.startTracking()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func stopTracking() {
        timer?.invalidate()
        timer = nil
        isTracking = false

        locationManager.stopTracking()

        guard elapsedSeconds > 10,
              let startCoord = locationManager.startCoordinate else { return }

        let request = RouteCreateRequest(
            activityType: activeType.rawValue,
            startLatitude: startCoord.latitude,
            startLongitude: startCoord.longitude,
            endLatitude: locationManager.endCoordinate?.latitude,
            endLongitude: locationManager.endCoordinate?.longitude,
            coordinatesJson: locationManager.coordinatesJSON,
            distanceKm: locationManager.distanceKm,
            durationSeconds: elapsedSeconds,
            startedAt: trackingStartTime ?? Date(),
            finishedAt: Date()
        )

        routeManager.saveRoute(request)
    }

    // MARK: - Helpers
    private func formatElapsedTime(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        }
        return String(format: "%02d:%02d", mins, secs)
    }

    private func formatMinutes(_ mins: Int) -> String {
        if mins >= 60 {
            return "\(mins / 60)\(loc.localized("activities_hours_short")) \(mins % 60)\(loc.localized("activities_mins_short"))"
        }
        return "\(mins) \(loc.localized("activities_mins"))"
    }
}

// MARK: - Start Activity Sheet
struct StartActivitySheet: View {
    let onStart: (ActivityType) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: ActivityType = .running

    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 3)
                .fill(AppTheme.Colors.secondaryText.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Text(LocalizationManager.shared.localized("activities_start"))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 16) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedType = type
                        }
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(selectedType == type ? type.color.opacity(0.2) : AppTheme.Colors.secondaryBackground)
                                    .frame(width: 64, height: 64)

                                Image(systemName: type.icon)
                                    .font(.system(size: 28))
                                    .foregroundColor(selectedType == type ? type.color : AppTheme.Colors.secondaryText)
                            }

                            Text(type.displayName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedType == type ? AppTheme.Colors.primaryText : AppTheme.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedType == type ? type.color.opacity(0.08) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedType == type ? type.color : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, 4)

            Button {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onStart(selectedType)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18))
                    Text(LocalizationManager.shared.localized("activities_begin"))
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [selectedType.color, selectedType.color.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: selectedType.color.opacity(0.4), radius: 10, x: 0, y: 5)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Components

struct ActivityStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
    }
}

struct RouteActivityCard: View {
    let route: RouteResponse

    var activityType: ActivityType {
        ActivityType(rawValue: route.activityType) ?? .running
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(activityType.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: activityType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(activityType.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(activityType.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Spacer()
                    Text(formatDate(route.startedAt))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                HStack(spacing: 16) {
                    Label(String(format: "%.2f km", route.distanceKm), systemImage: "location.fill")
                    Label(formatDuration(route.durationSeconds), systemImage: "clock.fill")
                    if let cal = route.caloriesBurned {
                        Label("\(cal) kcal", systemImage: "flame.fill")
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, HH:mm"
        return formatter.string(from: date)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        }
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    NavigationStack {
        ActivitiesView()
    }
}
