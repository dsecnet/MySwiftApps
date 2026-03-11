import SwiftUI
import PhotosUI
import MapKit

// MARK: - Create Listing View (Single Page Form)
struct CreateListingView: View {
    @StateObject private var viewModel = CreateListingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Bar
                topBar

                Divider().background(AppTheme.Colors.inputBorder)

                // MARK: - Scrollable Form
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
                        // 1. Listing Type (Sale / Rent)
                        listingTypeSection

                        // 2. Property Category
                        propertyCategorySection

                        // 3. Rooms & Floor (only for old/new building)
                        if viewModel.selectedPropertyType == .oldBuilding || viewModel.selectedPropertyType == .newBuilding {
                            roomsFloorSection
                        }

                        // 3b. Rooms & Area (for house)
                        if viewModel.selectedPropertyType == .house {
                            houseDetailsSection
                        }

                        // 3c. Area (for office)
                        if viewModel.selectedPropertyType == .office {
                            officeDetailsSection
                        }

                        // 3d. Land area in sot (for land)
                        if viewModel.selectedPropertyType == .land {
                            landDetailsSection
                        }

                        // 4. Location (City / District / Microdistrict)
                        locationPickerSection

                        // 5. Address
                        addressSection

                        // 6. Price & Currency + Area
                        priceAreaSection

                        // 7. Description
                        descriptionSection

                        // 8. Features
                        featuresSection

                        // 9. Photos (at the end)
                        photosSection
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.bottom, 100)
                }

                // MARK: - Publish Button
                publishButton
            }

            // Error overlay
            if let error = viewModel.errorMessage {
                errorBanner(error)
            }
        }
        .alert("success".localized, isPresented: $viewModel.showSuccess) {
            Button("ok".localized) {
                dismiss()
            }
        } message: {
            Text("Elanınız uğurla dərc edildi!")
        }
        .sheet(isPresented: $viewModel.showLocationPicker) {
            locationPickerSheet
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("post_property".localized)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Button {
                Task { await viewModel.submit() }
            } label: {
                Text("publish".localized)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.accent)
            }
            .disabled(viewModel.isSubmitting)
            .frame(width: 40)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
    }

    // MARK: - 1. Photos Section
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                sectionTitle("photos_media")
                Spacer()
                Text(String(format: "photos_count".localized, viewModel.selectedImages.count))
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(
                        viewModel.selectedImages.count < 5
                            ? AppTheme.Colors.error
                            : AppTheme.Colors.success
                    )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    // Add photo button
                    if viewModel.canAddMorePhotos {
                        PhotosPicker(
                            selection: $viewModel.photoPickerItems,
                            maxSelectionCount: 10 - viewModel.selectedImages.count,
                            matching: .images
                        ) {
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.accent)

                                Text("add_photos".localized)
                                    .font(AppTheme.Fonts.small())
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .lineLimit(1)
                            }
                            .frame(width: 110, height: 110)
                            .background(AppTheme.Colors.inputBackground)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                    .stroke(AppTheme.Colors.accent.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            )
                        }
                        .onChange(of: viewModel.photoPickerItems) { _ in
                            viewModel.loadImages()
                        }
                    }

                    // Selected images
                    ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: viewModel.selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipped()
                                .cornerRadius(AppTheme.CornerRadius.medium)
                                .overlay(
                                    Group {
                                        if index == 0 {
                                            VStack {
                                                Spacer()
                                                Text("ƏSAS")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(AppTheme.Colors.accent)
                                                    .cornerRadius(4)
                                                    .padding(4)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                )

                            Button {
                                viewModel.removeImage(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2)
                            }
                            .padding(6)
                        }
                    }
                }
            }

            Text("photos_hint".localized)
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
    }

    // MARK: - 2. Listing Type
    private var listingTypeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("listing_type")

            HStack(spacing: 0) {
                listingTypeSegment(type: .sale, title: "for_sale".localized)
                listingTypeSegment(type: .rent, title: "for_rent".localized)
            }
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
        }
    }

    private func listingTypeSegment(type: ListingType, title: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedListingType = type
            }
        } label: {
            Text(title)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(
                    viewModel.selectedListingType == type ? .white : AppTheme.Colors.textSecondary
                )
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    viewModel.selectedListingType == type
                        ? AppTheme.Colors.accent
                        : Color.clear
                )
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .padding(2)
    }

    // MARK: - 3. Property Category
    // "Mənzil" is the parent for oldBuilding/newBuilding
    private var isMenzilSelected: Bool {
        viewModel.selectedPropertyType == .oldBuilding || viewModel.selectedPropertyType == .newBuilding
    }

    private var propertyCategorySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("property_type")

            // Main categories: Mənzil, Həyət evi, Ofis, Qaraj, Torpaq, Obyekt
            FlowLayout(spacing: AppTheme.Spacing.sm) {
                // Mənzil (parent for old/new building)
                menzilParentChip

                // Other property types (not old/new building)
                ForEach([PropertyType.house, .office, .garage, .land, .commercial], id: \.self) { type in
                    propertyCategoryChip(type: type)
                }
            }

            // Sub-selection: Köhnə tikili / Yeni tikili (shown when Mənzil is selected)
            if isMenzilSelected {
                HStack(spacing: AppTheme.Spacing.sm) {
                    buildingSubChip(type: .oldBuilding)
                    buildingSubChip(type: .newBuilding)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // "Mənzil" parent chip
    private var menzilParentChip: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                // Default to oldBuilding when tapping Mənzil
                if !isMenzilSelected {
                    viewModel.selectedPropertyType = .oldBuilding
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "building.fill")
                    .font(.system(size: 13))

                Text("Mənzil")
                    .font(AppTheme.Fonts.captionBold())
            }
            .foregroundColor(isMenzilSelected ? .white : AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isMenzilSelected
                    ? AppTheme.Colors.accent
                    : AppTheme.Colors.cardBackground
            )
            .cornerRadius(20)
            .overlay(
                Capsule()
                    .stroke(
                        isMenzilSelected ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // Köhnə tikili / Yeni tikili sub-chip
    private func buildingSubChip(type: PropertyType) -> some View {
        let isSelected = viewModel.selectedPropertyType == type

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedPropertyType = type
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 12))

                Text(type.displayKey.localized)
                    .font(AppTheme.Fonts.captionBold())
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isSelected
                    ? AppTheme.Colors.accent.opacity(0.8)
                    : AppTheme.Colors.cardBackground
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // Other property type chip (house, office, etc.)
    private func propertyCategoryChip(type: PropertyType) -> some View {
        let isSelected = viewModel.selectedPropertyType == type

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedPropertyType = type
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 13))

                Text(type.displayKey.localized)
                    .font(AppTheme.Fonts.captionBold())
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isSelected
                    ? AppTheme.Colors.accent
                    : AppTheme.Colors.cardBackground
            )
            .cornerRadius(20)
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. Rooms & Floor (for buildings only)
    private var roomsFloorSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Rooms
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                sectionTitle("rooms")

                HStack {
                    Button { viewModel.decrementRooms() } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }

                    Text("\(viewModel.rooms)")
                        .font(AppTheme.Fonts.heading3())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)

                    Button { viewModel.incrementRooms() } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }

            // Floor
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                sectionTitle("floor")

                HStack(spacing: 4) {
                    TextField("0", text: Binding(
                        get: { "\(viewModel.currentFloor)" },
                        set: { viewModel.currentFloor = Int($0) ?? viewModel.currentFloor }
                    ))
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)

                    Text("/")
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    TextField("0", text: Binding(
                        get: { "\(viewModel.totalFloors)" },
                        set: { viewModel.totalFloors = Int($0) ?? viewModel.totalFloors }
                    ))
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - 4b. House Details (Rooms + Area)
    private var houseDetailsSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Rooms
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                sectionTitle("rooms")

                HStack {
                    Button { viewModel.decrementRooms() } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }

                    Text("\(viewModel.rooms)")
                        .font(AppTheme.Fonts.heading3())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)

                    Button { viewModel.incrementRooms() } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }

            // Area
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                sectionTitle("area_sqm")

                TextField("0", text: $viewModel.totalArea)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.inputBackground)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - 4c. Office Details (Area)
    private var officeDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            sectionTitle("area_sqm")

            TextField("0", text: $viewModel.totalArea)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .keyboardType(.decimalPad)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - 4d. Land Details (Area in Sot)
    private var landDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                sectionTitle("land_area")
                Spacer()
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                TextField("0", text: $viewModel.landAreaSot)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .keyboardType(.numberPad)

                Text("sot")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - 5. Location Picker (City / District / Microdistrict)
    private var locationPickerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("location")

            // Location summary button - opens nested picker
            Button {
                viewModel.showLocationPicker = true
            } label: {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        if viewModel.locationSummary.isEmpty {
                            Text("Şəhər / Rayon / Mikrorayon seçin")
                                .font(AppTheme.Fonts.body())
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        } else {
                            Text(viewModel.locationSummary)
                                .font(AppTheme.Fonts.body())
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

        }
    }

    // MARK: - 6. Address
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("address")

            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.textTertiary)

                TextField("enter_address".localized, text: $viewModel.locationText)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - 7. Price & Area
    private var showAreaInPriceSection: Bool {
        // Hide area here if property type has its own area section
        let typesWithOwnArea: [PropertyType] = [.house, .office, .land]
        return !typesWithOwnArea.contains(viewModel.selectedPropertyType)
    }

    private var priceAreaSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Price with currency selector
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                sectionTitle("price")

                HStack(spacing: AppTheme.Spacing.sm) {
                    // Price input
                    TextField("0", text: $viewModel.price)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.Colors.inputBackground)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                        )

                    // Currency chips
                    HStack(spacing: 4) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            currencyMiniChip(currency: currency)
                        }
                    }
                }
            }

            // Area (only for types that don't have their own area section)
            if showAreaInPriceSection {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    sectionTitle("area_sqm")

                    TextField("0", text: $viewModel.totalArea)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.Colors.inputBackground)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                        )
                }
            }
        }
    }

    private func currencyMiniChip(currency: Currency) -> some View {
        let isSelected = viewModel.selectedCurrency == currency

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedCurrency = currency
            }
        } label: {
            Text(currency.symbol)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .frame(width: 38, height: 38)
                .background(
                    isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground
                )
                .cornerRadius(AppTheme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(
                            isSelected ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 8. Description
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("description")

            ZStack(alignment: .topLeading) {
                if viewModel.descriptionText.isEmpty {
                    Text("Əmlakınızın xüsusiyyətlərini təsvir edin...")
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                }

                TextEditor(text: $viewModel.descriptionText)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
            }
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - 9. Features (no currency here)
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("key_amenities")

            FlowLayout(spacing: AppTheme.Spacing.sm) {
                featureChip(title: "has_elevator".localized, isSelected: $viewModel.hasElevator)

                ForEach(Renovation.allCases, id: \.self) { renovation in
                    renovationChip(renovation: renovation)
                }
            }
        }
    }

    private func featureChip(title: String, isSelected: Binding<Bool>) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSelected.wrappedValue.toggle()
            }
        } label: {
            Text(title)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(
                    isSelected.wrappedValue ? .white : AppTheme.Colors.textSecondary
                )
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    isSelected.wrappedValue
                        ? AppTheme.Colors.accent
                        : AppTheme.Colors.cardBackground
                )
                .cornerRadius(20)
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected.wrappedValue ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func renovationChip(renovation: Renovation) -> some View {
        let isSelected = viewModel.selectedRenovation == renovation

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedRenovation = renovation
            }
        } label: {
            Text(renovation.displayKey.localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground
                )
                .cornerRadius(20)
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Publish Button
    private var publishButton: some View {
        VStack(spacing: 0) {
            Divider().background(AppTheme.Colors.inputBorder)

            Button {
                Task { await viewModel.submit() }
            } label: {
                HStack(spacing: AppTheme.Spacing.sm) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("publish".localized)
                            .font(AppTheme.Fonts.bodyBold())
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.Colors.cyanGradient)
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
            .disabled(viewModel.isSubmitting)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background)
    }

    // MARK: - Location Picker Sheet (City → District → Microdistrict)
    @State private var expandedCityId: String? = nil
    @State private var expandedDistrictId: String? = nil

    private var locationPickerSheet: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(LocationData.cities) { city in
                        VStack(spacing: 0) {
                            // City row
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    if expandedCityId == city.id {
                                        expandedCityId = nil
                                    } else {
                                        expandedCityId = city.id
                                        expandedDistrictId = nil
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "building.2.crop.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(
                                            viewModel.city == city.name
                                                ? AppTheme.Colors.accent
                                                : AppTheme.Colors.textTertiary
                                        )

                                    Text(city.name)
                                        .font(AppTheme.Fonts.bodyBold())
                                        .foregroundColor(AppTheme.Colors.textPrimary)

                                    Spacer()

                                    if viewModel.city == city.name && !viewModel.district.isEmpty {
                                        Text(viewModel.district)
                                            .font(AppTheme.Fonts.small())
                                            .foregroundColor(AppTheme.Colors.accent)
                                    }

                                    Image(systemName: expandedCityId == city.id ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                }
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.vertical, AppTheme.Spacing.md)
                                .background(
                                    viewModel.city == city.name
                                        ? AppTheme.Colors.accent.opacity(0.08)
                                        : Color.clear
                                )
                            }
                            .buttonStyle(.plain)

                            // Districts (expanded)
                            if expandedCityId == city.id {
                                VStack(spacing: 0) {
                                    // "Select city only" option
                                    Button {
                                        viewModel.selectCity(city)
                                        viewModel.showLocationPicker = false
                                    } label: {
                                        HStack {
                                            Image(systemName: "checkmark.circle")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.Colors.accent)

                                            Text("Bütün \(city.name)")
                                                .font(AppTheme.Fonts.caption())
                                                .foregroundColor(AppTheme.Colors.accent)

                                            Spacer()
                                        }
                                        .padding(.horizontal, AppTheme.Spacing.xxl)
                                        .padding(.vertical, AppTheme.Spacing.sm)
                                    }
                                    .buttonStyle(.plain)

                                    ForEach(city.districts) { district in
                                        VStack(spacing: 0) {
                                            // District row
                                            Button {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    if district.microdistricts.isEmpty {
                                                        // No microdistricts - select directly
                                                        viewModel.selectCity(city)
                                                        viewModel.selectDistrict(district.name)
                                                        viewModel.showLocationPicker = false
                                                    } else if expandedDistrictId == district.id {
                                                        expandedDistrictId = nil
                                                    } else {
                                                        expandedDistrictId = district.id
                                                    }
                                                }
                                            } label: {
                                                HStack {
                                                    Image(systemName: "map.circle.fill")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(
                                                            viewModel.district == district.name
                                                                ? AppTheme.Colors.accent
                                                                : AppTheme.Colors.textTertiary
                                                        )

                                                    Text(district.name)
                                                        .font(AppTheme.Fonts.body())
                                                        .foregroundColor(AppTheme.Colors.textPrimary)

                                                    Spacer()

                                                    if viewModel.district == district.name && !viewModel.microdistrict.isEmpty {
                                                        Text(viewModel.microdistrict)
                                                            .font(AppTheme.Fonts.small())
                                                            .foregroundColor(AppTheme.Colors.accent)
                                                    }

                                                    if !district.microdistricts.isEmpty {
                                                        Image(systemName: expandedDistrictId == district.id ? "chevron.up" : "chevron.right")
                                                            .font(.system(size: 11, weight: .medium))
                                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                                    } else if viewModel.district == district.name {
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 13, weight: .semibold))
                                                            .foregroundColor(AppTheme.Colors.accent)
                                                    }
                                                }
                                                .padding(.leading, AppTheme.Spacing.xxl + AppTheme.Spacing.sm)
                                                .padding(.trailing, AppTheme.Spacing.lg)
                                                .padding(.vertical, AppTheme.Spacing.sm)
                                                .background(
                                                    viewModel.district == district.name && viewModel.city == city.name
                                                        ? AppTheme.Colors.accent.opacity(0.05)
                                                        : Color.clear
                                                )
                                            }
                                            .buttonStyle(.plain)

                                            // Microdistricts (expanded)
                                            if expandedDistrictId == district.id {
                                                // "Select district only" option
                                                Button {
                                                    viewModel.selectCity(city)
                                                    viewModel.selectDistrict(district.name)
                                                    viewModel.showLocationPicker = false
                                                } label: {
                                                    HStack {
                                                        Image(systemName: "checkmark.circle")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(AppTheme.Colors.accent)

                                                        Text("Bütün \(district.name)")
                                                            .font(AppTheme.Fonts.small())
                                                            .foregroundColor(AppTheme.Colors.accent)

                                                        Spacer()
                                                    }
                                                    .padding(.leading, AppTheme.Spacing.xxl + AppTheme.Spacing.xxl)
                                                    .padding(.trailing, AppTheme.Spacing.lg)
                                                    .padding(.vertical, AppTheme.Spacing.xs)
                                                }
                                                .buttonStyle(.plain)

                                                ForEach(district.microdistricts, id: \.self) { micro in
                                                    Button {
                                                        viewModel.selectCity(city)
                                                        viewModel.selectDistrict(district.name)
                                                        viewModel.selectMicrodistrict(micro)
                                                        viewModel.showLocationPicker = false
                                                    } label: {
                                                        HStack {
                                                            Text(micro)
                                                                .font(AppTheme.Fonts.caption())
                                                                .foregroundColor(AppTheme.Colors.textSecondary)

                                                            Spacer()

                                                            if viewModel.microdistrict == micro && viewModel.district == district.name {
                                                                Image(systemName: "checkmark")
                                                                    .font(.system(size: 12, weight: .semibold))
                                                                    .foregroundColor(AppTheme.Colors.accent)
                                                            }
                                                        }
                                                        .padding(.leading, AppTheme.Spacing.xxl + AppTheme.Spacing.xxl + AppTheme.Spacing.sm)
                                                        .padding(.trailing, AppTheme.Spacing.lg)
                                                        .padding(.vertical, AppTheme.Spacing.xs)
                                                        .background(
                                                            viewModel.microdistrict == micro && viewModel.district == district.name
                                                                ? AppTheme.Colors.accent.opacity(0.05)
                                                                : Color.clear
                                                        )
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            Divider()
                                .background(AppTheme.Colors.inputBorder)
                        }
                    }
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("location".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        viewModel.showLocationPicker = false
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .toolbarBackground(AppTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
    }

    // MARK: - Error Banner
    private func errorBanner(_ message: String) -> some View {
        VStack {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppTheme.Colors.error)

                Text(message)
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(.white)

                Spacer()

                Button {
                    viewModel.errorMessage = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.sm)

            Spacer()
        }
    }

    // MARK: - Helpers
    private func sectionTitle(_ key: String) -> some View {
        Text(key.localized)
            .font(AppTheme.Fonts.captionBold())
            .foregroundColor(AppTheme.Colors.textSecondary)
            .textCase(.uppercase)
    }
}

// MARK: - Preview
#Preview {
    CreateListingView()
        .preferredColorScheme(.dark)
}
