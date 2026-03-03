import Foundation
import StoreKit

// MARK: - Product Identifiers
enum MenzilimProduct: String, CaseIterable {
    case premiumMonthly = "menzilim_premium_monthly"
    case premiumYearly = "menzilim_premium_yearly"
    case boostVIP = "menzilim_boost_vip"
    case boostPremium = "menzilim_boost_premium"
    case boostStandard = "menzilim_boost_standard"

    var displayName: String {
        switch self {
        case .premiumMonthly: return "Premium Aylıq"
        case .premiumYearly: return "Premium İllik"
        case .boostVIP: return "VIP Boost"
        case .boostPremium: return "Premium Boost"
        case .boostStandard: return "Standard Boost"
        }
    }

    var localPrice: String {
        switch self {
        case .premiumMonthly: return "4.99 ₼"
        case .premiumYearly: return "39.99 ₼"
        case .boostVIP: return "4.99 ₼"
        case .boostPremium: return "2.99 ₼"
        case .boostStandard: return "0.99 ₼"
        }
    }

    var isSubscription: Bool {
        switch self {
        case .premiumMonthly, .premiumYearly: return true
        case .boostVIP, .boostPremium, .boostStandard: return false
        }
    }

    static var subscriptionProducts: [MenzilimProduct] {
        [.premiumMonthly, .premiumYearly]
    }

    static var boostProducts: [MenzilimProduct] {
        [.boostVIP, .boostPremium, .boostStandard]
    }
}

// MARK: - Purchase Result
enum PurchaseResult {
    case success(productId: String)
    case pending
    case cancelled
    case failed(Error)
}

// MARK: - StoreKit Manager
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedSubscriptions: Set<String> = []
    @Published private(set) var isPremiumUser: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var purchaseSuccessProduct: String?
    @Published var showPurchaseSuccess: Bool = false

    // MARK: - Private Properties
    private var transactionListener: Task<Void, Error>?
    private let api = APIService.shared

    // MARK: - Init
    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products from App Store
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let productIds = MenzilimProduct.allCases.map { $0.rawValue }
            let storeProducts = try await Product.products(for: Set(productIds))
            products = storeProducts.sorted { $0.price < $1.price }
            AppLogger.log("Loaded \(products.count) products from App Store", category: AppLogger.payment)
        } catch {
            AppLogger.error("Failed to load products: \(error.localizedDescription)", category: AppLogger.payment)
            errorMessage = "Məhsullar yüklənə bilmədi. Yenidən cəhd edin."
            showError = true
        }
    }

    // MARK: - Get Product by ID
    func product(for identifier: MenzilimProduct) -> Product? {
        products.first { $0.id == identifier.rawValue }
    }

    // MARK: - Purchase Product
    func purchase(_ productId: MenzilimProduct) async -> PurchaseResult {
        guard let product = product(for: productId) else {
            let error = NSError(domain: "StoreKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Məhsul tapılmadı"])
            errorMessage = "Məhsul tapılmadı. Yenidən cəhd edin."
            showError = true
            return .failed(error)
        }

        return await purchase(product)
    }

    func purchase(_ product: Product) async -> PurchaseResult {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerification(verification)

                // Verify receipt with backend
                await verifyReceiptWithBackend(transaction: transaction)

                // Update local state
                await updatePurchasedProducts()

                // Finish the transaction
                await transaction.finish()

                purchaseSuccessProduct = product.displayName
                showPurchaseSuccess = true

                AppLogger.log("Purchase successful: \(product.id)", category: AppLogger.payment)
                return .success(productId: product.id)

            case .userCancelled:
                AppLogger.log("Purchase cancelled by user: \(product.id)", category: AppLogger.payment)
                return .cancelled

            case .pending:
                AppLogger.log("Purchase pending: \(product.id)", category: AppLogger.payment)
                return .pending

            @unknown default:
                let error = NSError(domain: "StoreKitManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Naməlum nəticə"])
                return .failed(error)
            }
        } catch {
            AppLogger.error("Purchase failed: \(error.localizedDescription)", category: AppLogger.payment)
            errorMessage = "Satınalma uğursuz oldu: \(error.localizedDescription)"
            showError = true
            return .failed(error)
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            AppLogger.log("Purchases restored successfully", category: AppLogger.payment)
        } catch {
            AppLogger.error("Restore failed: \(error.localizedDescription)", category: AppLogger.payment)
            errorMessage = "Satınalmaları bərpa etmək mümkün olmadı."
            showError = true
        }
    }

    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchased = Set<String>()

        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                purchased.insert(transaction.productID)
            }
        }

        purchasedSubscriptions = purchased

        // Update premium status
        isPremiumUser = purchased.contains(MenzilimProduct.premiumMonthly.rawValue) ||
                        purchased.contains(MenzilimProduct.premiumYearly.rawValue)

        AppLogger.log("Updated purchases. Premium: \(isPremiumUser), Active: \(purchased)", category: AppLogger.payment)
    }

    // MARK: - Check if Product is Purchased
    func isPurchased(_ productId: MenzilimProduct) -> Bool {
        purchasedSubscriptions.contains(productId.rawValue)
    }

    // MARK: - Get Subscription Status
    func subscriptionStatus() async -> Product.SubscriptionInfo.Status? {
        guard let subscriptionProduct = products.first(where: {
            $0.id == MenzilimProduct.premiumMonthly.rawValue ||
            $0.id == MenzilimProduct.premiumYearly.rawValue
        }) else {
            return nil
        }

        guard let subscription = subscriptionProduct.subscription else { return nil }

        do {
            let statuses = try await subscription.status
            return statuses.first { $0.state == .subscribed || $0.state == .inGracePeriod }
        } catch {
            AppLogger.error("Failed to get subscription status: \(error.localizedDescription)", category: AppLogger.payment)
            return nil
        }
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerification(result)
                    await self.verifyReceiptWithBackend(transaction: transaction)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                    AppLogger.log("Transaction update processed: \(transaction.productID)", category: AppLogger.payment)
                } catch {
                    AppLogger.error("Transaction update verification failed: \(error.localizedDescription)", category: AppLogger.payment)
                }
            }
        }
    }

    // MARK: - Verify Transaction
    private nonisolated func checkVerification<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            AppLogger.error("Transaction verification failed: \(error.localizedDescription)", category: AppLogger.payment)
            throw error
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Verify Receipt with Backend
    private func verifyReceiptWithBackend(transaction: Transaction) async {
        do {
            struct ReceiptVerification: Codable {
                let productId: String
                let transactionId: String
                let originalTransactionId: String
                let purchaseDate: String
                let environment: String

                enum CodingKeys: String, CodingKey {
                    case productId = "product_id"
                    case transactionId = "transaction_id"
                    case originalTransactionId = "original_transaction_id"
                    case purchaseDate = "purchase_date"
                    case environment
                }
            }

            let verification = ReceiptVerification(
                productId: transaction.productID,
                transactionId: String(transaction.id),
                originalTransactionId: String(transaction.originalID),
                purchaseDate: transaction.purchaseDate.iso8601String,
                environment: transaction.environment.rawValue
            )

            struct VerifyResponse: Codable {
                let verified: Bool
            }

            let _: VerifyResponse = try await api.request(
                endpoint: "/payments/verify-receipt",
                method: .POST,
                body: verification
            )

            AppLogger.log("Receipt verified with backend for: \(transaction.productID)", category: AppLogger.payment)
        } catch {
            // Non-fatal: purchase still valid locally even if backend verification fails
            AppLogger.error("Backend receipt verification failed: \(error.localizedDescription)", category: AppLogger.payment)
        }
    }

    // MARK: - Formatted Price
    func formattedPrice(for productId: MenzilimProduct) -> String {
        if let product = product(for: productId) {
            return product.displayPrice
        }
        return productId.localPrice
    }

    // MARK: - Monthly Price Equivalent
    func monthlyPriceEquivalent(for productId: MenzilimProduct) -> String? {
        guard productId == .premiumYearly,
              let product = product(for: productId) else { return nil }

        let monthlyPrice = product.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = product.priceFormatStyle.currencyCode

        return formatter.string(from: monthlyPrice as NSDecimalNumber)
    }
}
