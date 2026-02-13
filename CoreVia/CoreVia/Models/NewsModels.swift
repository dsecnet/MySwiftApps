import Foundation

// MARK: - News Article
struct NewsArticle: Codable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let category: String
    let source: String
    let readingTime: Int
    let imageDescription: String
    let publishedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, summary, category, source
        case readingTime = "reading_time"
        case imageDescription = "image_description"
        case publishedAt = "published_at"
    }

    var categoryIcon: String {
        switch category.lowercased() {
        case "workout": return "dumbbell.fill"
        case "nutrition": return "fork.knife"
        case "research": return "flask.fill"
        case "tips": return "lightbulb.fill"
        case "lifestyle": return "heart.fill"
        default: return "newspaper.fill"
        }
    }

    var categoryColor: String {
        switch category.lowercased() {
        case "workout": return "blue"
        case "nutrition": return "green"
        case "research": return "purple"
        case "tips": return "orange"
        case "lifestyle": return "pink"
        default: return "gray"
        }
    }

    var publishedDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: publishedAt)
    }

    var timeAgo: String {
        guard let date = publishedDate else { return "" }

        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .day], from: date, to: now)

        if let days = components.day, days > 0 {
            return "\(days) gün əvvəl"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) saat əvvəl"
        } else {
            return "İndi"
        }
    }
}

// MARK: - News Response
struct NewsResponse: Codable {
    let articles: [NewsArticle]
    let total: Int
    let cacheStatus: String

    enum CodingKeys: String, CodingKey {
        case articles, total
        case cacheStatus = "cache_status"
    }
}

// MARK: - News Category
struct NewsCategory: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
}

struct NewsCategoriesResponse: Codable {
    let categories: [NewsCategory]
}
