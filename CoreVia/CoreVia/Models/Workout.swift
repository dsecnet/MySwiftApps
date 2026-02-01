//
//  Workout.swift
//  CoreVia
//
//  Məşq data modeli
//

import Foundation

// MARK: - Workout Category (Məşq kateqoriyası)
enum WorkoutCategory: String, Codable, CaseIterable {
    case strength = "strength"
    case cardio = "cardio"
    case flexibility = "flexibility"
    case endurance = "endurance"
    
    var icon: String {
        switch self {
        case .strength:
            return "figure.strengthtraining.traditional"
        case .cardio:
            return "heart.fill"
        case .flexibility:
            return "figure.yoga"
        case .endurance:
            return "figure.run"
        }
    }
    
    var color: String {
        switch self {
        case .strength:
            return "red"
        case .cardio:
            return "orange"
        case .flexibility:
            return "purple"
        case .endurance:
            return "blue"
        }
    }

    var localizedName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .strength: return loc.localized("workout_cat_strength")
        case .cardio: return loc.localized("workout_cat_cardio")
        case .flexibility: return loc.localized("workout_cat_flexibility")
        case .endurance: return loc.localized("workout_cat_endurance")
        }
    }
}

// MARK: - Workout Model
struct Workout: Identifiable, Codable {
    let id: String
    var userId: String?
    var title: String                   // Məşqın adı
    var category: WorkoutCategory       // Kateqoriya
    var duration: Int                   // Dəqiqə
    var caloriesBurned: Int?            // Yandırılan kalori (optional)
    var notes: String?                  // Qeydlər
    var date: Date                      // Məşq tarixi
    var isCompleted: Bool               // Tamamlandı?

    enum CodingKeys: String, CodingKey {
        case id, title, category, duration, notes, date
        case userId = "user_id"
        case caloriesBurned = "calories_burned"
        case isCompleted = "is_completed"
    }

    // MARK: - Init
    init(
        id: String = UUID().uuidString,
        userId: String? = nil,
        title: String,
        category: WorkoutCategory,
        duration: Int,
        caloriesBurned: Int? = nil,
        notes: String? = nil,
        date: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.category = category
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.notes = notes
        self.date = date
        self.isCompleted = isCompleted
    }
}

// MARK: - Mock Data (Test üçün)
extension Workout {
    static let mockWorkouts: [Workout] = [
        Workout(
            title: "Biceps Training",
            category: .strength,
            duration: 20,
            caloriesBurned: 150,
            notes: "3 set x 12 təkrar",
            isCompleted: true
        ),
        Workout(
            title: "Morning Run",
            category: .cardio,
            duration: 30,
            caloriesBurned: 250,
            isCompleted: true
        ),
        Workout(
            title: "Leg Day",
            category: .strength,
            duration: 45,
            caloriesBurned: 320,
            isCompleted: false
        )
    ]
}

// MARK: - Helpers
extension Workout {
    // Bugünkü məşq?
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    // Bu həftəki məşq?
    var isThisWeek: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    // Tarix formatı
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    // Qısa tarix (bugün, dünən)
    var relativeDate: String {
        let loc = LocalizationManager.shared
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return loc.localized("common_today")
        } else if calendar.isDateInYesterday(date) {
            return loc.localized("common_yesterday")
        } else {
            return formattedDate
        }
    }
}
