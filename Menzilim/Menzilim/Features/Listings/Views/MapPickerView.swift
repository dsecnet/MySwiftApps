import SwiftUI
import MapKit
import CoreLocation

// MARK: - Map Picker View
struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = MapPickerLocationManager()

    @Binding var selectedAddress: String
    @Binding var selectedDistrict: String
    @Binding var selectedLatitude: Double?
    @Binding var selectedLongitude: Double?
    var initialCity: AzerbaijanCity?

    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4093, longitude: 49.8671),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )
    @State private var pinCoordinate: CLLocationCoordinate2D?
    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching: Bool = false
    @State private var geocodedAddress: String = ""
    @State private var geocodedDistrict: String = ""
    @State private var showSearchResults: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar

                    ZStack(alignment: .bottom) {
                        mapView

                        if !geocodedAddress.isEmpty {
                            addressCard
                        }
                    }
                }

                if showSearchResults && !searchResults.isEmpty {
                    searchResultsList
                }
            }
            .navigationTitle("select_on_map".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        applySelection()
                    } label: {
                        Text("done".localized)
                            .font(AppTheme.Fonts.captionBold())
                            .foregroundColor(
                                pinCoordinate != nil
                                    ? AppTheme.Colors.accent
                                    : AppTheme.Colors.textTertiary
                            )
                    }
                    .disabled(pinCoordinate == nil)
                }
            }
            .onAppear {
                let city = initialCity ?? LocationData.cities.first!
                region = MKCoordinateRegion(
                    center: city.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: city.span, longitudeDelta: city.span)
                )
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textTertiary)

            TextField("Ünvan axtar...", text: $searchText)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .autocorrectionDisabled()
                .onSubmit {
                    performSearch()
                }
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        searchResults = []
                        showSearchResults = false
                    }
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchResults = []
                    showSearchResults = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }

            Button {
                performSearch()
            } label: {
                Text("Axtar")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(AppTheme.CornerRadius.small)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.inputBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppTheme.Colors.inputBorder),
            alignment: .bottom
        )
    }

    // MARK: - Map View
    private var mapView: some View {
        Map(coordinateRegion: $region, annotationItems: pinAnnotations) { item in
            MapAnnotation(coordinate: item.coordinate) {
                VStack(spacing: 0) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.Colors.accent)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, y: 2)

                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.accent)
                        .offset(y: -4)
                }
            }
        }
        .overlay {
            MapTapOverlay { coordinate in
                withAnimation(.easeInOut(duration: 0.2)) {
                    pinCoordinate = coordinate
                }
                reverseGeocode(coordinate: coordinate)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                moveToUserLocation()
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.accent)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
            }
            .padding(.trailing, AppTheme.Spacing.md)
            .padding(.bottom, geocodedAddress.isEmpty ? AppTheme.Spacing.lg : 120)
        }
    }

    private var pinAnnotations: [PinAnnotation] {
        if let pin = pinCoordinate {
            return [PinAnnotation(coordinate: pin)]
        }
        return []
    }

    // MARK: - Address Card
    private var addressCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.accent)

                Text(geocodedAddress)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)

                Spacer()
            }

            if !geocodedDistrict.isEmpty {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    Text(geocodedDistrict)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }

            Button {
                applySelection()
            } label: {
                Text("Bu ünvanı seç")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(AppTheme.CornerRadius.medium)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(color: Color.black.opacity(0.2), radius: 8, y: -2)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.md)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Search Results List
    private var searchResultsList: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 52)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(searchResults, id: \.self) { item in
                        Button {
                            selectSearchResult(item)
                        } label: {
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "mappin.circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppTheme.Colors.accent)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "")
                                        .font(AppTheme.Fonts.body())
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                        .lineLimit(1)

                                    if let address = item.placemark.mapFormattedAddress {
                                        Text(address)
                                            .font(AppTheme.Fonts.small())
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.md)
                        }

                        Divider()
                            .background(AppTheme.Colors.inputBorder)
                    }
                }
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .padding(.horizontal, AppTheme.Spacing.md)
            }

            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            showSearchResults = false
        }
    }

    // MARK: - Actions
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let city = initialCity ?? LocationData.cities.first!
        request.region = MKCoordinateRegion(
            center: city.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                searchResults = Array(response.mapItems.prefix(8))
                showSearchResults = true
            }
        }
    }

    private func selectSearchResult(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        pinCoordinate = coordinate
        searchText = item.name ?? ""
        showSearchResults = false

        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        reverseGeocode(coordinate: coordinate)
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else { return }

            var addressParts: [String] = []
            if let street = placemark.thoroughfare {
                addressParts.append(street)
            }
            if let subThoroughfare = placemark.subThoroughfare {
                addressParts.append(subThoroughfare)
            }
            if let subLocality = placemark.subLocality {
                addressParts.append(subLocality)
            }
            if let locality = placemark.locality {
                addressParts.append(locality)
            }

            geocodedAddress = addressParts.isEmpty
                ? "\(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))"
                : addressParts.joined(separator: ", ")

            geocodedDistrict = placemark.subAdministrativeArea ?? placemark.subLocality ?? ""
        }
    }

    private func applySelection() {
        guard let pin = pinCoordinate else { return }
        selectedAddress = geocodedAddress
        selectedLatitude = pin.latitude
        selectedLongitude = pin.longitude
        if !geocodedDistrict.isEmpty {
            selectedDistrict = geocodedDistrict
        }
        dismiss()
    }

    private func moveToUserLocation() {
        locationManager.requestLocation()
        if let location = locationManager.lastLocation {
            let coordinate = location.coordinate
            withAnimation {
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
}

// MARK: - Pin Annotation Model
struct PinAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Map Tap Overlay (UIKit bridge for tap-to-place-pin)
struct MapTapOverlay: UIViewRepresentable {
    let onTap: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> MapTapOverlayUIView {
        let view = MapTapOverlayUIView()
        view.onTap = onTap
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: MapTapOverlayUIView, context: Context) {
        uiView.onTap = onTap
    }
}

class MapTapOverlayUIView: UIView {
    var onTap: ((CLLocationCoordinate2D) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        if let mapView = findMapView(in: self.window) {
            let coordinate = mapView.convert(point, toCoordinateFrom: self)
            onTap?(coordinate)
        }
    }

    private func findMapView(in view: UIView?) -> MKMapView? {
        guard let view = view else { return nil }
        if let mapView = view as? MKMapView {
            return mapView
        }
        for subview in view.subviews {
            if let found = findMapView(in: subview) {
                return found
            }
        }
        return nil
    }
}

// MARK: - Location Manager for Map Picker
class MapPickerLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently fail - user can still manually pick location
    }
}

// MARK: - MKPlacemark Extension
extension MKPlacemark {
    var mapFormattedAddress: String? {
        var parts: [String] = []
        if let street = thoroughfare { parts.append(street) }
        if let number = subThoroughfare { parts.append(number) }
        if let district = subLocality { parts.append(district) }
        if let city = locality { parts.append(city) }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}
