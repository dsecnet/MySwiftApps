import SwiftUI
import StoreKit

/// Product Detail View with Purchase Flow
struct ProductDetailView: View {
    let productId: String
    @StateObject private var viewModel: ProductDetailViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showPurchaseConfirmation = false
    @State private var showReviewSheet = false

    init(productId: String) {
        self.productId = productId
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productId: productId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let product = viewModel.product {
                    // Cover Image
                    coverImageSection(product: product)

                    VStack(alignment: .leading, spacing: 20) {
                        // Product Info
                        productInfoSection(product: product)

                        Divider()

                        // Description
                        descriptionSection(product: product)

                        Divider()

                        // Seller Info
                        sellerSection(product: product)

                        Divider()

                        // Reviews
                        reviewsSection
                    }
                    .padding()
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Product not found")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if let product = viewModel.product {
                purchaseButton(product: product)
            }
        }
        .task {
            await viewModel.loadProduct()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .sheet(isPresented: $showReviewSheet) {
            if let product = viewModel.product {
                WriteReviewView(productId: product.id) {
                    Task {
                        await viewModel.loadReviews()
                    }
                }
            }
        }
    }

    // MARK: - Cover Image

    private func coverImageSection(product: MarketplaceProduct) -> some View {
        Group {
            if let imageUrl = product.coverImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(height: 250)
                .clipped()
            } else {
                ZStack {
                    Color("PrimaryColor").opacity(0.1)
                    Image(systemName: productIcon(product.productType))
                        .font(.system(size: 80))
                        .foregroundColor(Color("PrimaryColor"))
                }
                .frame(height: 250)
            }
        }
    }

    // MARK: - Product Info

    private func productInfoSection(product: MarketplaceProduct) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Type Badge
            Text(loc.localized("marketplace_\(product.productType)"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryColor"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color("PrimaryColor").opacity(0.1))
                .cornerRadius(8)

            // Title
            Text(product.title)
                .font(.title2)
                .fontWeight(.bold)

            // Rating
            if let rating = product.averageRating, let count = product.reviewCount {
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    Text(String(format: "%.1f", rating))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("(\(count) \(loc.localized("marketplace_reviews")))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            // Price
            Text("\(String(format: "%.2f", product.price)) \(product.currency)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryColor"))
        }
    }

    // MARK: - Description

    private func descriptionSection(product: MarketplaceProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.localized("marketplace_description"))
                .font(.headline)

            Text(product.description)
                .font(.body)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Seller

    private func sellerSection(product: MarketplaceProduct) -> some View {
        Group {
            if let seller = product.seller {
                HStack(spacing: 12) {
                    // Seller Image
                    if let imageUrl = seller.profileImageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color(.systemGray5))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color("PrimaryColor").opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Text(seller.name.prefix(1).uppercased())
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("PrimaryColor"))
                            }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.localized("marketplace_sold_by"))
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(seller.name)
                            .font(.headline)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(loc.localized("marketplace_reviews"))
                    .font(.headline)

                Spacer()

                if viewModel.hasPurchased {
                    Button {
                        showReviewSheet = true
                    } label: {
                        Text(loc.localized("marketplace_write_review"))
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryColor"))
                    }
                }
            }

            if viewModel.reviews.isEmpty {
                Text(loc.localized("marketplace_no_reviews"))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.reviews.prefix(3)) { review in
                    ReviewRow(review: review)
                }

                if viewModel.reviews.count > 3 {
                    Button {
                        // Show all reviews
                    } label: {
                        Text(loc.localized("marketplace_see_all_reviews"))
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryColor"))
                    }
                }
            }
        }
    }

    // MARK: - Purchase Button

    private func purchaseButton(product: MarketplaceProduct) -> some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(loc.localized("marketplace_price"))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(String(format: "%.2f", product.price)) \(product.currency)")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Spacer()

                Button {
                    showPurchaseConfirmation = true
                } label: {
                    Text(viewModel.hasPurchased ? loc.localized("marketplace_purchased") : loc.localized("marketplace_buy_now"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.hasPurchased ? Color.gray : Color("PrimaryColor"))
                        .cornerRadius(12)
                }
                .disabled(viewModel.hasPurchased || viewModel.isPurchasing)
                .frame(width: 180)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .confirmationDialog(
            loc.localized("marketplace_confirm_purchase"),
            isPresented: $showPurchaseConfirmation,
            titleVisibility: .visible
        ) {
            Button(loc.localized("marketplace_buy_now")) {
                Task {
                    await viewModel.purchaseProduct()
                }
            }
            Button(loc.localized("common_cancel"), role: .cancel) {}
        } message: {
            Text("\(loc.localized("marketplace_total")): \(String(format: "%.2f", product.price)) \(product.currency)")
        }
    }

    // MARK: - Helpers

    private func productIcon(_ type: String) -> String {
        switch type {
        case "workout_plan": return "figure.strengthtraining.traditional"
        case "meal_plan": return "fork.knife"
        case "ebook": return "book.closed"
        case "training_program": return "figure.run"
        case "video_course": return "play.rectangle"
        default: return "bag"
        }
    }
}

// MARK: - Review Row

struct ReviewRow: View {
    let review: ProductReview

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Reviewer Name
                if let reviewer = review.reviewer {
                    Text(reviewer.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                } else {
                    Text("Anonymous")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Rating Stars
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }

            // Comment
            if let comment = review.comment {
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Date
            Text(review.createdAt.timeAgo())
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// #Preview { // iOS 17+ only
//     NavigationStack {
//         ProductDetailView(productId: "123")
//     }
// }
