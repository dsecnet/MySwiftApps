import SwiftUI
import MapKit

// MARK: - Map Pin Annotation
struct MapListing: Identifiable, Hashable {
    let id: String
    let listing: Listing
    let coordinate: CLLocationCoordinate2D

    var priceLabel: String {
        let price = listing.price
        if price >= 1_000_000 {
            return String(format: "%.1fM", price / 1_000_000) + " \(listing.currency.symbol)"
        } else if price >= 1000 {
            return String(format: "%.0fK", price / 1000) + " \(listing.currency.symbol)"
        } else {
            return "\(Int(price)) \(listing.currency.symbol)"
        }
    }

    // Hashable conformance
    static func == (lhs: MapListing, rhs: MapListing) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Map Search View
struct MapSearchView: View {
    @ObservedObject var viewModel: SearchViewModel

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.3893, longitude: 49.8471),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    )
    @State private var selectedListingId: String?
    @State private var showBottomSheet: Bool = true

    private var mapListings: [MapListing] {
        viewModel.results.compactMap { listing in
            guard let lat = listing.latitude, let lon = listing.longitude else { return nil }
            return MapListing(
                id: listing.id,
                listing: listing,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
            )
        }
    }

    var body: some View {
        ZStack {
            // MARK: - Map
            mapContent

            // MARK: - Top Floating Search
            VStack {
                floatingSearchBar
                filterChipsOverlay
                Spacer()
            }

            // MARK: - Bottom Sheet
            VStack {
                Spacer()

                if showBottomSheet {
                    bottomSheetContent
                        .transition(.move(edge: .bottom))
                }
            }
        }
    }

    // MARK: - Map Content (iOS 16 compatible)
    private var mapContent: some View {
        Map(coordinateRegion: $region, annotationItems: mapListings) { mapListing in
            MapAnnotation(coordinate: mapListing.coordinate) {
                priceMarker(for: mapListing)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Price Marker
    private func priceMarker(for mapListing: MapListing) -> some View {
        let isSelected = selectedListingId == mapListing.id

        return VStack(spacing: 0) {
            Text(mapListing.priceLabel)
                .font(AppTheme.Fonts.smallBold())
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(
                    isSelected
                        ? AppTheme.Colors.accent
                        : AppTheme.Colors.cardBackground
                )
                .cornerRadius(AppTheme.CornerRadius.small)
                .shadow(color: Color.black.opacity(0.3), radius: 4, y: 2)

            // Triangle pointer
            Triangle()
                .fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground)
                .frame(width: 12, height: 6)
                .shadow(color: Color.black.opacity(0.2), radius: 2, y: 1)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedListingId = mapListing.id
            }
        }
    }

    // MARK: - Floating Search Bar
    private var floatingSearchBar: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.Colors.textTertiary)

            TextField("search".localized, text: $viewModel.searchText)
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground.opacity(0.95))
        .cornerRadius(AppTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, y: 2)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Filter Chips Overlay
    private var filterChipsOverlay: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                // List View toggle
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.showMapView = false
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 12))
                        Text("list_view".localized)
                            .font(AppTheme.Fonts.smallBold())
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.cardBackground.opacity(0.95))
                    .cornerRadius(AppTheme.CornerRadius.pill)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                            .stroke(AppTheme.Colors.accent, lineWidth: 1)
                    )
                }

                // Filter button
                Button {
                    viewModel.showFilterSheet = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 12))
                        Text("filter".localized)
                            .font(AppTheme.Fonts.smallBold())
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.cardBackground.opacity(0.95))
                    .cornerRadius(AppTheme.CornerRadius.pill)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                            .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                    )
                }

                // Results count chip
                Text("\(viewModel.totalResults) \("properties_in_area".localized)")
                    .font(AppTheme.Fonts.smallBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.cardBackground.opacity(0.95))
                    .cornerRadius(AppTheme.CornerRadius.pill)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Bottom Sheet Content
    private var bottomSheetContent: some View {
        VStack(spacing: 0) {
            // Drag indicator
            dragIndicator

            // Header
            HStack {
                Text("properties_in_area".localized)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Text("(\(viewModel.results.count))")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.accent)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showBottomSheet.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.Colors.inputBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.sm)

            // Listings scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(viewModel.results) { listing in
                        mapBottomCard(listing: listing)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                .fill(AppTheme.Colors.background)
                .shadow(color: Color.black.opacity(0.3), radius: 16, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Drag Indicator
    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AppTheme.Colors.inputBorder)
            .frame(width: 40, height: 4)
            .padding(.top, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.md)
    }

    // MARK: - Map Bottom Card
    private func mapBottomCard(listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: listing.mainImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16 / 10, contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(AppTheme.Colors.surfaceBackground)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            )
                    }
                }
                .frame(width: 220, height: 130)
                .clipped()
                .cornerRadius(AppTheme.CornerRadius.medium)

                // Boost badge
                if listing.isBoosted, let boostType = listing.boostType {
                    Text(boostType.displayName)
                        .font(AppTheme.Fonts.smallBold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color(hex: boostType.color))
                        .cornerRadius(AppTheme.CornerRadius.small)
                        .padding(AppTheme.Spacing.sm)
                }
            }

            // Price
            Text(listing.formattedPrice)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Spacing.sm)

            // Location
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textTertiary)

                Text("\(listing.district), \(listing.city)")
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, AppTheme.Spacing.sm)

            // Quick details
            HStack(spacing: AppTheme.Spacing.md) {
                Label("\(listing.rooms)", systemImage: "bed.double.fill")
                Label("\(Int(listing.areaSqm))m\u{00B2}", systemImage: "ruler.fill")
            }
            .font(AppTheme.Fonts.small())
            .foregroundColor(AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
        .frame(width: 220)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

// MARK: - Triangle Shape
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

// MARK: - Preview
#Preview {
    MapSearchView(viewModel: SearchViewModel())
        .preferredColorScheme(.dark)
}
