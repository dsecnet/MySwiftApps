import Foundation

// MARK: - Live Session

struct LiveSession: Identifiable, Codable {
    let id: String
    let trainerId: String
    let title: String
    let description: String?
    let sessionType: String  // group, one_on_one, open
    let maxParticipants: Int
    let difficultyLevel: String
    let durationMinutes: Int

    let scheduledStart: Date
    let scheduledEnd: Date
    let actualStart: Date?
    let actualEnd: Date?

    let status: String  // scheduled, live, completed, cancelled
    let isPublic: Bool

    let isPaid: Bool
    let price: Double
    let currency: String

    let workoutPlan: [WorkoutExercise]?

    // Counts
    let registeredCount: Int?
    let activeCount: Int?

    // Trainer
    var trainer: SessionTrainer?

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description, status, price, currency
        case trainerId = "trainer_id"
        case sessionType = "session_type"
        case maxParticipants = "max_participants"
        case difficultyLevel = "difficulty_level"
        case durationMinutes = "duration_minutes"
        case scheduledStart = "scheduled_start"
        case scheduledEnd = "scheduled_end"
        case actualStart = "actual_start"
        case actualEnd = "actual_end"
        case isPublic = "is_public"
        case isPaid = "is_paid"
        case workoutPlan = "workout_plan"
        case registeredCount = "registered_count"
        case activeCount = "active_count"
        case trainer
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SessionTrainer: Codable {
    let id: String
    let name: String
    let profileImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImageUrl = "profile_image_url"
    }
}

struct WorkoutExercise: Codable {
    let name: String
    let type: String
    let reps: Int?
    let sets: Int?
    let durationSeconds: Int?
    let restSeconds: Int

    enum CodingKeys: String, CodingKey {
        case name, type, reps, sets
        case durationSeconds = "duration_seconds"
        case restSeconds = "rest_seconds"
    }
}

// MARK: - Session List Response

struct SessionListResponse: Codable {
    let sessions: [LiveSession]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case sessions, total, page
        case pageSize = "page_size"
        case hasMore = "has_more"
    }
}

// MARK: - Create Session Request

struct CreateSessionRequest: Codable {
    let title: String
    let description: String?
    let sessionType: String
    let maxParticipants: Int
    let difficultyLevel: String
    let durationMinutes: Int
    let scheduledStart: Date
    let isPublic: Bool
    let isPaid: Bool
    let price: Double?
    let currency: String
    let workoutPlan: [WorkoutExercise]

    enum CodingKeys: String, CodingKey {
        case title, description, currency
        case sessionType = "session_type"
        case maxParticipants = "max_participants"
        case difficultyLevel = "difficulty_level"
        case durationMinutes = "duration_minutes"
        case scheduledStart = "scheduled_start"
        case isPublic = "is_public"
        case isPaid = "is_paid"
        case price
        case workoutPlan = "workout_plan"
    }
}

// MARK: - Session Participant

struct SessionParticipant: Identifiable, Codable {
    let id: String
    let sessionId: String
    let userId: String
    let status: String
    let joinedAt: Date?
    let leftAt: Date?
    let completedExercises: Int
    let totalReps: Int
    let caloriesBurned: Double
    let avgFormScore: Double?
    let totalCorrections: Int
    let createdAt: Date

    var user: ParticipantUser?

    enum CodingKeys: String, CodingKey {
        case id, status, user
        case sessionId = "session_id"
        case userId = "user_id"
        case joinedAt = "joined_at"
        case leftAt = "left_at"
        case completedExercises = "completed_exercises"
        case totalReps = "total_reps"
        case caloriesBurned = "calories_burned"
        case avgFormScore = "avg_form_score"
        case totalCorrections = "total_corrections"
        case createdAt = "created_at"
    }
}

struct ParticipantUser: Codable {
    let id: String
    let name: String
    let profileImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImageUrl = "profile_image_url"
    }
}

// MARK: - Session Stats

struct SessionStats: Codable {
    let id: String
    let sessionId: String
    let totalRegistered: Int
    let totalJoined: Int
    let totalCompleted: Int
    let peakConcurrent: Int
    let avgCompletionRate: Double
    let avgFormScore: Double
    let totalCorrections: Int
    let totalReps: Int
    let totalCaloriesBurned: Double
    let avgDurationMinutes: Double
    let avgRating: Double?
    let totalRatings: Int

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case totalRegistered = "total_registered"
        case totalJoined = "total_joined"
        case totalCompleted = "total_completed"
        case peakConcurrent = "peak_concurrent"
        case avgCompletionRate = "avg_completion_rate"
        case avgFormScore = "avg_form_score"
        case totalCorrections = "total_corrections"
        case totalReps = "total_reps"
        case totalCaloriesBurned = "total_calories_burned"
        case avgDurationMinutes = "avg_duration_minutes"
        case avgRating = "avg_rating"
        case totalRatings = "total_ratings"
    }
}

// MARK: - WebSocket Messages

struct WSMessage: Codable {
    let type: String
    let data: [String: AnyCodable]
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        }
    }
}

struct SessionStartMessage: Codable {
    let type: String
    let sessionId: String
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case type
        case sessionId = "session_id"
        case timestamp
    }
}

struct FormCorrectionMessage: Codable {
    let type: String
    let userId: String
    let correctionType: String
    let message: String
    let formScore: Double

    enum CodingKeys: String, CodingKey {
        case type, message
        case userId = "user_id"
        case correctionType = "correction_type"
        case formScore = "form_score"
    }
}
