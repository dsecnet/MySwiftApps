import Foundation
import StoreKit
import os.log

/// StoreKit 2 Manager - Premium subscription idareetmesi
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    // MARK: - Product IDs
    enum ProductID: String, CaseIterable {
        case monthlyPremium = "life.corevia.premium.monthly"
        case yearlyPremium  = "life.corevia.premium.yearly"
    }

    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products from App Store
    func loadProducts() async {
        isLoading = true
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            isLoading = false
        } catch {
            AppLogger.network.error("StoreKit products yukleme xetasi: \(error.localizedDescription)")
            errorMessage = "Mehsullar yuklene bilmedi"
            isLoading = false
        }
    }

    // MARK: - Purchase (iOS-02 fix: backend receipt verify edilir)
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Backend-e receipt gonder ve verify et
            let verified = await sendReceiptToBackend(transaction)
            if verified {
                await transaction.finish()
                await updatePurchasedProducts()
                // Token claims-i yenile (isPremium JWT-de guncellenir)
                await AuthManager.shared.refreshTokenClaims()
                return transaction
            } else {
                // Backend verify etmedi - alisi tamamlama
                AppLogger.network.error("Backend receipt verification failed for transaction \(transaction.id)")
                throw StoreError.backendVerificationFailed
            }

        case .userCancelled:
            return nil

        case .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            AppLogger.network.error("Restore purchases xetasi: \(error.localizedDescription)")
            errorMessage = "Alislar bərpa edilə bilmedi"
        }
    }

    // MARK: - Check Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Update Purchased Products (iOS-side entitlement check)
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
        SettingsManager.shared.isPremium = isPremium
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    // Backend-e gonder, sonra finish et
                    let verified = await self.sendReceiptToBackend(transaction)
                    if verified {
                        await transaction.finish()
                        await self.updatePurchasedProducts()
                        await AuthManager.shared.refreshTokenClaims()
                    } else {
                        AppLogger.network.error("Background transaction backend verify failed: \(transaction.id)")
                    }
                }
            }
        }
    }

    // MARK: - Backend Receipt Verification (iOS-02 fix)
    // Apple StoreKit 2 transaction melumatlarini backend-e gonderib verify edirik.
    // Backend /api/v1/premium/verify-apple endpoint-i bu melumatlarla Apple-a
    // sorgu edir ve premium statusu DB-de yenileyir.
    @discardableResult
    private func sendReceiptToBackend(_ transaction: Transaction) async -> Bool {
        struct ReceiptBody: Encodable {
            let transaction_id: String
            let original_transaction_id: String
            let product_id: String
            let purchase_date: String
        }

        struct VerifyResponse: Decodable {
            let success: Bool
            let is_premium: Bool
            let message: String?
        }

        let formatter = ISO8601DateFormatter()
        let body = ReceiptBody(
            transaction_id: String(transaction.id),
            original_transaction_id: String(transaction.originalID),
            product_id: transaction.productID,
            purchase_date: formatter.string(from: transaction.purchaseDate)
        )

        do {
            let response: VerifyResponse = try await APIService.shared.request(
                endpoint: "/api/v1/premium/verify-apple",
                method: "POST",
                body: body,
                requiresAuth: true
            )
            return response.success && response.is_premium
        } catch {
            AppLogger.network.error("sendReceiptToBackend failed: \(error.localizedDescription)")
            return false
        }
    }
}

// MARK: - Store Errors
enum StoreError: LocalizedError {
    case failedVerification
    case purchaseFailed
    case backendVerificationFailed

    var errorDescription: String? {
        switch self {
        case .failedVerification:         return "Alis dogulama ugursuz oldu"
        case .purchaseFailed:             return "Alis ugursuz oldu"
        case .backendVerificationFailed:  return "Server terefdinden alis tesdiqlenilmedi"
        }
    }
}
