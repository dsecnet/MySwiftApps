import SwiftUI
import MapKit

struct PropertiesMapView: View {
    @StateObject private var viewModel = PropertiesViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    @State private var showFilters = false
    @State private var selectedProperty: PropertyWithDistance?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Map
            Map(position: $mapViewModel.cameraPosition) {
                ForEach(mapViewModel.nearbyProperties) { property in
                    Annotation(property.title, coordinate: CLLocationCoordinate2D(
                        latitude: property.latitude,
                        longitude: property.longitude
                    )) {
                        PropertyMapPin(
                            property: property,
                            isSelected: selectedProperty?.id == property.id
                        )
                        .onTapGesture {
                            selectedProperty = property
                        }
                    }
                }
            }
            .ignoresSafeArea()

            // Top Bar
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }

                    Button {
                        Task {
                            await mapViewModel.refreshNearby()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding()

                Spacer()
            }

            // Selected Property Card
            if let property = selectedProperty {
                VStack {
                    Spacer()

                    PropertyMapCard(property: property)
                        .padding()
                        .transition(.move(edge: .bottom))
                }
            }

            // Loading
            if mapViewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
            }
        }
        .task {
            await mapViewModel.loadNearbyProperties()
        }
        .sheet(isPresented: $showFilters) {
            MapFiltersView(viewModel: mapViewModel)
        }
    }
}

// MARK: - Map Pin
struct PropertyMapPin: View {
    let property: PropertyWithDistance
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Price bubble
            Text(property.price.toCurrency())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    isSelected ? AppTheme.primaryColor : Color.red
                )
                .cornerRadius(12)

            // Arrow
            Triangle()
                .fill(isSelected ? AppTheme.primaryColor : Color.red)
                .frame(width: 10, height: 8)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Property Card
struct PropertyMapCard: View {
    let property: PropertyWithDistance

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Image
                if let imageUrl = property.images?.first {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(property.title)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text(property.district ?? "Bakı")
                            .font(.caption)

                        if let metro = property.nearestMetro {
                            Text("• \(metro)")
                                .font(.caption)
                                .foregroundColor(AppTheme.primaryColor)
                        }
                    }
                    .foregroundColor(.secondary)

                    Text(property.price.toCurrency())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)

                    HStack(spacing: 12) {
                        if let rooms = property.rooms {
                            Label("\(rooms)", systemImage: "bed.double.fill")
                                .font(.caption)
                        }
                        if let area = property.areaSqm {
                            Label(area.toArea(), systemImage: "square.fill")
                                .font(.caption)
                        }

                        Label("\(property.distanceKm) km", systemImage: "arrow.left.and.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.successColor)
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}

// MARK: - Filters Sheet
struct MapFiltersView: View {
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Radius") {
                    Slider(value: $viewModel.radiusKm, in: 0.5...10, step: 0.5) {
                        Text("Radius")
                    }
                    Text("\(viewModel.radiusKm, specifier: "%.1f") km")
                        .foregroundColor(.secondary)
                }

                Section("Property Type") {
                    Picker("Type", selection: $viewModel.selectedPropertyType) {
                        Text("Hamısı").tag(nil as PropertyType?)
                        ForEach(PropertyType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type as PropertyType?)
                        }
                    }
                }

                Section("Deal Type") {
                    Picker("Deal", selection: $viewModel.selectedDealType) {
                        Text("Hamısı").tag(nil as DealType?)
                        Text("Satış").tag(DealType.sale as DealType?)
                        Text("Kirayə").tag(DealType.rent as DealType?)
                    }
                }

                Section("Price Range") {
                    HStack {
                        TextField("Min", value: $viewModel.minPrice, format: .number)
                            .keyboardType(.numberPad)
                        Text("-")
                        TextField("Max", value: $viewModel.maxPrice, format: .number)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("Filterlər")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Bağla") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tətbiq et") {
                        Task {
                            await viewModel.applyFilters()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Map ViewModel
@MainActor
class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D.bakuCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D.bakuCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))

    @Published var nearbyProperties: [PropertyWithDistance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Filters
    @Published var radiusKm: Double = 3.0
    @Published var selectedPropertyType: PropertyType?
    @Published var selectedDealType: DealType?
    @Published var minPrice: Double?
    @Published var maxPrice: Double?

    func loadNearbyProperties() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await MapService.shared.getNearbyProperties(
                latitude: region.center.latitude,
                longitude: region.center.longitude,
                radiusKm: radiusKm
            )

            nearbyProperties = response.properties
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshNearby() async {
        await loadNearbyProperties()
    }

    func applyFilters() async {
        isLoading = true

        do {
            let response = try await MapService.shared.radiusSearch(
                latitude: region.center.latitude,
                longitude: region.center.longitude,
                radiusKm: radiusKm,
                propertyType: selectedPropertyType,
                dealType: selectedDealType,
                minPrice: minPrice,
                maxPrice: maxPrice
            )

            nearbyProperties = response.properties
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    PropertiesMapView()
}
