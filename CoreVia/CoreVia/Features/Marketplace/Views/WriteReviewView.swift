import SwiftUI

/// Write Review View
struct WriteReviewView: View {
    let productId: String
    let onReviewSubmitted: () -> Void

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: WriteReviewViewModel
    let loc = LocalizationManager.shared

    init(productId: String, onReviewSubmitted: @escaping () -> Void) {
        self.productId = productId
        self.onReviewSubmitted = onReviewSubmitted
        _viewModel = StateObject(wrappedValue: WriteReviewViewModel(productId: productId))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Rating Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.localized("marketplace_your_rating"))
                            .font(.headline)

                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { rating in
                                Button {
                                    viewModel.rating = rating
                                } label: {
                                    Image(systemName: rating <= viewModel.rating ? "star.fill" : "star")
                                        .font(.title)
                                        .foregroundColor(rating <= viewModel.rating ? .yellow : .gray)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    // Comment
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("marketplace_your_review"))
                            .font(.headline)

                        TextEditor(text: $viewModel.comment)
                            .frame(minHeight: 120)
                    }
                } header: {
                    Text(loc.localized("marketplace_optional"))
                }

                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(loc.localized("marketplace_write_review"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.localized("common_cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.localized("marketplace_submit")) {
                        Task {
                            let success = await viewModel.submitReview()
                            if success {
                                onReviewSubmitted()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.rating == 0 || viewModel.isSubmitting)
                }
            }
            .overlay {
                if viewModel.isSubmitting {
                    LoadingOverlay()
                }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
class WriteReviewViewModel: ObservableObject {
    let productId: String

    @Published var rating: Int = 0
    @Published var comment: String = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    init(productId: String) {
        self.productId = productId
    }

    func submitReview() async -> Bool {
        guard rating > 0 else {
            errorMessage = "Please select a rating"
            return false
        }

        isSubmitting = true
        errorMessage = nil

        do {
            let request = CreateReviewRequest(
                productId: productId,
                rating: rating,
                comment: comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment
            )

            let _: ProductReview = try await APIService.shared.request(
                endpoint: "/api/v1/marketplace/reviews",
                method: "POST",
                body: request
            )

            isSubmitting = false
            return true

        } catch {
            errorMessage = error.localizedDescription
            isSubmitting = false
            return false
        }
    }
}

#Preview {
    WriteReviewView(productId: "123") {
        print("Review submitted")
    }
}
