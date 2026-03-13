import Foundation


struct MarketplaceProduct: Identifiable, Codable {
    let id: String
    let sellerId: String
    let productType: String
    let title: String
    let description: String
    let price: Double
    let currency: String
    var coverImageUrl: String?
    var previewVideoUrl: String?
    var isPublished: Bool
    var createdAt: Date
    var updatedAt: Date

    // Extra
    var seller: ProductSeller?
    var averageRating: Double?
    var reviewCount: Int?
    var salesCount: Int?
    var isPurchased: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, currency, seller
        case sellerId = "seller_id"
        case productType = "product_type"
        case coverImageUrl = "cover_image_url"
        case previewVideoUrl = "preview_video_url"
        case isPublished = "is_published"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case averageRating = "rating"
        case reviewCount = "reviews_count"
        case salesCount = "sales_count"
        case isPurchased = "is_purchased"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        sellerId = try c.decode(String.self, forKey: .sellerId)
        productType = try c.decode(String.self, forKey: .productType)
        title = try c.decode(String.self, forKey: .title)
        description = try c.decode(String.self, forKey: .description)
        price = try c.decode(Double.self, forKey: .price)
        currency = try c.decode(String.self, forKey: .currency)
        coverImageUrl = try c.decodeIfPresent(String.self, forKey: .coverImageUrl)
        previewVideoUrl = try c.decodeIfPresent(String.self, forKey: .previewVideoUrl)
        isPublished = (try? c.decode(Bool.self, forKey: .isPublished)) ?? false
        createdAt = (try? c.decode(Date.self, forKey: .createdAt)) ?? Date()
        updatedAt = (try? c.decode(Date.self, forKey: .updatedAt)) ?? Date()
        seller = try? c.decodeIfPresent(ProductSeller.self, forKey: .seller)
        averageRating = try? c.decodeIfPresent(Double.self, forKey: .averageRating)
        reviewCount = try? c.decodeIfPresent(Int.self, forKey: .reviewCount)
        salesCount = try? c.decodeIfPresent(Int.self, forKey: .salesCount)
        isPurchased = try? c.decodeIfPresent(Bool.self, forKey: .isPurchased)
    }

    /// Şəkil URL-i relative ola bilər ("/uploads/...") — full URL qaytarır
    var fullCoverImageUrl: URL? {
        guard let path = coverImageUrl, !path.isEmpty else { return nil }
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        return URL(string: "\(APIService.shared.baseURL)\(path)")
    }
}

struct ProductSeller: Codable {
    let id: String
    let name: String
    var profileImageUrl: String?
    var rating: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, rating
        case profileImageUrl = "profile_image_url"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        profileImageUrl = try? c.decodeIfPresent(String.self, forKey: .profileImageUrl)
        rating = try? c.decodeIfPresent(Double.self, forKey: .rating)
    }
}

// MARK: - Products Response

struct ProductsResponse: Codable {
    let products: [MarketplaceProduct]
    var total: Int
    var page: Int
    var pageSize: Int
    var hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case products, total, page
        case pageSize = "page_size"
        case hasMore = "has_more"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        products = (try? c.decode([MarketplaceProduct].self, forKey: .products)) ?? []
        total = (try? c.decode(Int.self, forKey: .total)) ?? 0
        page = (try? c.decode(Int.self, forKey: .page)) ?? 1
        pageSize = (try? c.decode(Int.self, forKey: .pageSize)) ?? 20
        hasMore = (try? c.decode(Bool.self, forKey: .hasMore)) ?? false
    }
}

// MARK: - Product Create/Update

struct CreateProductRequest: Codable {
    let productType: String
    let title: String
    let description: String
    let price: Double
    let currency: String
    let isPublished: Bool

    enum CodingKeys: String, CodingKey {
        case title, description, price, currency
        case productType = "product_type"
        case isPublished = "is_published"
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
    var buyerId: String
    var productId: String
    var amountPaid: Double
    var currency: String
    var purchasedAt: Date

    // Extra
    var product: MarketplaceProduct?
    var productTitle: String?

    enum CodingKeys: String, CodingKey {
        case id, currency, product
        case buyerId = "buyer_id"
        case productId = "product_id"
        case amountPaid = "amount_paid"
        case purchasedAt = "purchased_at"
        case productTitle = "product_title"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        buyerId = (try? c.decode(String.self, forKey: .buyerId)) ?? ""
        productId = (try? c.decode(String.self, forKey: .productId)) ?? ""
        amountPaid = (try? c.decode(Double.self, forKey: .amountPaid)) ?? 0
        currency = (try? c.decode(String.self, forKey: .currency)) ?? "AZN"
        purchasedAt = (try? c.decode(Date.self, forKey: .purchasedAt)) ?? Date()
        product = try? c.decodeIfPresent(MarketplaceProduct.self, forKey: .product)
        productTitle = try? c.decodeIfPresent(String.self, forKey: .productTitle)
    }
}

// MARK: - Review

struct ProductReview: Identifiable, Codable {
    let id: String
    var productId: String
    var buyerId: String
    let rating: Int
    var comment: String?
    var createdAt: Date

    // Extra — backend "author" qaytarır
    var reviewer: ReviewAuthor?

    enum CodingKeys: String, CodingKey {
        case id, rating, comment
        case reviewer = "author"
        case productId = "product_id"
        case buyerId = "buyer_id"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        productId = (try? c.decode(String.self, forKey: .productId)) ?? ""
        buyerId = (try? c.decode(String.self, forKey: .buyerId)) ?? ""
        rating = (try? c.decode(Int.self, forKey: .rating)) ?? 0
        comment = try? c.decodeIfPresent(String.self, forKey: .comment)
        createdAt = (try? c.decode(Date.self, forKey: .createdAt)) ?? Date()
        reviewer = try? c.decodeIfPresent(ReviewAuthor.self, forKey: .reviewer)
    }
}

struct ReviewAuthor: Codable {
    let id: String
    let name: String
    var profileImageUrl: String?

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
