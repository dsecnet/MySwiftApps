//
//  TrainerMarketplaceViewModel.swift
//  CoreVia
//
//  Trainer mehsul CRUD - movcut APIService pattern-i ile
//

import Foundation
import os.log

@MainActor
class TrainerMarketplaceViewModel: ObservableObject {
    @Published var products: [MarketplaceProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMore = true

    private var currentPage = 1
    private let pageSize = 20
    private var currentProductType: String?

    // MARK: - Load My Products

    func loadMyProducts(productType: String? = nil, refresh: Bool = false) async {
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
                URLQueryItem(name: "page_size", value: "\(pageSize)"),
                URLQueryItem(name: "seller_id", value: "me")
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
            AppLogger.network.error("Load trainer marketplace products xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Load More

    func loadMore() async {
        guard hasMore, !isLoading else { return }
        await loadMyProducts(productType: currentProductType)
    }

    // MARK: - Delete Product

    func deleteProduct(_ productId: String) async {
        do {
            try await APIService.shared.requestVoid(
                endpoint: "/api/v1/marketplace/products/\(productId)",
                method: "DELETE"
            )
            products.removeAll { $0.id == productId }
        } catch {
            AppLogger.network.error("Delete trainer product xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}
