import SwiftUI
import PhotosUI

// MARK: - Create Listing View
struct CreateListingView: View {
    @StateObject private var viewModel = CreateListingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Navigation Header
                navigationHeader

                // MARK: - Step Indicator
                stepIndicator

                // MARK: - Progress Bar
                progressBar

                // MARK: - Step Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        switch viewModel.currentStep {
                        case .basicDetails:
                            step1BasicDetails
                        case .propertyDetails:
                            step2PropertyDetails
                        case .mediaDescription:
                            step3MediaDescription
                        case .preview:
                            step4Preview
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.bottom, 120)
                }

                // MARK: - Bottom Buttons
                bottomButtons
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
            Text("publish".localized)
        }
    }

    // MARK: - Navigation Header
    private var navigationHeader: some View {
        HStack {
            Button {
                if viewModel.canGoBack {
                    viewModel.previousStep()
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("post_property".localized)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            // Balance spacer
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
    }

    // MARK: - Step Indicator
    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(CreateListingViewModel.Step.allCases, id: \.self) { step in
                // Circle
                ZStack {
                    Circle()
                        .fill(
                            step.rawValue <= viewModel.currentStep.rawValue
                                ? AppTheme.Colors.accent
                                : AppTheme.Colors.inputBackground
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(
                                    step.rawValue <= viewModel.currentStep.rawValue
                                        ? AppTheme.Colors.accent
                                        : AppTheme.Colors.inputBorder,
                                    lineWidth: 2
                                )
                        )

                    if step.rawValue < viewModel.currentStep.rawValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(step.stepNumber)")
                            .font(AppTheme.Fonts.smallBold())
                            .foregroundColor(
                                step.rawValue == viewModel.currentStep.rawValue
                                    ? .white
                                    : AppTheme.Colors.textTertiary
                            )
                    }
                }
                .onTapGesture {
                    if step.rawValue <= viewModel.currentStep.rawValue {
                        viewModel.goToStep(step)
                    }
                }

                // Connecting line
                if step.rawValue < CreateListingViewModel.totalSteps - 1 {
                    Rectangle()
                        .fill(
                            step.rawValue < viewModel.currentStep.rawValue
                                ? AppTheme.Colors.accent
                                : AppTheme.Colors.inputBorder
                        )
                        .frame(height: 2)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xxxl)
        .padding(.vertical, AppTheme.Spacing.md)
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.Colors.inputBorder)
                        .frame(height: 3)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.Colors.accent)
                        .frame(width: geometry.size.width * viewModel.progress, height: 3)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                }
            }
            .frame(height: 3)

            Text(viewModel.currentStepLabel)
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.sm)
    }

    // MARK: - Step 1: Basic Details
    private var step1BasicDetails: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
            // Property Type (Residential / Commercial)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                sectionTitle("property_type_label")

                HStack(spacing: 0) {
                    toggleSegment(
                        title: "residential".localized,
                        isSelected: viewModel.isResidential
                    ) {
                        viewModel.isResidential = true
                    }

                    toggleSegment(
                        title: "commercial_type".localized,
                        isSelected: !viewModel.isResidential
                    ) {
                        viewModel.isResidential = false
                    }
                }
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }

            // Deal Type (For Sale / For Rent)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                sectionTitle("deal_type")

                HStack(spacing: AppTheme.Spacing.md) {
                    dealTypeCard(
                        type: .sale,
                        icon: "tag.fill",
                        isSelected: viewModel.selectedListingType == .sale
                    )
                    dealTypeCard(
                        type: .rent,
                        icon: "key.fill",
                        isSelected: viewModel.selectedListingType == .rent
                    )
                }
            }

            // Location
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                sectionTitle("location")

                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    TextField("enter_address".localized, text: $viewModel.locationText)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .autocorrectionDisabled()

                    Button {
                        // Use current location
                    } label: {
                        Text("current_location".localized)
                            .font(AppTheme.Fonts.smallBold())
                            .foregroundColor(AppTheme.Colors.accent)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(AppTheme.Colors.accent.opacity(0.12))
                            .cornerRadius(AppTheme.CornerRadius.small)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(
                            viewModel.validationErrors["location"] != nil
                                ? AppTheme.Colors.error
                                : AppTheme.Colors.inputBorder,
                            lineWidth: 1
                        )
                )

                if let error = viewModel.validationErrors["location"] {
                    Text(error)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.error)
                }
            }

            // Photos
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                sectionTitle("add_photos")

                Text("photos_hint".localized)
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.textTertiary)

                photosGrid
            }
        }
    }

    private func toggleSegment(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? AppTheme.Colors.accent : Color.clear)
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .padding(2)
    }

    private func dealTypeCard(type: ListingType, icon: String, isSelected: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedListingType = type
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.textTertiary
                    )

                Text(type.displayKey.localized)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(
                        isSelected ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                isSelected
                    ? AppTheme.Colors.accent.opacity(0.1)
                    : AppTheme.Colors.cardBackground
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }

    // MARK: - Photos Grid
    private var photosGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
            GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
            GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
        ]

        return LazyVGrid(columns: columns, spacing: AppTheme.Spacing.sm) {
            // Add photo button
            PhotosPicker(
                selection: $viewModel.photoPickerItems,
                maxSelectionCount: 20,
                matching: .images
            ) {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.Colors.accent)

                    Text("add_photos".localized)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.inputBorder, style: StrokeStyle(lineWidth: 1, dash: [6]))
                )
            }
            .onChange(of: viewModel.photoPickerItems) { _ in
                viewModel.loadImages()
            }

            // Selected images
            ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: viewModel.selectedImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(AppTheme.CornerRadius.medium)

                    // Remove button
                    Button {
                        viewModel.removeImage(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5).clipShape(Circle()))
                    }
                    .padding(4)

                    // First image indicator
                    if index == 0 {
                        VStack {
                            Spacer()
                            Text("1")
                                .font(AppTheme.Fonts.smallBold())
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(AppTheme.Colors.accent)
                                .clipShape(Circle())
                                .padding(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Property Details
    private var step2PropertyDetails: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
            // Dimensions
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                sectionTitle("property_details")

                // Rooms stepper
                stepperRow(
                    label: "room_size".localized,
                    suffix: "",
                    value: viewModel.rooms,
                    onIncrement: { viewModel.incrementRooms() },
                    onDecrement: { viewModel.decrementRooms() }
                )

                // Total area
                inputFieldWithSuffix(
                    label: "total_area".localized,
                    placeholder: "0",
                    text: $viewModel.totalArea,
                    suffix: "m\u{00B2}",
                    error: viewModel.validationErrors["totalArea"]
                )
            }

            // Floor Details
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                sectionTitle("floor")

                stepperRow(
                    label: "current_floor".localized,
                    suffix: "",
                    value: viewModel.currentFloor,
                    onIncrement: { viewModel.incrementCurrentFloor() },
                    onDecrement: { viewModel.decrementCurrentFloor() }
                )

                stepperRow(
                    label: "total_floors".localized,
                    suffix: "",
                    value: viewModel.totalFloors,
                    onIncrement: { viewModel.incrementTotalFloors() },
                    onDecrement: { viewModel.decrementTotalFloors() }
                )

                // Elevator checkbox
                Button {
                    viewModel.hasElevator.toggle()
                } label: {
                    HStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: viewModel.hasElevator ? "checkmark.square.fill" : "square")
                            .font(.system(size: 22))
                            .foregroundColor(
                                viewModel.hasElevator
                                    ? AppTheme.Colors.accent
                                    : AppTheme.Colors.textTertiary
                            )

                        Text("has_elevator".localized)
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }

            // Pricing
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                sectionTitle("total_price")

                HStack(spacing: AppTheme.Spacing.md) {
                    // Price input
                    TextField("0", text: $viewModel.price)
                        .font(AppTheme.Fonts.price())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.Colors.inputBackground)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(
                                    viewModel.validationErrors["price"] != nil
                                        ? AppTheme.Colors.error
                                        : AppTheme.Colors.inputBorder,
                                    lineWidth: 1
                                )
                        )

                    // Currency toggle
                    currencyToggle
                }

                if let error = viewModel.validationErrors["price"] {
                    Text(error)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.error)
                }
            }
        }
    }

    private func stepperRow(
        label: String,
        suffix: String,
        value: Int,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(label)
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            HStack(spacing: AppTheme.Spacing.lg) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }

                Text("\(value)\(suffix)")
                    .font(AppTheme.Fonts.heading3())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(minWidth: 40)

                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }

    private func inputFieldWithSuffix(
        label: String,
        placeholder: String,
        text: Binding<String>,
        suffix: String,
        error: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(label)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()

                HStack(spacing: AppTheme.Spacing.sm) {
                    TextField(placeholder, text: text)
                        .font(AppTheme.Fonts.heading3())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)

                    Text(suffix)
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(
                        error != nil ? AppTheme.Colors.error : Color.clear,
                        lineWidth: 1
                    )
            )

            if let error = error {
                Text(error)
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.error)
            }
        }
    }

    private var currencyToggle: some View {
        HStack(spacing: 0) {
            ForEach([Currency.AZN, Currency.USD], id: \.self) { currency in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedCurrency = currency
                    }
                } label: {
                    Text(currency.rawValue)
                        .font(AppTheme.Fonts.smallBold())
                        .foregroundColor(
                            viewModel.selectedCurrency == currency
                                ? .white
                                : AppTheme.Colors.textSecondary
                        )
                        .frame(width: 50, height: 40)
                        .background(
                            viewModel.selectedCurrency == currency
                                ? AppTheme.Colors.accent
                                : Color.clear
                        )
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
            }
        }
        .padding(2)
        .background(AppTheme.Colors.inputBackground)
        .cornerRadius(AppTheme.CornerRadius.small)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
        )
    }

    // MARK: - Step 3: Media & Description
    private var step3MediaDescription: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
            // Title
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                sectionTitle("basic_details")

                TextField("basic_details".localized, text: $viewModel.title)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.inputBackground)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(
                                viewModel.validationErrors["title"] != nil
                                    ? AppTheme.Colors.error
                                    : AppTheme.Colors.inputBorder,
                                lineWidth: 1
                            )
                    )

                if let error = viewModel.validationErrors["title"] {
                    Text(error)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.error)
                }
            }

            // Description
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                sectionTitle("description")

                TextEditor(text: $viewModel.descriptionText)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.inputBackground)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(
                                viewModel.validationErrors["description"] != nil
                                    ? AppTheme.Colors.error
                                    : AppTheme.Colors.inputBorder,
                                lineWidth: 1
                            )
                    )

                if let error = viewModel.validationErrors["description"] {
                    Text(error)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.error)
                }
            }

            // Video URL
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack {
                    sectionTitle("Video URL")

                    Text("(\("skip".localized))")
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }

                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    TextField("https://...", text: $viewModel.videoUrl)
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
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

    // MARK: - Step 4: Preview
    private var step4Preview: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            // Preview Header
            Text("preview".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Preview Card
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                // Images preview
                if !viewModel.selectedImages.isEmpty {
                    TabView {
                        ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                            Image(uiImage: viewModel.selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 220)
                    .cornerRadius(AppTheme.CornerRadius.large)
                } else {
                    Rectangle()
                        .fill(AppTheme.Colors.surfaceBackground)
                        .frame(height: 220)
                        .cornerRadius(AppTheme.CornerRadius.large)
                        .overlay(
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                                Text("add_photos".localized)
                                    .font(AppTheme.Fonts.caption())
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            }
                        )
                }

                // Price
                HStack {
                    Text(viewModel.previewFormattedPrice)
                        .font(AppTheme.Fonts.price())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()

                    Text(viewModel.selectedListingType.displayKey.localized)
                        .font(AppTheme.Fonts.smallBold())
                        .foregroundColor(AppTheme.Colors.accent)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.Colors.accent.opacity(0.15))
                        .cornerRadius(AppTheme.CornerRadius.small)
                }

                // Title
                Text(viewModel.title.isEmpty ? "---" : viewModel.title)
                    .font(AppTheme.Fonts.title())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                // Location
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    Text(viewModel.locationText.isEmpty ? "---" : viewModel.locationText)
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Divider().background(AppTheme.Colors.inputBorder)

                // Details
                HStack(spacing: AppTheme.Spacing.lg) {
                    previewDetail(icon: "bed.double.fill", value: "\(viewModel.rooms)", label: "rooms".localized)
                    previewDetailDivider
                    previewDetail(icon: "ruler.fill", value: viewModel.totalArea.isEmpty ? "0" : viewModel.totalArea, label: "m\u{00B2}")
                    previewDetailDivider
                    previewDetail(icon: "building.2.fill", value: viewModel.previewFloorInfo, label: "floor".localized)
                }

                Divider().background(AppTheme.Colors.inputBorder)

                // Description preview
                if !viewModel.descriptionText.isEmpty {
                    Text(viewModel.descriptionText)
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(4)
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
        }
    }

    private func previewDetail(icon: String, value: String, label: String) -> some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.accent)

            Text(value)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(label)
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
    }

    private var previewDetailDivider: some View {
        Rectangle()
            .fill(AppTheme.Colors.inputBorder)
            .frame(width: 1, height: 16)
    }

    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        VStack(spacing: 0) {
            Divider().background(AppTheme.Colors.inputBorder)

            HStack(spacing: AppTheme.Spacing.md) {
                // Save Draft
                Button {
                    viewModel.saveDraft()
                } label: {
                    Text("save_draft".localized)
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                        )
                }

                // Next Step / Publish
                Button {
                    if viewModel.isLastStep {
                        Task {
                            await viewModel.submit()
                        }
                    } else {
                        viewModel.nextStep()
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text(
                                viewModel.isLastStep
                                    ? "publish".localized
                                    : "next_step".localized
                            )
                            .font(AppTheme.Fonts.bodyBold())
                            .foregroundColor(.white)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.Colors.cyanGradient)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
                .disabled(viewModel.isSubmitting)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background)
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
