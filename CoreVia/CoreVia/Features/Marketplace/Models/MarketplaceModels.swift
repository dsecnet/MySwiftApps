import Foundation

// MARK: - Marketplace Product

struct MarketplaceProduct: Identifiable, Codable {
    let id: String
    let sellerId: String
    let productType: String  // workout_plan, meal_plan, ebook, consultation
    let title: String
    let description: String
    let price: Double
    let currency: String
    let coverImageUrl: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    // Extra
    var seller: ProductSeller?
    var averageRating: Double?
    var reviewCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, currency
        case sellerId = "seller_id"
        case productType = "product_type"
        case coverImageUrl = "cover_image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case seller
        case averageRating = "average_rating"
        case reviewCount = "review_count"
    }
}

struct ProductSeller: Codable {
    let id: String
    let name: String
    let profileImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImageUrl = "profile_image_url"
    }
}

// MARK: - Products Response

struct ProductsResponse: Codable {
    let products: [MarketplaceProduct]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case products, total, page
        case pageSize = "page_size"
        case hasMore = "has_more"
    }
}

// MARK: - Product Create/Update

struct CreateProductRequest: Codable {
    let productType: String
    let title: String
    let description: String
    let price: Double
    let currency: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case title, description, price, currency
        case productType = "product_type"
        case isActive = "is_active"
    }
}

// MARK: - Purchase

struct PurchaseRequest: Codable {
    let productId: String
    let receiptData: String

    enum CodingKeys: String, CodingKey {
        case receiptData = "receipt_data"
        case productId = "product_id"
    }
}

struct ProductPurchase: Identifiable, Codable {
    let id: String
    let userId: String
    let productId: String
    let price: Double
    let currency: String
    let purchasedAt: Date

    // Extra
    var product: MarketplaceProduct?

    enum CodingKeys: String, CodingKey {
        case id, price, currency, product
        case userId = "user_id"
        case productId = "product_id"
        case purchasedAt = "purchased_at"
    }
}

// MARK: - Review

struct ProductReview: Identifiable, Codable {
    let id: String
    let productId: String
    let userId: String
    let rating: Int
    let comment: String?
    let createdAt: Date

    // Extra
    var reviewer: ReviewAuthor?

    enum CodingKeys: String, CodingKey {
        case id, rating, comment, reviewer
        case productId = "product_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct ReviewAuthor: Codable {
    let id: String
    let name: String
    let profileImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImageUrl = "profile_image_url"
    }
}

struct CreateReviewRequest: Codable {
    let productId: String
    let rating: Int
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case rating, comment
        case productId = "product_id"
    }
}
