import Foundation

// MARK: - Social Post

struct SocialPost: Identifiable, Codable {
    let id: String
    let userId: String
    let postType: String  // workout, meal, progress, achievement, general
    let content: String?
    let imageUrl: String?
    let workoutId: String?
    let foodEntryId: String?
    var likesCount: Int
    var commentsCount: Int
    let isPublic: Bool
    let createdAt: Date
    let updatedAt: Date

    // Extra
    var author: PostAuthor?
    var isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id, content
        case userId = "user_id"
        case postType = "post_type"
        case imageUrl = "image_url"
        case workoutId = "workout_id"
        case foodEntryId = "food_entry_id"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case isPublic = "is_public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case author
        case isLiked = "is_liked"
    }
}

struct PostAuthor: Codable {
    let id: String
    let name: String
    let profileImageUrl: String?
    let userType: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImageUrl = "profile_image_url"
        case userType = "user_type"
    }
}

// MARK: - Feed Response

struct FeedResponse: Codable {
    let posts: [SocialPost]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case posts, total, page
        case pageSize = "page_size"
        case hasMore = "has_more"
    }
}

// MARK: - Post Create

struct CreatePostRequest: Codable {
    let postType: String
    let content: String?
    let workoutId: String?
    let foodEntryId: String?
    let isPublic: Bool

    enum CodingKeys: String, CodingKey {
        case content
        case postType = "post_type"
        case workoutId = "workout_id"
        case foodEntryId = "food_entry_id"
        case isPublic = "is_public"
    }
}

// MARK: - Comment

struct PostComment: Identifiable, Codable {
    let id: String
    let postId: String
    let userId: String
    let content: String
    let createdAt: Date
    var author: CommentAuthor?

    enum CodingKeys: String, CodingKey {
        case id, content, author
        case postId = "post_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct CommentAuthor: Codable {
    let id: String
    let name: String
    let profileImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImageUrl = "profile_image_url"
    }
}

// MARK: - Achievement

struct Achievement: Identifiable, Codable {
    let id: String
    let userId: String
    let achievementType: String
    let title: String
    let description: String?
    let iconUrl: String?
    let earnedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case userId = "user_id"
        case achievementType = "achievement_type"
        case iconUrl = "icon_url"
        case earnedAt = "earned_at"
    }
}
