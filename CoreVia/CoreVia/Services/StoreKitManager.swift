import Foundation
import StoreKit
import os.log

/// StoreKit 2 Manager - Premium subscription idarəetməsi
/// TODO: Apple Pay implementasiyası üçün bu faylı tamamla
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    // MARK: - Product IDs
    enum ProductID: String, CaseIterable {
        case monthlyPremium = "life.corevia.premium.monthly"
        case yearlyPremium = "life.corevia.premium.yearly"
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
        Task { await loadProducts() }
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
            errorMessage = "Məhsullar yüklənə bilmədi: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // TODO: Backend-ə receipt göndər - /api/v1/premium/verify-apple
            // await sendReceiptToBackend(transaction)

            await transaction.finish()
            await updatePurchasedProducts()
            return transaction

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
            errorMessage = "Alışlar bərpa edilə bilmədi"
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

    // MARK: - Update Purchased Products
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased

        // Sync premium status with SettingsManager
        SettingsManager.shared.isPremium = isPremium
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                }
            }
        }
    }

    // MARK: - TODO: Backend Receipt Verification
    /// Apple receipt-i backend-ə göndər və premium statusu yenilə
    /// Endpoint: POST /api/v1/premium/verify-apple
    /// Body: { "transaction_id": "...", "original_transaction_id": "...", "product_id": "..." }
    /*
    private func sendReceiptToBackend(_ transaction: Transaction) async {
        let body: [String: Any] = [
            "transaction_id": String(transaction.id),
            "original_transaction_id": String(transaction.originalID),
            "product_id": transaction.productID
        ]
        // Call APIService to verify
        // let result: PremiumResponse = try await APIService.shared.request(...)
        // Update premium status based on backend response
    }
    */
}

// MARK: - Store Errors
enum StoreError: LocalizedError {
    case failedVerification
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .failedVerification: return "Alış doğrulama uğursuz oldu"
        case .purchaseFailed: return "Alış uğursuz oldu"
        }
    }
}
