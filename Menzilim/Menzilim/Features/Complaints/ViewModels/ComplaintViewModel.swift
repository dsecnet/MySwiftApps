import SwiftUI
import Combine
import PhotosUI

// MARK: - Complaint ViewModel
@MainActor
class ComplaintViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var selectedComplaintType: ComplaintType? = nil
    @Published var descriptionText: String = ""
    @Published var screenshotItems: [PhotosPickerItem] = []
    @Published var screenshotImages: [UIImage] = []
    @Published var isSubmitting: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    // Target
    var targetType: ComplaintTargetType = .listing
    var targetId: String = ""

    // MARK: - Validation
    var isFormValid: Bool {
        selectedComplaintType != nil && !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Process Selected Photos
    func processSelectedPhotos() async {
        var images: [UIImage] = []
        for item in screenshotItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        screenshotImages = images
    }

    // MARK: - Remove Screenshot
    func removeScreenshot(at index: Int) {
        guard index < screenshotImages.count else { return }
        screenshotImages.remove(at: index)
        if index < screenshotItems.count {
            screenshotItems.remove(at: index)
        }
    }

    // MARK: - Submit Complaint
    func submitComplaint() {
        guard isFormValid else { return }

        isSubmitting = true

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isSubmitting = false
            self?.showSuccessAlert = true
        }
    }

    // MARK: - Reset Form
    func resetForm() {
        selectedComplaintType = nil
        descriptionText = ""
        screenshotItems = []
        screenshotImages = []
    }
}
