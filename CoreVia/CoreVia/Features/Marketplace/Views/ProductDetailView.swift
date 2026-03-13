import SwiftUI
import SafariServices

/// Product Detail View with Purchase Flow
struct ProductDetailView: View {
    let productId: String
    @StateObject private var viewModel: ProductDetailViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss

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

                        // Buy Button
                        Button {
                            Task {
                                await viewModel.purchaseProduct()
                            }
                        } label: {
                            Text(viewModel.hasPurchased ? loc.localized("marketplace_purchased") : loc.localized("marketplace_buy_now"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(viewModel.hasPurchased ? Color.gray : Color.red)
                                .cornerRadius(14)
                        }
                        .disabled(viewModel.hasPurchased || viewModel.isPurchasing)
                        .padding(.top, 8)
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
        .sheet(isPresented: $viewModel.showPaymentWeb) {
            if let url = viewModel.paymentURL {
                PaymentWebView(url: url) {
                    viewModel.showPaymentWeb = false
                    Task {
                        await viewModel.checkPaymentAfterReturn()
                    }
                }
            }
        }
    }

    // MARK: - Cover Image

    private func coverImageSection(product: MarketplaceProduct) -> some View {
        Group {
            if let url = product.fullCoverImageUrl {
                AuthenticatedImage(url: url) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                .cornerRadius(16)
                .padding(.horizontal)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.1))
                    Image(systemName: productIcon(product.productType))
                        .font(.system(size: 60))
                        .foregroundColor(Color.red)
                }
                .frame(height: 220)
                .padding(.horizontal)
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
                .foregroundColor(Color.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)

            // Title
            Text(product.title)
                .font(.title2)
                .fontWeight(.bold)

            // Price
            Text("\(String(format: "%.2f", product.price)) \(product.currency)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.red)
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
                        AuthenticatedImage(url: url) {
                            Circle()
                                .fill(Color(.systemGray5))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Text(seller.name.prefix(1).uppercased())
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.red)
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

// #Preview { // iOS 17+ only
//     NavigationStack {
//         ProductDetailView(productId: "123")
//     }
// }
