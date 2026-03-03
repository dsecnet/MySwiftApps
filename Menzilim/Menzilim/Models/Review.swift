import Foundation

// MARK: - Review Model
struct Review: Codable, Identifiable {
    let id: String
    let agentId: String
    let userId: String
    var rating: Int
    var comment: String
    var agentReply: String?
    var createdAt: Date?

    // Joined user info
    var user: User?

    var starsArray: [Bool] {
        (1...5).map { $0 <= rating }
    }

    var timeAgo: String {
        guard let date = createdAt else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    enum CodingKeys: String, CodingKey {
        case id, rating, comment, user
        case agentId = "agent_id"
        case userId = "user_id"
        case agentReply = "agent_reply"
        case createdAt = "created_at"
    }
}

// MARK: - Create Review Request
struct CreateReviewRequest: Codable {
    let rating: Int
    let comment: String
}
