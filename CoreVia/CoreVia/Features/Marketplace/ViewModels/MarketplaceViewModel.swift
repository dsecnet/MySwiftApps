import Foundation
import SwiftUI

@MainActor
class MarketplaceViewModel: ObservableObject {
    @Published var products: [MarketplaceProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMore = true

    private var currentPage = 1
    private let pageSize = 20
    private var currentProductType: String?

    // MARK: - Load Products

    func loadProducts(productType: String? = nil, refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            hasMore = true
            currentProductType = productType
        }

        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            var queryItems = [
                URLQueryItem(name: "page", value: "\(currentPage)"),
                URLQueryItem(name: "page_size", value: "\(pageSize)")
            ]

            if let type = productType {
                queryItems.append(URLQueryItem(name: "product_type", value: type))
            }

            let response: ProductsResponse = try await APIService.shared.request(
                endpoint: "/api/v1/marketplace/products",
                method: "GET",
                queryItems: queryItems
            )

            if refresh || currentPage == 1 {
                products = response.products
            } else {
                products.append(contentsOf: response.products)
            }

            hasMore = response.hasMore
            currentPage += 1

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Load More

    func loadMore() async {
        guard hasMore, !isLoading else { return }
        await loadProducts(productType: currentProductType)
    }
}
