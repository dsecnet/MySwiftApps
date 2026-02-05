import Foundation
import StoreKit

@MainActor
class ProductDetailViewModel: ObservableObject {
    let productId: String

    @Published var product: MarketplaceProduct?
    @Published var reviews: [ProductReview] = []
    @Published var hasPurchased = false
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    init(productId: String) {
        self.productId = productId
    }

    // MARK: - Load Product

    func loadProduct() async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedProduct: MarketplaceProduct = try await APIService.shared.request(
                endpoint: "/api/v1/marketplace/products/\(productId)",
                method: "GET"
            )

            product = loadedProduct

            // Load reviews
            await loadReviews()

            // Check if already purchased
            await checkPurchaseStatus()

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Load Reviews

    func loadReviews() async {
        do {
            let loadedReviews: [ProductReview] = try await APIService.shared.request(
                endpoint: "/api/v1/marketplace/products/\(productId)/reviews",
                method: "GET"
            )

            reviews = loadedReviews

        } catch {
            print("Failed to load reviews: \(error)")
        }
    }

    // MARK: - Check Purchase Status

    private func checkPurchaseStatus() async {
        do {
            struct PurchasesResponse: Codable {
                let purchases: [ProductPurchase]
            }

            let response: PurchasesResponse = try await APIService.shared.request(
                endpoint: "/api/v1/marketplace/my-purchases",
                method: "GET"
            )

            hasPurchased = response.purchases.contains { $0.productId == productId }

        } catch {
            print("Failed to check purchase status: \(error)")
        }
    }

    // MARK: - Purchase Product

    func purchaseProduct() async {
        guard let product = product else { return }

        isPurchasing = true
        errorMessage = nil

        do {
            // 1. Initiate Apple IAP
            let receiptData = try await initiateApplePurchase(productIdentifier: "corevia_\(product.id)")

            // 2. Validate with backend
            let request = PurchaseRequest(
                productId: product.id,
                receiptData: receiptData
            )

            let purchase: ProductPurchase = try await APIService.shared.request(
                endpoint: "/api/v1/marketplace/purchase",
                method: "POST",
                body: request
            )

            // Success
            hasPurchased = true

        } catch {
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }

    // MARK: - Apple IAP

    private func initiateApplePurchase(productIdentifier: String) async throws -> String {
        // For demonstration - in production, use StoreKit 2
        // This is a simplified version

        // 1. Fetch product
        let request = SKProductsRequest(productIdentifiers: [productIdentifier])
        // ... StoreKit flow ...

        // 2. Purchase product
        // ... Purchase flow ...

        // 3. Get receipt
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            throw NSError(domain: "Purchase", code: -1, userInfo: [NSLocalizedDescriptionKey: "No receipt found"])
        }

        return receiptData.base64EncodedString()
    }
}
