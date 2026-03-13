import Foundation
import StoreKit
import os.log

@MainActor
class ProductDetailViewModel: ObservableObject {
    let productId: String

    @Published var product: MarketplaceProduct?
    @Published var reviews: [ProductReview] = []
    @Published var hasPurchased = false
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    // Kapital Bank payment
    @Published var showPaymentWeb = false
    @Published var paymentURL: URL?

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
            AppLogger.network.error("Load product detail xetasi: \(error.localizedDescription)")
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
            AppLogger.network.error("Failed to load reviews: \(error.localizedDescription)")
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
            AppLogger.network.error("Failed to check purchase status: \(error.localizedDescription)")
        }
    }

    // MARK: - Kapital Bank Purchase

    func purchaseProduct() async {
        guard let product = product else { return }

        isPurchasing = true
        errorMessage = nil

        do {
            let kapitalManager = KapitalPaymentManager.shared
            kapitalManager.reset()

            let response = try await kapitalManager.createOrder(productId: "marketplace_\(product.id)")

            if let url = URL(string: response.redirectUrl) {
                paymentURL = url
                showPaymentWeb = true
            } else {
                errorMessage = "Ödəniş linki yaradıla bilmədi"
            }
        } catch {
            AppLogger.network.error("Purchase product xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }

    /// Safari bağlandıqdan sonra ödəniş statusunu yoxla
    func checkPaymentAfterReturn() async {
        guard let paymentId = KapitalPaymentManager.shared.currentPaymentId else { return }

        isPurchasing = true
        let success = await KapitalPaymentManager.shared.waitForPaymentCompletion(paymentId: paymentId)

        if success {
            hasPurchased = true
        } else if let error = KapitalPaymentManager.shared.paymentError {
            errorMessage = error
        }
        isPurchasing = false
    }

    // MARK: - Apple IAP (StoreKit 2 — saxlanılıb, Apple tələb etsə)

    func purchaseProductWithApple() async {
        guard let product = product else { return }

        isPurchasing = true
        errorMessage = nil

        do {
            let receiptData = try await initiateApplePurchase(productIdentifier: "corevia_\(product.id)")

            let request = PurchaseRequest(
                productId: product.id,
                receiptData: receiptData
            )

            let _: ProductPurchase = try await APIService.shared.request(
                endpoint: "/api/v1/marketplace/purchase",
                method: "POST",
                body: request
            )

            hasPurchased = true

        } catch {
            AppLogger.network.error("Purchase product xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }

    private func initiateApplePurchase(productIdentifier: String) async throws -> String {
        let products = try await Product.products(for: [productIdentifier])

        guard let storeProduct = products.first else {
            throw NSError(
                domain: "Purchase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mehsul App Store-da tapilmadi."]
            )
        }

        let result = try await storeProduct.purchase()

        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                let transactionId = String(transaction.id)
                return transactionId

            case .unverified(_, let error):
                throw NSError(
                    domain: "Purchase",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Odenis dogrulama ugursuz: \(error.localizedDescription)"]
                )
            }

        case .userCancelled:
            throw NSError(
                domain: "Purchase",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Odenis legv edildi."]
            )

        case .pending:
            throw NSError(
                domain: "Purchase",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Odenis gozleyir (valideyn icazesi ve s.)."]
            )

        @unknown default:
            throw NSError(
                domain: "Purchase",
                code: -5,
                userInfo: [NSLocalizedDescriptionKey: "Bilinmeyen odenis netices."]
            )
        }
    }
}
