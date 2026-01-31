//
//  MealPlanManager.swift
//  CoreVia
//
//  Qida planı modeli və idarəsi
//

import Foundation
import SwiftUI

// MARK: - Meal Plan Item (Plan daxilindəki yemək)
struct MealPlanItem: Identifiable, Codable {
    let id: String
    var name: String
    var calories: Int
    var protein: Double?
    var carbs: Double?
    var fats: Double?
    var mealType: MealType

    init(
        id: String = UUID().uuidString,
        name: String,
        calories: Int,
        protein: Double? = nil,
        carbs: Double? = nil,
        fats: Double? = nil,
        mealType: MealType = .breakfast
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.mealType = mealType
    }
}

// MARK: - Meal Plan Model
struct MealPlan: Identifiable, Codable {
    let id: String
    var title: String
    var planType: PlanType
    var meals: [MealPlanItem]
    var assignedStudentName: String?
    var createdDate: Date
    var dailyCalorieTarget: Int
    var notes: String?

    init(
        id: String = UUID().uuidString,
        title: String,
        planType: PlanType,
        meals: [MealPlanItem] = [],
        assignedStudentName: String? = nil,
        createdDate: Date = Date(),
        dailyCalorieTarget: Int = 2000,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.planType = planType
        self.meals = meals
        self.assignedStudentName = assignedStudentName
        self.createdDate = createdDate
        self.dailyCalorieTarget = dailyCalorieTarget
        self.notes = notes
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: createdDate)
    }

    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        meals.compactMap { $0.protein }.reduce(0, +)
    }

    var totalCarbs: Double {
        meals.compactMap { $0.carbs }.reduce(0, +)
    }

    var totalFats: Double {
        meals.compactMap { $0.fats }.reduce(0, +)
    }
}

// MARK: - Meal Plan Manager
class MealPlanManager: ObservableObject {

    static let shared = MealPlanManager()

    @Published var plans: [MealPlan] = []

    private let storageKey = "saved_meal_plans"

    init() {
        loadPlans()
    }

    // MARK: - CRUD

    func addPlan(_ plan: MealPlan) {
        plans.insert(plan, at: 0)
        savePlans()
    }

    func updatePlan(_ plan: MealPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
            savePlans()
        }
    }

    func deletePlan(_ plan: MealPlan) {
        plans.removeAll { $0.id == plan.id }
        savePlans()
    }

    func deletePlan(at offsets: IndexSet) {
        plans.remove(atOffsets: offsets)
        savePlans()
    }

    // MARK: - Filters

    func plansForType(_ type: PlanType) -> [MealPlan] {
        plans.filter { $0.planType == type }
    }

    func plansForStudent(_ studentName: String) -> [MealPlan] {
        plans.filter { $0.assignedStudentName == studentName }
    }

    var totalPlans: Int { plans.count }

    // MARK: - Persistence

    private func savePlans() {
        do {
            let encoded = try JSONEncoder().encode(plans)
            UserDefaults.standard.set(encoded, forKey: storageKey)
            print("✅ Qida planları saxlanıldı: \(plans.count) ədəd")
        } catch {
            print("❌ Qida planlarını saxlaya bilmədi: \(error)")
        }
    }

    private func loadPlans() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            print("ℹ️ Heç bir saxlanılmış qida planı yoxdur")
            return
        }

        do {
            plans = try JSONDecoder().decode([MealPlan].self, from: data)
            print("✅ Qida planları yükləndi: \(plans.count) ədəd")
        } catch {
            print("❌ Qida planlarını yükləyə bilmədi: \(error)")
            plans = []
        }
    }

    func clearAllPlans() {
        plans = []
        UserDefaults.standard.removeObject(forKey: storageKey)
        print("🗑️ Bütün qida planları silindi")
    }
}
