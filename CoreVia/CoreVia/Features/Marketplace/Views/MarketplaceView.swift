import SwiftUI

/// Marketplace View - Browse and purchase products
struct MarketplaceView: View {
    @StateObject private var viewModel = MarketplaceViewModel()
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var selectedProductType: String = "all"

    let productTypes = ["all", "workout_plan", "meal_plan", "training_program", "ebook", "video_course"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Tabs
                filterSection

                // Products List
                if viewModel.isLoading && viewModel.products.isEmpty {
                    loadingView
                } else if viewModel.products.isEmpty {
                    emptyStateView
                } else {
                    productsListView
                }
            }
            .navigationTitle(loc.localized("marketplace_title"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadProducts(productType: selectedProductType == "all" ? nil : selectedProductType)
            }
            .task {
                await viewModel.loadProducts(productType: nil)
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
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(productTypes, id: \.self) { type in
                    FilterChip(
                        title: loc.localized("marketplace_\(type)"),
                        isSelected: selectedProductType == type
                    ) {
                        selectedProductType = type
                        Task {
                            await viewModel.loadProducts(productType: type == "all" ? nil : type, refresh: true)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Products List

    private var productsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.products) { product in
                    NavigationLink {
                        ProductDetailView(productId: product.id)
                    } label: {
                        ProductCard(product: product)
                    }
                    .buttonStyle(.plain)
                }

                // Load More
                if viewModel.hasMore {
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 70))
                .foregroundColor(.gray)

            Text(loc.localized("marketplace_no_products"))
                .font(.title3)
                .fontWeight(.semibold)

            Text(loc.localized("marketplace_no_products_desc"))
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: MarketplaceProduct
    let loc = LocalizationManager.shared

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Cover Image
            if let imageUrl = product.coverImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 100, height: 100)
                .cornerRadius(12)
            } else {
                ZStack {
                    Color("PrimaryColor").opacity(0.1)
                    Image(systemName: productIcon)
                        .font(.title)
                        .foregroundColor(Color("PrimaryColor"))
                }
                .frame(width: 100, height: 100)
                .cornerRadius(12)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Product Type Badge
                Text(loc.localized("marketplace_\(product.productType)"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryColor"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("PrimaryColor").opacity(0.1))
                    .cornerRadius(6)

                // Title
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                // Seller
                if let seller = product.seller {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle")
                            .font(.caption)
                        Text(seller.name)
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }

                Spacer()

                // Price & Rating
                HStack {
                    Text("\(String(format: "%.2f", product.price)) \(product.currency)")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryColor"))

                    Spacer()

                    if let rating = product.averageRating, let count = product.reviewCount {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("(\(count))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    private var productIcon: String {
        switch product.productType {
        case "workout_plan":
            return "figure.strengthtraining.traditional"
        case "meal_plan":
            return "fork.knife"
        case "ebook":
            return "book.closed"
        case "training_program":
            return "figure.run"
        case "video_course":
            return "play.rectangle"
        default:
            return "bag"
        }
    }
}

// #Preview { // iOS 17+ only
//     MarketplaceView()
// }
