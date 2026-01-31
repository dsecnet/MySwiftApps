

import Foundation
import SwiftUI

// MARK: - Meal Type
enum MealType: String, Codable, CaseIterable {
    case breakfast = "Səhər"
    case lunch = "Günorta"
    case dinner = "Axşam"
    case snack = "Snack"
    
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
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .purple
        case .snack: return .green
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
    var name: String
    var calories: Int
    var protein: Double?
    var carbs: Double?
    var fats: Double?
    var mealType: MealType
    var date: Date
    var notes: String?
    var hasImage: Bool

    init(
        id: String = UUID().uuidString,
        name: String,
        calories: Int,
        protein: Double? = nil,
        carbs: Double? = nil,
        fats: Double? = nil,
        mealType: MealType,
        date: Date = Date(),
        notes: String? = nil,
        hasImage: Bool = false
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.mealType = mealType
        self.date = date
        self.notes = notes
        self.hasImage = hasImage
    }

    // Köhnə data ilə uyğunluq üçün custom decoder
    enum CodingKeys: String, CodingKey {
        case id, name, calories, protein, carbs, fats, mealType, date, notes, hasImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Int.self, forKey: .calories)
        protein = try container.decodeIfPresent(Double.self, forKey: .protein)
        carbs = try container.decodeIfPresent(Double.self, forKey: .carbs)
        fats = try container.decodeIfPresent(Double.self, forKey: .fats)
        mealType = try container.decode(MealType.self, forKey: .mealType)
        date = try container.decode(Date.self, forKey: .date)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        hasImage = try container.decodeIfPresent(Bool.self, forKey: .hasImage) ?? false
    }
}

// MARK: - Food Manager
class FoodManager: ObservableObject {
    
    static let shared = FoodManager()
    
    @Published var foodEntries: [FoodEntry] = []
    @Published var dailyCalorieGoal: Int = 2000
    
    private let entriesKey = "saved_food_entries"
    private let goalKey = "daily_calorie_goal"
    
    init() {
        loadEntries()
        loadGoal()
    }
    
    // MARK: - CRUD Operations
    
    func addEntry(_ entry: FoodEntry) {
        foodEntries.insert(entry, at: 0)
        saveEntries()
    }
    
    func updateEntry(_ entry: FoodEntry) {
        if let index = foodEntries.firstIndex(where: { $0.id == entry.id }) {
            foodEntries[index] = entry
            saveEntries()
        }
    }
    
    func deleteEntry(_ entry: FoodEntry) {
        if entry.hasImage {
            FoodImageManager.shared.deleteImage(forEntryId: entry.id)
        }
        foodEntries.removeAll { $0.id == entry.id }
        saveEntries()
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
        UserDefaults.standard.set(goal, forKey: goalKey)
        print("✅ Günlük hədəf yeniləndi: \(goal) kcal")
    }
    
    // MARK: - Persistence
    
    private func saveEntries() {
        do {
            let encoded = try JSONEncoder().encode(foodEntries)
            UserDefaults.standard.set(encoded, forKey: entriesKey)
            print("✅ Qida qeydləri saxlanıldı: \(foodEntries.count) ədəd")
        } catch {
            print("❌ Qida qeydlərini saxlaya bilmədi: \(error)")
        }
    }
    
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
            print("ℹ️ Heç bir saxlanılmış qida yoxdur")
            loadMockData()
            return
        }
        
        do {
            foodEntries = try JSONDecoder().decode([FoodEntry].self, from: data)
            print("✅ Qida qeydləri yükləndi: \(foodEntries.count) ədəd")
        } catch {
            print("❌ Qida qeydlərini yükləyə bilmədi: \(error)")
            foodEntries = []
        }
    }
    
    private func loadGoal() {
        let savedGoal = UserDefaults.standard.integer(forKey: goalKey)
        if savedGoal > 0 {
            dailyCalorieGoal = savedGoal
        }
    }
    
    private func loadMockData() {
        foodEntries = [
            FoodEntry(name: "Yumurta omlet", calories: 250, protein: 18, carbs: 5, fats: 18, mealType: .breakfast),
            FoodEntry(name: "Toyuq filesi", calories: 350, protein: 45, carbs: 10, fats: 12, mealType: .lunch),
            FoodEntry(name: "Alma", calories: 80, protein: 0, carbs: 20, fats: 0, mealType: .snack)
        ]
    }
    
    func clearAllEntries() {
        foodEntries = []
        UserDefaults.standard.removeObject(forKey: entriesKey)
        print("🗑️ Bütün qida qeydləri silindi")
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
