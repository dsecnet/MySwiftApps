
//
//  FoodManager.swift
//  CoreVia
//
//  Qida data management - Backend API ilə
//

import Foundation
import SwiftUI

// MARK: - Meal Type
enum MealType: String, Codable, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .breakfast: return AppTheme.Colors.mealBreakfast
        case .lunch: return AppTheme.Colors.mealLunch
        case .dinner: return AppTheme.Colors.mealDinner
        case .snack: return AppTheme.Colors.mealSnack
        }
    }

    var localizedName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .breakfast: return loc.localized("food_meal_breakfast")
        case .lunch: return loc.localized("food_meal_lunch")
        case .dinner: return loc.localized("food_meal_dinner")
        case .snack: return loc.localized("food_meal_snack")
        }
    }
}

// MARK: - Food Entry Model
struct FoodEntry: Identifiable, Codable {
    let id: String
    var userId: String?
    var name: String
    var calories: Int
    var protein: Double?
    var carbs: Double?
    var fats: Double?
    var mealType: MealType
    var date: Date
    var notes: String?
    var hasImage: Bool
    var imageUrl: String?
    var aiAnalyzed: Bool?
    var aiConfidence: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, calories, protein, carbs, fats, date, notes
        case userId = "user_id"
        case mealType = "meal_type"
        case hasImage = "has_image"
        case imageUrl = "image_url"
        case aiAnalyzed = "ai_analyzed"
        case aiConfidence = "ai_confidence"
    }

    init(
        id: String = UUID().uuidString,
        userId: String? = nil,
        name: String,
        calories: Int,
        protein: Double? = nil,
        carbs: Double? = nil,
        fats: Double? = nil,
        mealType: MealType,
        date: Date = Date(),
        notes: String? = nil,
        hasImage: Bool = false,
        imageUrl: String? = nil,
        aiAnalyzed: Bool? = nil,
        aiConfidence: Double? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.mealType = mealType
        self.date = date
        self.notes = notes
        self.hasImage = hasImage
        self.imageUrl = imageUrl
        self.aiAnalyzed = aiAnalyzed
        self.aiConfidence = aiConfidence
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Int.self, forKey: .calories)
        protein = try container.decodeIfPresent(Double.self, forKey: .protein)
        carbs = try container.decodeIfPresent(Double.self, forKey: .carbs)
        fats = try container.decodeIfPresent(Double.self, forKey: .fats)
        mealType = try container.decode(MealType.self, forKey: .mealType)
        date = try container.decode(Date.self, forKey: .date)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        hasImage = try container.decodeIfPresent(Bool.self, forKey: .hasImage) ?? false
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        aiAnalyzed = try container.decodeIfPresent(Bool.self, forKey: .aiAnalyzed)
        aiConfidence = try container.decodeIfPresent(Double.self, forKey: .aiConfidence)
    }
}

// MARK: - Backend request models
private struct FoodCreateRequest: Encodable {
    let name: String
    let calories: Int
    let protein: Double?
    let carbs: Double?
    let fats: Double?
    let mealType: String
    let date: Date?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fats, date, notes
        case mealType = "meal_type"
    }
}

private struct FoodUpdateRequest: Encodable {
    var name: String?
    var calories: Int?
    var protein: Double?
    var carbs: Double?
    var fats: Double?
    var mealType: String?
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fats, notes
        case mealType = "meal_type"
    }
}

// MARK: - Food Manager
class FoodManager: ObservableObject {

    static let shared = FoodManager()

    @Published var foodEntries: [FoodEntry] = []
    @Published var dailyCalorieGoal: Int = 2000
    @Published var isLoading: Bool = false

    private let api = APIService.shared

    init() {
        loadEntries()
    }

    // MARK: - CRUD Operations

    func addEntry(_ entry: FoodEntry) {
        foodEntries.insert(entry, at: 0)

        Task {
            do {
                let created: FoodEntry = try await api.request(
                    endpoint: "/api/v1/food/",
                    method: "POST",
                    body: FoodCreateRequest(
                        name: entry.name,
                        calories: entry.calories,
                        protein: entry.protein,
                        carbs: entry.carbs,
                        fats: entry.fats,
                        mealType: entry.mealType.rawValue,
                        date: entry.date,
                        notes: entry.notes
                    )
                )
                await MainActor.run {
                    if let index = self.foodEntries.firstIndex(where: { $0.id == entry.id }) {
                        self.foodEntries[index] = created
                    }
                }
            } catch {
                print("Food create xətası: \(error)")
            }
        }
    }

    func updateEntry(_ entry: FoodEntry) {
        if let index = foodEntries.firstIndex(where: { $0.id == entry.id }) {
            foodEntries[index] = entry

            Task {
                do {
                    let _: FoodEntry = try await api.request(
                        endpoint: "/api/v1/food/\(entry.id)",
                        method: "PUT",
                        body: FoodUpdateRequest(
                            name: entry.name,
                            calories: entry.calories,
                            protein: entry.protein,
                            carbs: entry.carbs,
                            fats: entry.fats,
                            mealType: entry.mealType.rawValue,
                            notes: entry.notes
                        )
                    )
                } catch {
                    print("Food update xətası: \(error)")
                }
            }
        }
    }

    func deleteEntry(_ entry: FoodEntry) {
        foodEntries.removeAll { $0.id == entry.id }

        Task {
            do {
                try await api.requestVoid(endpoint: "/api/v1/food/\(entry.id)")
            } catch {
                print("Food delete xətası: \(error)")
            }
        }
    }

    // MARK: - Filters

    var todayEntries: [FoodEntry] {
        foodEntries.filter { Calendar.current.isDateInToday($0.date) }
    }

    func entriesForMealType(_ type: MealType) -> [FoodEntry] {
        todayEntries.filter { $0.mealType == type }
    }

    // MARK: - Statistics

    var todayTotalCalories: Int {
        todayEntries.reduce(0) { $0 + $1.calories }
    }

    var todayTotalProtein: Double {
        todayEntries.compactMap { $0.protein }.reduce(0, +)
    }

    var todayTotalCarbs: Double {
        todayEntries.compactMap { $0.carbs }.reduce(0, +)
    }

    var todayTotalFats: Double {
        todayEntries.compactMap { $0.fats }.reduce(0, +)
    }

    var todayProgress: Double {
        Double(todayTotalCalories) / Double(dailyCalorieGoal)
    }

    var remainingCalories: Int {
        max(0, dailyCalorieGoal - todayTotalCalories)
    }

    func caloriesForMealType(_ type: MealType) -> Int {
        entriesForMealType(type).reduce(0) { $0 + $1.calories }
    }

    // MARK: - Goal Management

    func updateDailyGoal(_ goal: Int) {
        dailyCalorieGoal = goal
        UserDefaults.standard.set(goal, forKey: "daily_calorie_goal")
    }

    // MARK: - Backend Sync

    func loadEntries() {
        guard KeychainManager.shared.isLoggedIn else { return }

        isLoading = true
        Task {
            do {
                let fetched: [FoodEntry] = try await api.request(endpoint: "/api/v1/food/")
                await MainActor.run {
                    self.foodEntries = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                print("Food yükləmə xətası: \(error)")
            }
        }
    }

    func clearAllEntries() {
        foodEntries = []
    }
}

// MARK: - Helpers
extension FoodEntry {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
