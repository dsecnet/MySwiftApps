import SwiftUI
import Combine

// MARK: - Subscription Plan
enum SubscriptionPlan: String, CaseIterable {
    case monthly
    case yearly

    var displayKey: String {
        switch self {
        case .monthly: return "monthly"
        case .yearly: return "yearly"
        }
    }

    var price: String {
        switch self {
        case .monthly: return "$4.99"
        case .yearly: return "$39.99"
        }
    }

    var pricePerMonth: String {
        switch self {
        case .monthly: return "$4.99/ay"
        case .yearly: return "$3.33/ay"
        }
    }

    var features: [String] {
        switch self {
        case .monthly:
            return [
                "unlimited_listings",
                "basic_analytics",
                "email_support"
            ]
        case .yearly:
            return [
                "unlimited_listings",
                "advanced_analytics",
                "priority_support",
                "verified_badge",
                "boost_listing"
            ]
        }
    }
}

// MARK: - Boost Product
struct BoostProduct: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: String
    let duration: String
    let listingPreview: Listing?
}

// MARK: - Premium ViewModel
@MainActor
class PremiumViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var selectedPlan: SubscriptionPlan = .monthly
    @Published var isPurchasing: Bool = false
    @Published var isRestoring: Bool = false
    @Published var isPremiumUser: Bool = false
    @Published var showPurchaseSuccess: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Boost Products
    @Published var boostProducts: [BoostProduct] = []

    // MARK: - Init
    init() {
        loadBoostProducts()
    }

    // MARK: - Purchase Subscription
    func purchasePlan(_ plan: SubscriptionPlan) {
        isPurchasing = true
        selectedPlan = plan

        // Simulate purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isPurchasing = false
            self?.isPremiumUser = true
            self?.showPurchaseSuccess = true
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() {
        isRestoring = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isRestoring = false
        }
    }

    // MARK: - Purchase Boost
    func purchaseBoost(_ product: BoostProduct) {
        isPurchasing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isPurchasing = false
            self?.showPurchaseSuccess = true
        }
    }

    // MARK: - Load Boost Products
    private func loadBoostProducts() {
        boostProducts = [
            BoostProduct(
                name: "boost_listing".localized,
                description: "boost_subtitle".localized,
                price: "9.99 ₼",
                duration: "7 gun",
                listingPreview: Listing(
                    id: "boost_preview",
                    userId: "user_001",
                    agentId: "agent_001",
                    title: "3 otaqli menzil Nesimi",
                    description: "Premium boost preview",
                    listingType: .sale,
                    propertyType: .newBuilding,
                    price: 185000,
                    currency: .AZN,
                    city: "Baki",
                    district: "Nesimi",
                    address: "28 May",
                    rooms: 3,
                    areaSqm: 120,
                    floor: 8,
                    totalFloors: 16,
                    renovation: .good,
                    images: ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400"],
                    videoUrl: nil,
                    status: .active,
                    viewsCount: 456,
                    isBoosted: false
                )
            )
        ]
    }
}
