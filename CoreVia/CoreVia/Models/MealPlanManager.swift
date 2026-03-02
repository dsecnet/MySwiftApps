//
//  MealPlanManager.swift
//  CoreVia
//
//  Qida planı modeli və idarəsi - Backend API ilə
//

import Foundation
import SwiftUI
import os.log

// MARK: - Meal Plan Item (Plan daxilindəki yemək)
struct MealPlanItem: Identifiable, Codable {
    let id: String
    var name: String
    var calories: Int
    var protein: Double?
    var carbs: Double?
    var fats: Double?
    var mealType: MealType

    enum CodingKeys: String, CodingKey {
        case id, name, calories, protein, carbs, fats
        case mealType = "meal_type"
    }

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
    var trainerId: String?
    var assignedStudentId: String?
    var title: String
    var planType: PlanType
    var meals: [MealPlanItem]
    var assignedStudentName: String?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var dailyCalorieTarget: Int
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case id, title, notes
        case trainerId = "trainer_id"
        case assignedStudentId = "assigned_student_id"
        case planType = "plan_type"
        case meals = "items"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case dailyCalorieTarget = "daily_calorie_target"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(
        id: String = UUID().uuidString,
        trainerId: String? = nil,
        assignedStudentId: String? = nil,
        title: String,
        planType: PlanType,
        meals: [MealPlanItem] = [],
        assignedStudentName: String? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        dailyCalorieTarget: Int = 2000,
        notes: String? = nil
    ) {
        self.id = id
        self.trainerId = trainerId
        self.assignedStudentId = assignedStudentId
        self.title = title
        self.planType = planType
        self.meals = meals
        self.assignedStudentName = assignedStudentName
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.dailyCalorieTarget = dailyCalorieTarget
        self.notes = notes
    }

    // Custom decoder - backend is_completed/completed_at göndərməyə bilər
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        trainerId = try container.decodeIfPresent(String.self, forKey: .trainerId)
        assignedStudentId = try container.decodeIfPresent(String.self, forKey: .assignedStudentId)
        title = try container.decode(String.self, forKey: .title)
        planType = try container.decode(PlanType.self, forKey: .planType)
        meals = try container.decodeIfPresent([MealPlanItem].self, forKey: .meals) ?? []
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        dailyCalorieTarget = try container.decodeIfPresent(Int.self, forKey: .dailyCalorieTarget) ?? 2000
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        assignedStudentName = nil
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: createdAt ?? Date())
    }

    // Backward compat
    var createdDate: Date {
        createdAt ?? Date()
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

// MARK: - Backend request models
private struct MealPlanItemCreateRequest: Encodable {
    let name: String
    let calories: Int
    let protein: Double?
    let carbs: Double?
    let fats: Double?
    let mealType: String

    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fats
        case mealType = "meal_type"
    }
}

private struct MealPlanCreateRequest: Encodable {
    let title: String
    let planType: String
    let dailyCalorieTarget: Int
    let notes: String?
    let assignedStudentId: String?
    let items: [MealPlanItemCreateRequest]

    enum CodingKeys: String, CodingKey {
        case title, notes, items
        case planType = "plan_type"
        case dailyCalorieTarget = "daily_calorie_target"
        case assignedStudentId = "assigned_student_id"
    }
}

private struct MealPlanUpdateRequest: Encodable {
    var title: String?
    var planType: String?
    var dailyCalorieTarget: Int?
    var notes: String?
    var assignedStudentId: String?

    enum CodingKeys: String, CodingKey {
        case title, notes
        case planType = "plan_type"
        case dailyCalorieTarget = "daily_calorie_target"
        case assignedStudentId = "assigned_student_id"
    }
}

// MARK: - Meal Plan Manager
class MealPlanManager: ObservableObject {

    static let shared = MealPlanManager()

    @Published var plans: [MealPlan] = []
    @Published var isLoading: Bool = false

    private let api = APIService.shared

    init() {
        loadPlans()
    }

    // MARK: - CRUD

    func addPlan(_ plan: MealPlan) {
        plans.insert(plan, at: 0)

        Task {
            do {
                let itemRequests = plan.meals.map {
                    MealPlanItemCreateRequest(
                        name: $0.name,
                        calories: $0.calories,
                        protein: $0.protein,
                        carbs: $0.carbs,
                        fats: $0.fats,
                        mealType: $0.mealType.rawValue
                    )
                }
                let created: MealPlan = try await api.request(
                    endpoint: "/api/v1/plans/meal",
                    method: "POST",
                    body: MealPlanCreateRequest(
                        title: plan.title,
                        planType: plan.planType.rawValue,
                        dailyCalorieTarget: plan.dailyCalorieTarget,
                        notes: plan.notes,
                        assignedStudentId: plan.assignedStudentId,
                        items: itemRequests
                    )
                )
                await MainActor.run {
                    if let index = self.plans.firstIndex(where: { $0.id == plan.id }) {
                        self.plans[index] = created
                    }
                }
            } catch {
                AppLogger.food.error("Meal plan create xetasi: \(error.localizedDescription)")
            }
        }
    }

    func updatePlan(_ plan: MealPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan

            Task {
                do {
                    let _: MealPlan = try await api.request(
                        endpoint: "/api/v1/plans/meal/\(plan.id)",
                        method: "PUT",
                        body: MealPlanUpdateRequest(
                            title: plan.title,
                            planType: plan.planType.rawValue,
                            dailyCalorieTarget: plan.dailyCalorieTarget,
                            notes: plan.notes,
                            assignedStudentId: plan.assignedStudentId
                        )
                    )
                } catch {
                    AppLogger.food.error("Meal plan update xetasi: \(error.localizedDescription)")
                }
            }
        }
    }

    func deletePlan(_ plan: MealPlan) {
        plans.removeAll { $0.id == plan.id }

        Task {
            do {
                try await api.requestVoid(endpoint: "/api/v1/plans/meal/\(plan.id)")
            } catch {
                AppLogger.food.error("Meal plan delete xetasi: \(error.localizedDescription)")
            }
        }
    }

    func deletePlan(at offsets: IndexSet) {
        let plansToDelete = offsets.map { plans[$0] }
        plans.remove(atOffsets: offsets)

        for plan in plansToDelete {
            Task {
                do {
                    try await api.requestVoid(endpoint: "/api/v1/plans/meal/\(plan.id)")
                } catch {
                    AppLogger.food.error("Meal plan delete xetasi: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Complete Plan

    func completePlan(_ plan: MealPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index].isCompleted = true
            plans[index].completedAt = Date()
        }

        Task {
            do {
                let _: MealPlan = try await api.request(
                    endpoint: "/api/v1/plans/meal/\(plan.id)/complete",
                    method: "PUT"
                )
            } catch {
                await MainActor.run {
                    if let index = self.plans.firstIndex(where: { $0.id == plan.id }) {
                        self.plans[index].isCompleted = false
                        self.plans[index].completedAt = nil
                    }
                }
                AppLogger.food.error("Meal plan complete xetasi: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Filters

    func plansForType(_ type: PlanType) -> [MealPlan] {
        plans.filter { $0.planType == type }
    }

    func plansForStudent(_ studentName: String) -> [MealPlan] {
        plans.filter { $0.assignedStudentName == studentName }
    }

    var totalPlans: Int { plans.count }

    // MARK: - Backend Sync

    func loadPlans() {
        guard KeychainManager.shared.isLoggedIn else {
            AppLogger.food.warning("MealPlanManager: isLoggedIn=false, loadPlans kecildi")
            return
        }

        isLoading = true
        Task {
            do {
                let fetched: [MealPlan] = try await api.request(endpoint: "/api/v1/plans/meal")
                AppLogger.food.info("Meal plans yuklendi: \(fetched.count) plan tapildi")
                await MainActor.run {
                    self.plans = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                AppLogger.food.error("Meal plans yukleme xetasi: \(error.localizedDescription)")
                if let de = error as? DecodingError { AppLogger.food.warning("Decode error type: \(String(describing: type(of: de)))") }
            }
        }
    }

    func clearAllPlans() {
        plans = []
    }
}
