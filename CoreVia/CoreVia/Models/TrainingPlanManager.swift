//
//  TrainingPlanManager.swift
//  CoreVia
//
//  İdman planı modeli və idarəsi
//

import Foundation
import SwiftUI

// MARK: - Plan Type
enum PlanType: String, Codable, CaseIterable {
    case weightLoss = "WeightLoss"
    case weightGain = "WeightGain"
    case strengthTraining = "StrengthTraining"

    var icon: String {
        switch self {
        case .weightLoss: return "flame.fill"
        case .weightGain: return "arrow.up.circle.fill"
        case .strengthTraining: return "dumbbell.fill"
        }
    }

    var color: Color {
        switch self {
        case .weightLoss: return .orange
        case .weightGain: return .green
        case .strengthTraining: return .red
        }
    }

    var localizedName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .weightLoss: return loc.localized("plan_type_weight_loss")
        case .weightGain: return loc.localized("plan_type_weight_gain")
        case .strengthTraining: return loc.localized("plan_type_strength")
        }
    }
}

// MARK: - Plan Workout (Plan daxilindəki məşq)
struct PlanWorkout: Identifiable, Codable {
    let id: String
    var name: String
    var sets: Int
    var reps: Int
    var duration: Int? // dəqiqə

    init(
        id: String = UUID().uuidString,
        name: String,
        sets: Int = 3,
        reps: Int = 12,
        duration: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.duration = duration
    }
}

// MARK: - Training Plan Model
struct TrainingPlan: Identifiable, Codable {
    let id: String
    var title: String
    var planType: PlanType
    var workouts: [PlanWorkout]
    var assignedStudentName: String?
    var createdDate: Date
    var notes: String?

    init(
        id: String = UUID().uuidString,
        title: String,
        planType: PlanType,
        workouts: [PlanWorkout] = [],
        assignedStudentName: String? = nil,
        createdDate: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.planType = planType
        self.workouts = workouts
        self.assignedStudentName = assignedStudentName
        self.createdDate = createdDate
        self.notes = notes
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: createdDate)
    }
}

// MARK: - Training Plan Manager
class TrainingPlanManager: ObservableObject {

    static let shared = TrainingPlanManager()

    @Published var plans: [TrainingPlan] = []

    private let storageKey = "saved_training_plans"

    init() {
        loadPlans()
    }

    // MARK: - CRUD

    func addPlan(_ plan: TrainingPlan) {
        plans.insert(plan, at: 0)
        savePlans()
    }

    func updatePlan(_ plan: TrainingPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
            savePlans()
        }
    }

    func deletePlan(_ plan: TrainingPlan) {
        plans.removeAll { $0.id == plan.id }
        savePlans()
    }

    func deletePlan(at offsets: IndexSet) {
        plans.remove(atOffsets: offsets)
        savePlans()
    }

    // MARK: - Filters

    func plansForType(_ type: PlanType) -> [TrainingPlan] {
        plans.filter { $0.planType == type }
    }

    func plansForStudent(_ studentName: String) -> [TrainingPlan] {
        plans.filter { $0.assignedStudentName == studentName }
    }

    var totalPlans: Int { plans.count }

    // MARK: - Persistence

    private func savePlans() {
        do {
            let encoded = try JSONEncoder().encode(plans)
            UserDefaults.standard.set(encoded, forKey: storageKey)
            print("✅ İdman planları saxlanıldı: \(plans.count) ədəd")
        } catch {
            print("❌ İdman planlarını saxlaya bilmədi: \(error)")
        }
    }

    private func loadPlans() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            print("ℹ️ Heç bir saxlanılmış idman planı yoxdur")
            return
        }

        do {
            plans = try JSONDecoder().decode([TrainingPlan].self, from: data)
            print("✅ İdman planları yükləndi: \(plans.count) ədəd")
        } catch {
            print("❌ İdman planlarını yükləyə bilmədi: \(error)")
            plans = []
        }
    }

    func clearAllPlans() {
        plans = []
        UserDefaults.standard.removeObject(forKey: storageKey)
        print("🗑️ Bütün idman planları silindi")
    }
}
