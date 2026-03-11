import SwiftUI
import PhotosUI
import Combine

// MARK: - Create Listing ViewModel
@MainActor
class CreateListingViewModel: ObservableObject {

    // MARK: - Step Management
    enum Step: Int, CaseIterable {
        case basicDetails = 0
        case propertyDetails = 1
        case mediaDescription = 2
        case preview = 3

        var titleKey: String {
            switch self {
            case .basicDetails: return "basic_details"
            case .propertyDetails: return "property_details"
            case .mediaDescription: return "photos_media"
            case .preview: return "preview"
            }
        }

        var stepNumber: Int { rawValue + 1 }
    }

    static let totalSteps = Step.allCases.count

    @Published var currentStep: Step = .basicDetails

    // MARK: - Step 1: Basic Details
    @Published var isResidential: Bool = true
    @Published var selectedPropertyType: PropertyType = .oldBuilding
    @Published var selectedListingType: ListingType = .sale
    @Published var locationText: String = ""
    @Published var selectedCity: AzerbaijanCity? = LocationData.cities.first
    @Published var city: String = "Bakı"
    @Published var district: String = ""
    @Published var microdistrict: String = ""

    // Photos
    @Published var selectedImages: [UIImage] = []
    @Published var photoPickerItems: [PhotosPickerItem] = []

    // MARK: - Step 2: Property Details
    @Published var rooms: Int = 2
    @Published var totalArea: String = ""
    @Published var landAreaSot: String = ""
    @Published var currentFloor: Int = 5
    @Published var totalFloors: Int = 16
    @Published var hasElevator: Bool = false
    @Published var selectedRenovation: Renovation = .none
    @Published var price: String = ""
    @Published var selectedCurrency: Currency = .AZN

    // MARK: - Step 3: Media & Description
    @Published var title: String = ""
    @Published var descriptionText: String = ""
    @Published var videoUrl: String = ""

    // MARK: - State
    @Published var isLoading: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var showSuccess: Bool = false
    @Published var errorMessage: String?

    // MARK: - Validation
    @Published var validationErrors: [String: String] = [:]

    // MARK: - Location Picker
    @Published var showLocationPicker: Bool = false

    // MARK: - Location Selection
    func selectCity(_ city: AzerbaijanCity) {
        selectedCity = city
        self.city = city.name
        district = ""
        microdistrict = ""
    }

    func selectDistrict(_ districtName: String) {
        district = districtName
        microdistrict = ""
    }

    func selectMicrodistrict(_ name: String) {
        microdistrict = name
    }

    var selectedCityDistricts: [CityDistrict] {
        selectedCity?.districts ?? []
    }

    var selectedDistrictMicrodistricts: [String] {
        selectedCity?.districts.first { $0.name == district }?.microdistricts ?? []
    }

    var locationSummary: String {
        var parts: [String] = []
        if !city.isEmpty { parts.append(city) }
        if !district.isEmpty { parts.append(district) }
        if !microdistrict.isEmpty { parts.append(microdistrict) }
        return parts.joined(separator: ", ")
    }

    // MARK: - Dependencies
    private let apiService = APIService.shared

    // MARK: - Progress
    var progress: Double {
        Double(currentStep.rawValue + 1) / Double(Self.totalSteps)
    }

    var currentStepLabel: String {
        String(format: "step_of".localized, currentStep.stepNumber, Self.totalSteps)
    }

    // MARK: - Navigation
    var canGoBack: Bool {
        currentStep.rawValue > 0
    }

    var canGoForward: Bool {
        currentStep.rawValue < Self.totalSteps - 1
    }

    var isLastStep: Bool {
        currentStep == .preview
    }

    func nextStep() {
        guard validateCurrentStep() else { return }

        if let next = Step(rawValue: currentStep.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = next
            }
        }
    }

    func previousStep() {
        if let prev = Step(rawValue: currentStep.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = prev
            }
        }
    }

    func goToStep(_ step: Step) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
        }
    }

    // MARK: - Validation
    func validateCurrentStep() -> Bool {
        validationErrors.removeAll()

        switch currentStep {
        case .basicDetails:
            return validateBasicDetails()
        case .propertyDetails:
            return validatePropertyDetails()
        case .mediaDescription:
            return validateMediaDescription()
        case .preview:
            return true
        }
    }

    private func validateBasicDetails() -> Bool {
        var isValid = true

        if locationText.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["location"] = "enter_address".localized
            isValid = false
        }

        return isValid
    }

    private func validatePropertyDetails() -> Bool {
        var isValid = true

        if totalArea.isEmpty || (Double(totalArea) ?? 0) <= 0 {
            validationErrors["totalArea"] = "total_area".localized
            isValid = false
        }

        if price.isEmpty || (Double(price) ?? 0) <= 0 {
            validationErrors["price"] = "price".localized
            isValid = false
        }

        return isValid
    }

    private func validateMediaDescription() -> Bool {
        var isValid = true

        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["title"] = "basic_details".localized
            isValid = false
        }

        if descriptionText.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["description"] = "description".localized
            isValid = false
        }

        return isValid
    }

    // MARK: - Image Selection
    func loadImages() {
        Task {
            var newImages: [UIImage] = []
            for item in photoPickerItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    newImages.append(image)
                }
            }
            let remaining = 10 - selectedImages.count
            selectedImages.append(contentsOf: newImages.prefix(remaining))
        }
    }

    var canAddMorePhotos: Bool {
        selectedImages.count < 10
    }

    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }

    // MARK: - Floor Steppers
    func incrementCurrentFloor() {
        if currentFloor < totalFloors {
            currentFloor += 1
        }
    }

    func decrementCurrentFloor() {
        if currentFloor > 1 {
            currentFloor -= 1
        }
    }

    func incrementTotalFloors() {
        totalFloors += 1
    }

    func decrementTotalFloors() {
        if totalFloors > currentFloor {
            totalFloors -= 1
        }
    }

    func incrementRooms() {
        rooms += 1
    }

    func decrementRooms() {
        if rooms > 1 {
            rooms -= 1
        }
    }

    // MARK: - Submit
    func submit() async {
        guard validateAllSteps() else { return }

        isSubmitting = true
        errorMessage = nil

        do {
            // Upload images first
            var imageUrls: [String] = []
            for image in selectedImages {
                if let data = image.jpegData(compressionQuality: 0.8) {
                    let uiImage = UIImage(data: data) ?? UIImage()
                    let url = try await ImageUploadService.shared.uploadImage(uiImage)
                    imageUrls.append(url)
                }
            }

            let request = CreateListingRequest(
                title: title,
                description: descriptionText,
                listingType: selectedListingType.rawValue,
                propertyType: selectedPropertyType.rawValue,
                price: Double(price) ?? 0,
                currency: selectedCurrency.rawValue,
                city: city,
                district: district,
                address: locationText,
                latitude: selectedCity?.coordinate.latitude,
                longitude: selectedCity?.coordinate.longitude,
                rooms: rooms,
                areaSqm: selectedPropertyType == .land
                    ? (Double(landAreaSot) ?? 0) * 100  // Convert sot to sqm
                    : Double(totalArea) ?? 0,
                floor: currentFloor,
                totalFloors: totalFloors,
                renovation: selectedRenovation.rawValue,
                images: imageUrls,
                videoUrl: videoUrl.isEmpty ? nil : videoUrl
            )

            let _: Listing = try await apiService.request(
                endpoint: "/listings",
                method: .POST,
                body: request
            )

            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    // MARK: - Save Draft
    func saveDraft() {
        // Save to UserDefaults or local storage
        // This is a placeholder for draft persistence
    }

    // MARK: - Validate All
    private func validateAllSteps() -> Bool {
        validationErrors.removeAll()
        let basic = validateBasicDetails()
        let details = validatePropertyDetails()
        let media = validateMediaDescription()
        return basic && details && media
    }

    // MARK: - Reset
    func reset() {
        currentStep = .basicDetails
        isResidential = true
        selectedPropertyType = .oldBuilding
        selectedListingType = .sale
        locationText = ""
        selectedCity = LocationData.cities.first
        city = "Bakı"
        district = ""
        microdistrict = ""
        selectedImages = []
        photoPickerItems = []
        rooms = 2
        totalArea = ""
        landAreaSot = ""
        currentFloor = 5
        totalFloors = 16
        hasElevator = false
        price = ""
        selectedCurrency = .AZN
        title = ""
        descriptionText = ""
        videoUrl = ""
        validationErrors.removeAll()
        errorMessage = nil
        showSuccess = false
    }

    // MARK: - Preview Helpers
    var previewFormattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let value = Double(price) ?? 0
        let priceStr = formatter.string(from: NSNumber(value: value)) ?? price
        return "\(priceStr) \(selectedCurrency.symbol)"
    }

    var previewFloorInfo: String {
        "\(currentFloor)/\(totalFloors)"
    }
}
