import Foundation

// MARK: - Complaint Type
enum ComplaintType: String, Codable, CaseIterable {
    case fakeListing = "fake_listing"
    case wrongPrice = "wrong_price"
    case wrongPhotos = "wrong_photos"
    case agentBehavior = "agent_behavior"
    case fraud = "fraud"
    case other = "other"

    var displayKey: String {
        switch self {
        case .fakeListing: return "fake_listing"
        case .wrongPrice: return "wrong_price"
        case .wrongPhotos: return "wrong_photos"
        case .agentBehavior: return "agent_behavior"
        case .fraud: return "fraud"
        case .other: return "other"
        }
    }

    var icon: String {
        switch self {
        case .fakeListing: return "doc.questionmark"
        case .wrongPrice: return "dollarsign.circle"
        case .wrongPhotos: return "photo.badge.exclamationmark"
        case .agentBehavior: return "person.badge.exclamationmark"
        case .fraud: return "exclamationmark.shield"
        case .other: return "ellipsis.circle"
        }
    }
}

// MARK: - Complaint Target Type
enum ComplaintTargetType: String, Codable {
    case listing
    case agent
}

// MARK: - Complaint Status
enum ComplaintStatus: String, Codable {
    case sent = "sent"
    case reviewing = "reviewing"
    case resolved = "resolved"
    case rejected = "rejected"
}

// MARK: - Complaint Model
struct Complaint: Codable, Identifiable {
    let id: String
    let reporterId: String
    var targetType: ComplaintTargetType
    var targetId: String
    var complaintType: ComplaintType
    var description: String
    var screenshots: [String]
    var status: ComplaintStatus
    var adminNote: String?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, description, screenshots, status
        case reporterId = "reporter_id"
        case targetType = "target_type"
        case targetId = "target_id"
        case complaintType = "complaint_type"
        case adminNote = "admin_note"
        case createdAt = "created_at"
    }
}

// MARK: - Create Complaint Request
struct CreateComplaintRequest: Codable {
    let targetType: String
    let targetId: String
    let complaintType: String
    let description: String
    let screenshots: [String]

    enum CodingKeys: String, CodingKey {
        case description, screenshots
        case targetType = "target_type"
        case targetId = "target_id"
        case complaintType = "complaint_type"
    }
}
