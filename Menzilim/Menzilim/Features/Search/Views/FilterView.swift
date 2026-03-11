import SwiftUI

// MARK: - Filter View (Bottom Sheet)
struct FilterView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Local Filter State
    @State private var selectedListingType: ListingType? = nil
    @State private var selectedPropertyType: PropertyType? = nil
    @State private var minPriceText: String = ""
    @State private var maxPriceText: String = ""
    @State private var selectedRooms: Int? = nil
    @State private var minAreaText: String = ""
    @State private var maxAreaText: String = ""
    @State private var selectedRenovation: Renovation? = nil
    @State private var showRenovationDropdown: Bool = false

    // Price slider
    @State private var priceSliderLow: Double = 0
    @State private var priceSliderHigh: Double = 1_000_000

    private let priceMin: Double = 0
    private let priceMax: Double = 1_000_000

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                header

                // MARK: - Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        // Type: Sale / Rent
                        listingTypeSection

                        // Property Type
                        propertyTypeSection

                        // Price Range
                        priceRangeSection

                        // Number of Rooms
                        roomsSection

                        // Area
                        areaSection

                        // Renovation Status
                        renovationSection
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.bottom, 100)
                }

                // MARK: - Show Results Button
                showResultsButton
            }
        }
        .onAppear {
            loadCurrentFilters()
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Text("filters".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Button {
                resetLocalFilters()
            } label: {
                Text("reset".localized)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.accent)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.lg)
        .background(AppTheme.Colors.cardBackground)
    }

    // MARK: - Listing Type Section (Sale / Rent)
    private var listingTypeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("listing_type")

            HStack(spacing: 0) {
                segmentButton(
                    title: "for_sale".localized,
                    isSelected: selectedListingType == .sale
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedListingType = selectedListingType == .sale ? nil : .sale
                    }
                }

                segmentButton(
                    title: "for_rent".localized,
                    isSelected: selectedListingType == .rent
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedListingType = selectedListingType == .rent ? nil : .rent
                    }
                }
            }
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
        }
    }

    private func segmentButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    isSelected
                        ? AppTheme.Colors.accent
                        : Color.clear
                )
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .padding(2)
    }

    // MARK: - Property Type Section
    private var propertyTypeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("property_type")

            let columns = [
                GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
                GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
                GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
            ]

            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.sm) {
                // "Any" option
                propertyTypeChip(title: "any".localized, type: nil)

                ForEach(PropertyType.allCases, id: \.self) { type in
                    propertyTypeChip(
                        title: type.displayKey.localized,
                        type: type
                    )
                }
            }
        }
    }

    private func propertyTypeChip(title: String, type: PropertyType?) -> some View {
        let isSelected = selectedPropertyType == type

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPropertyType = type
            }
        } label: {
            HStack(spacing: 4) {
                if let type = type {
                    Image(systemName: type.icon)
                        .font(.system(size: 11))
                }

                Text(title)
                    .font(AppTheme.Fonts.small())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                isSelected
                    ? AppTheme.Colors.accent
                    : AppTheme.Colors.inputBackground
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
    }

    // MARK: - Price Range Section
    private var priceRangeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("price_range")

            // Dual Slider
            dualPriceSlider

            // Min/Max Text Fields
            HStack(spacing: AppTheme.Spacing.md) {
                priceInputField(
                    placeholder: "Min",
                    text: $minPriceText
                )

                Text("-")
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textTertiary)

                priceInputField(
                    placeholder: "Max",
                    text: $maxPriceText
                )

                Text("AZN")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.accent)
            }
        }
    }

    private var dualPriceSlider: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let lowFraction = (priceSliderLow - priceMin) / (priceMax - priceMin)
            let highFraction = (priceSliderHigh - priceMin) / (priceMax - priceMin)

            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.Colors.inputBorder)
                    .frame(height: 4)

                // Active track
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.Colors.accent)
                    .frame(
                        width: CGFloat(highFraction - lowFraction) * width,
                        height: 4
                    )
                    .offset(x: CGFloat(lowFraction) * width)

                // Low thumb
                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 22, height: 22)
                    .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 4)
                    .offset(x: CGFloat(lowFraction) * width - 11)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = priceMin + Double(value.location.x / width) * (priceMax - priceMin)
                                priceSliderLow = min(max(newValue, priceMin), priceSliderHigh - 10000)
                                minPriceText = formatPrice(priceSliderLow)
                            }
                    )

                // High thumb
                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 22, height: 22)
                    .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 4)
                    .offset(x: CGFloat(highFraction) * width - 11)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = priceMin + Double(value.location.x / width) * (priceMax - priceMin)
                                priceSliderHigh = min(max(newValue, priceSliderLow + 10000), priceMax)
                                maxPriceText = formatPrice(priceSliderHigh)
                            }
                    )
            }
        }
        .frame(height: 30)
        .padding(.horizontal, AppTheme.Spacing.sm)
    }

    private func priceInputField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(AppTheme.Fonts.caption())
            .foregroundColor(AppTheme.Colors.textPrimary)
            .keyboardType(.numberPad)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
    }

    // MARK: - Rooms Section
    private var roomsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("number_of_rooms")

            HStack(spacing: AppTheme.Spacing.sm) {
                roomChip(title: "any".localized, value: nil)
                roomChip(title: "1", value: 1)
                roomChip(title: "2", value: 2)
                roomChip(title: "3", value: 3)
                roomChip(title: "4+", value: 4)
            }
        }
    }

    private func roomChip(title: String, value: Int?) -> some View {
        let isSelected = selectedRooms == value

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedRooms = value
            }
        } label: {
            Text(title)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    isSelected
                        ? AppTheme.Colors.accent
                        : AppTheme.Colors.inputBackground
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
    }

    // MARK: - Area Section
    private var areaSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("area_range")

            HStack(spacing: AppTheme.Spacing.md) {
                areaInputField(placeholder: "Min m\u{00B2}", text: $minAreaText)

                Text("-")
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textTertiary)

                areaInputField(placeholder: "Max m\u{00B2}", text: $maxAreaText)
            }
        }
    }

    private func areaInputField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(AppTheme.Fonts.caption())
            .foregroundColor(AppTheme.Colors.textPrimary)
            .keyboardType(.numberPad)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
    }

    // MARK: - Renovation Section
    private var renovationSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionTitle("renovation_status")

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showRenovationDropdown.toggle()
                }
            } label: {
                HStack {
                    Text(
                        selectedRenovation?.displayKey.localized
                            ?? "any".localized
                    )
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(
                        selectedRenovation != nil
                            ? AppTheme.Colors.textPrimary
                            : AppTheme.Colors.textTertiary
                    )

                    Spacer()

                    Image(systemName: showRenovationDropdown ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }

            if showRenovationDropdown {
                VStack(spacing: 0) {
                    renovationOption(title: "any".localized, value: nil)

                    ForEach(Renovation.allCases, id: \.self) { renovation in
                        Divider().background(AppTheme.Colors.inputBorder)
                        renovationOption(
                            title: renovation.displayKey.localized,
                            value: renovation
                        )
                    }
                }
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func renovationOption(title: String, value: Renovation?) -> some View {
        let isSelected = selectedRenovation == value

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedRenovation = value
                showRenovationDropdown = false
            }
        } label: {
            HStack {
                Text(title)
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.textPrimary
                    )

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }

    // MARK: - Show Results Button
    private var showResultsButton: some View {
        VStack(spacing: 0) {
            Divider().background(AppTheme.Colors.inputBorder)

            Button {
                commitFilters()
                dismiss()
            } label: {
                HStack {
                    Text("\("show_results".localized) (\(viewModel.totalResults))")
                        .font(AppTheme.Fonts.bodyBold())
                        .foregroundColor(.white)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.Colors.cyanGradient)
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
    }

    // MARK: - Helpers
    private func sectionTitle(_ key: String) -> some View {
        Text(key.localized)
            .font(AppTheme.Fonts.captionBold())
            .foregroundColor(AppTheme.Colors.textSecondary)
            .textCase(.uppercase)
    }

    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    // MARK: - Load / Save Filters
    private func loadCurrentFilters() {
        selectedListingType = viewModel.filter.listingType
        selectedPropertyType = viewModel.filter.propertyType
        selectedRooms = viewModel.filter.rooms
        selectedRenovation = viewModel.filter.renovation

        if let min = viewModel.filter.minPrice {
            minPriceText = formatPrice(min)
            priceSliderLow = min
        }
        if let max = viewModel.filter.maxPrice {
            maxPriceText = formatPrice(max)
            priceSliderHigh = max
        }
        if let minArea = viewModel.filter.minArea {
            minAreaText = "\(Int(minArea))"
        }
        if let maxArea = viewModel.filter.maxArea {
            maxAreaText = "\(Int(maxArea))"
        }
    }

    private func commitFilters() {
        viewModel.filter.listingType = selectedListingType
        viewModel.filter.propertyType = selectedPropertyType
        viewModel.filter.rooms = selectedRooms
        viewModel.filter.renovation = selectedRenovation

        viewModel.filter.minPrice = Double(minPriceText.replacingOccurrences(of: ",", with: ""))
        viewModel.filter.maxPrice = Double(maxPriceText.replacingOccurrences(of: ",", with: ""))
        viewModel.filter.minArea = Double(minAreaText)
        viewModel.filter.maxArea = Double(maxAreaText)

        viewModel.applyFilters()
    }

    private func resetLocalFilters() {
        selectedListingType = nil
        selectedPropertyType = nil
        minPriceText = ""
        maxPriceText = ""
        priceSliderLow = priceMin
        priceSliderHigh = priceMax
        selectedRooms = nil
        minAreaText = ""
        maxAreaText = ""
        selectedRenovation = nil
        showRenovationDropdown = false

        viewModel.resetFilters()
    }
}

// MARK: - Preview
#Preview {
    FilterView(viewModel: SearchViewModel())
        .preferredColorScheme(.dark)
}
