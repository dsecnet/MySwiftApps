import SwiftUI
import MapKit

// MARK: - Listing Detail View
struct ListingDetailView: View {
    let listing: Listing
    @StateObject private var viewModel = ListingsViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var isFavorited: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showReportSheet: Bool = false
    @State private var showFullDescription: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()

            // Main content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Image Carousel
                    imageCarouselSection

                    // MARK: - Content
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                        // Price & Type
                        priceSection

                        // Title & Location
                        titleLocationSection

                        // Quick Stats
                        quickStatsRow

                        // Divider
                        sectionDivider

                        // Description
                        descriptionSection

                        // Divider
                        sectionDivider

                        // Key Amenities
                        amenitiesSection

                        // Divider
                        sectionDivider

                        // Agent Card
                        agentSection

                        // Divider
                        sectionDivider

                        // Map Section
                        mapSection

                        // Divider
                        sectionDivider

                        // Similar Listings
                        similarListingsSection
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.lg)

                    // Bottom spacing for the sticky bar
                    Spacer()
                        .frame(height: 120)
                }
            }

            // MARK: - Bottom Bar
            bottomBar
        }
        .navigationBarHidden(true)
        .overlay(alignment: .top) {
            // Custom nav bar overlay
            customNavBar
        }
        .onAppear {
            viewModel.loadSimilarListings(for: listing)
        }
    }

    // MARK: - Custom Nav Bar
    private var customNavBar: some View {
        HStack {
            // Back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }

            Spacer()

            // Share button
            Button {
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }

            // Favorite button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isFavorited.toggle()
                }
                viewModel.toggleFavorite(listing: listing)
            } label: {
                Image(systemName: isFavorited ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFavorited ? AppTheme.Colors.error : .white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Image Carousel Section
    private var imageCarouselSection: some View {
        ZStack(alignment: .bottomTrailing) {
            ImageCarousel(
                imageURLs: listing.images.isEmpty
                    ? ["https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800"]
                    : listing.images,
                height: 300,
                cornerRadius: 0
            )

            // Image counter
            Text("\(listing.images.count) \("photos_media".localized)")
                .font(AppTheme.Fonts.small())
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(Color.black.opacity(0.5))
                .cornerRadius(AppTheme.CornerRadius.small)
                .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Price Section
    private var priceSection: some View {
        HStack(alignment: .center) {
            Text(listing.formattedPrice)
                .font(AppTheme.Fonts.heading1())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            // Listing type badge
            Text(listing.listingType.displayKey.localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(listingTypeBadgeColor)
                .clipShape(Capsule())

            // Boost badge
            if listing.isBoosted, let boostType = listing.boostType {
                Text(boostType.displayName)
                    .font(AppTheme.Fonts.smallBold())
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs + 2)
                    .background(Color(hex: boostType.color))
                    .clipShape(Capsule())
            }
        }
    }

    private var listingTypeBadgeColor: Color {
        switch listing.listingType {
        case .sale: return AppTheme.Colors.success
        case .rent: return AppTheme.Colors.info
        case .dailyRent: return AppTheme.Colors.warning
        }
    }

    // MARK: - Title & Location Section
    private var titleLocationSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(listing.title)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.accent)

                Text(listing.address)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            // Views count
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textTertiary)

                Text("\(listing.viewsCount)")
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
        }
    }

    // MARK: - Quick Stats Row
    private var quickStatsRow: some View {
        HStack(spacing: 0) {
            quickStatItem(
                icon: "bed.double.fill",
                value: "\(listing.rooms)",
                label: "rooms".localized
            )

            quickStatDivider

            quickStatItem(
                icon: "shower.fill",
                value: "\(max(1, listing.rooms / 2))",
                label: "baths".localized
            )

            quickStatDivider

            quickStatItem(
                icon: "square.dashed",
                value: "\(Int(listing.areaSqm)) m\u{00B2}",
                label: "area_sqm".localized
            )

            quickStatDivider

            quickStatItem(
                icon: "building.2.fill",
                value: listing.floorInfo ?? "-",
                label: "floor".localized
            )
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }

    private func quickStatItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.accent)

            Text(value)
                .font(AppTheme.Fonts.bodyBold())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(label)
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var quickStatDivider: some View {
        Rectangle()
            .fill(AppTheme.Colors.inputBorder)
            .frame(width: 1, height: 50)
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("description".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(listing.description)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(showFullDescription ? nil : 4)

            if listing.description.count > 150 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showFullDescription.toggle()
                    }
                } label: {
                    Text(showFullDescription ? "close".localized : "see_all".localized)
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
    }

    // MARK: - Key Amenities Section
    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("key_amenities".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Amenity tags in a flow layout
            let amenities = buildAmenities()
            FlowLayout(spacing: AppTheme.Spacing.sm) {
                ForEach(amenities, id: \.self) { amenity in
                    amenityTag(amenity)
                }
            }
        }
    }

    private func buildAmenities() -> [String] {
        var items: [String] = []
        items.append(listing.renovation.displayKey.localized)
        items.append(listing.propertyType.displayKey.localized)
        if listing.floor != nil { items.append("has_elevator".localized) }
        items.append("\(listing.rooms) \("rooms".localized)")
        items.append("\(Int(listing.areaSqm)) m\u{00B2}")
        if let floorInfo = listing.floorInfo {
            items.append("\("floor".localized): \(floorInfo)")
        }
        items.append(listing.listingType.displayKey.localized)
        return items
    }

    private func amenityTag(_ text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.success)

            Text(text)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.pill)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
        )
    }

    // MARK: - Agent Section
    private var agentSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("contact_agent".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Agent card
            VStack(spacing: AppTheme.Spacing.lg) {
                HStack(spacing: AppTheme.Spacing.md) {
                    // Agent avatar
                    let agent = agentForListing
                    AsyncImage(url: URL(string: agent?.avatarUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Circle()
                                .fill(AppTheme.Colors.surfaceBackground)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                )
                        }
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.accent, lineWidth: 2)
                    )

                    // Agent info
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(agent?.displayName ?? "Agent")
                            .font(AppTheme.Fonts.bodyBold())
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        if let agent = agent {
                            HStack(spacing: AppTheme.Spacing.xs) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.gold)

                                Text(agent.ratingFormatted)
                                    .font(AppTheme.Fonts.captionBold())
                                    .foregroundColor(AppTheme.Colors.textPrimary)

                                Text("(\(agent.totalReviews) \("reviews".localized))")
                                    .font(AppTheme.Fonts.small())
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            }

                            Text(agent.level.displayKey.localized)
                                .font(AppTheme.Fonts.small())
                                .foregroundColor(Color(hex: agent.level.badgeColor))
                        }
                    }

                    Spacer()

                    // Verified badge
                    if agent?.user?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }

                // Action buttons row
                HStack(spacing: AppTheme.Spacing.md) {
                    // Call button
                    agentActionButton(
                        icon: "phone.fill",
                        label: "call".localized,
                        color: AppTheme.Colors.success
                    ) {
                        // Handle call
                    }

                    // WhatsApp button
                    agentActionButton(
                        icon: "message.fill",
                        label: "whatsapp".localized,
                        color: Color(hex: "25D366")
                    ) {
                        // Handle WhatsApp
                    }

                    // Message button
                    agentActionButton(
                        icon: "envelope.fill",
                        label: "message".localized,
                        color: AppTheme.Colors.accent
                    ) {
                        // Handle message
                    }
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
        }
    }

    private var agentForListing: Agent? {
        guard let agentId = listing.agentId else { return nil }
        return HomeViewModel.mockAgents.first { $0.id == agentId }
    }

    private func agentActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())

                Text(label)
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Location Section
    private var fullAddress: String {
        var parts: [String] = []
        if !listing.address.isEmpty { parts.append(listing.address) }
        if !listing.district.isEmpty { parts.append(listing.district) }
        if !listing.city.isEmpty { parts.append(listing.city) }
        return parts.joined(separator: ", ")
    }

    @State private var resolvedCoordinate: CLLocationCoordinate2D? = nil
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4093, longitude: 49.8671),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    private var mapAnnotations: [PinAnnotation] {
        if let coord = resolvedCoordinate {
            return [PinAnnotation(coordinate: coord)]
        }
        return []
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("location".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Map with geocoded pin
            Map(coordinateRegion: .constant(mapRegion), annotationItems: mapAnnotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    VStack(spacing: 0) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.Colors.accent)
                            .shadow(color: Color.black.opacity(0.3), radius: 3, y: 2)

                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 8))
                            .foregroundColor(AppTheme.Colors.accent)
                            .offset(y: -3)
                    }
                }
            }
            .frame(height: 180)
            .cornerRadius(AppTheme.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
            .allowsHitTesting(false)
            .onAppear {
                geocodeAddress()
            }

            // Address info + open in maps
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(listing.district), \(listing.city)")
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    if !listing.address.isEmpty {
                        Text(listing.address)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Button {
                    openInMaps()
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 12))
                        Text("show_on_map".localized)
                            .font(AppTheme.Fonts.captionBold())
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.accent.opacity(0.12))
                    .cornerRadius(AppTheme.CornerRadius.small)
                }
            }
        }
    }

    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        let searchAddress = fullAddress

        geocoder.geocodeAddressString(searchAddress) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                resolvedCoordinate = coordinate
                mapRegion = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                )
            } else {
                // Fallback: use city coordinate from LocationData
                let city = LocationData.cities.first { $0.name == listing.city }
                if let cityCoord = city?.coordinate {
                    resolvedCoordinate = cityCoord
                    mapRegion = MKCoordinateRegion(
                        center: cityCoord,
                        span: MKCoordinateSpan(latitudeDelta: city?.span ?? 0.05, longitudeDelta: city?.span ?? 0.05)
                    )
                }
            }
        }
    }

    private func openInMaps() {
        let address = fullAddress
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Similar Listings Section
    private var similarListingsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("similar_listings".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppTheme.Spacing.md) {
                    ForEach(viewModel.similarListings) { similar in
                        NavigationLink {
                            ListingDetailView(listing: similar)
                        } label: {
                            CompactListingCard(
                                listing: similar,
                                isFavorite: false,
                                onFavoriteTap: {
                                    viewModel.toggleFavorite(listing: similar)
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppTheme.Colors.inputBorder)

            HStack(spacing: AppTheme.Spacing.lg) {
                // Price
                VStack(alignment: .leading, spacing: 2) {
                    Text("price".localized)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    Text(listing.formattedPrice)
                        .font(AppTheme.Fonts.title())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }

                Spacer()

                // Book Viewing Button
                Button {
                    // Handle book viewing
                } label: {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 16))

                        Text("book_viewing".localized)
                            .font(AppTheme.Fonts.bodyBold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .padding(.vertical, AppTheme.Spacing.md + 2)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent, AppTheme.Colors.primaryGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                AppTheme.Colors.background
                    .shadow(color: Color.black.opacity(0.3), radius: 10, y: -5)
            )
        }
    }

    // MARK: - Section Divider
    private var sectionDivider: some View {
        Divider()
            .background(AppTheme.Colors.inputBorder)
    }
}

// MARK: - Flow Layout (for amenity tags)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                let position = result.positions[index]
                subview.place(
                    at: CGPoint(
                        x: bounds.minX + position.x,
                        y: bounds.minY + position.y
                    ),
                    proposal: ProposedViewSize(subview.sizeThatFits(.unspecified))
                )
            }
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxRowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += maxRowHeight + spacing
                maxRowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            maxRowHeight = max(maxRowHeight, size.height)
            totalHeight = currentY + maxRowHeight
        }

        return (positions, CGSize(width: maxWidth, height: totalHeight))
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ListingDetailView(listing: HomeViewModel.mockListings[0])
    }
    .environmentObject(LocalizationManager.shared)
}
