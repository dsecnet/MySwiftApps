//
//  ExerciseModels.swift
//  CoreVia
//
//  Exercise Library data models — free-exercise-db (GitHub)
//

import SwiftUI

// MARK: - Exercise Model
struct Exercise: Identifiable, Codable {
    let id: String
    let name: String
    let force: String?
    let level: String?
    let mechanic: String?
    let equipment: String?
    let primaryMuscles: [String]
    let secondaryMuscles: [String]?
    let instructions: [String]?
    let category: String?
    let images: [String]?

    /// First image URL (GitHub CDN)
    var imageUrl: String? {
        guard let firstImage = images?.first, !firstImage.isEmpty else { return nil }
        return "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/\(firstImage)"
    }

    /// Second image URL (end position)
    var imageUrl2: String? {
        guard let imgs = images, imgs.count > 1 else { return nil }
        return "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/\(imgs[1])"
    }

    /// Primary muscles text (localized)
    var primaryMusclesText: String {
        primaryMuscles.map { MuscleTranslator.translate($0) }.joined(separator: ", ")
    }

    /// Primary body part
    var bodyPart: String {
        primaryMuscles.first ?? ""
    }

    /// Target muscles
    var target: String {
        primaryMusclesText
    }

    /// Equipment text (localized)
    var equipmentText: String {
        EquipmentTranslator.translate(equipment ?? "body only")
    }

    /// Level text (localized)
    var levelText: String {
        LevelTranslator.translate(level ?? "")
    }

    /// Category text (localized)
    var categoryText: String {
        CategoryTranslator.translate(category ?? "strength")
    }

    /// Force text (localized)
    var forceText: String? {
        guard let f = force else { return nil }
        return ForceTranslator.translate(f)
    }

    /// Secondary muscles (localized)
    var secondaryMusclesTranslated: [String]? {
        guard let muscles = secondaryMuscles else { return nil }
        let filtered = muscles.filter { !$0.isEmpty }
        guard !filtered.isEmpty else { return nil }
        return filtered.map { MuscleTranslator.translate($0) }
    }
}

// MARK: - Muscle Group Enum (Body Part Filter)
enum MuscleGroup: String, CaseIterable {
    case chest
    case abdominals
    case shoulders
    case biceps
    case triceps
    case lats
    case middleBack = "middle back"
    case lowerBack = "lower back"
    case quadriceps
    case hamstrings
    case glutes
    case calves
    case forearms
    case traps
    case neck
    case abductors
    case adductors

    var displayName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .chest:      return loc.localized("muscle_chest")
        case .abdominals: return loc.localized("muscle_abdominals")
        case .shoulders:  return loc.localized("muscle_shoulders")
        case .biceps:     return loc.localized("muscle_biceps")
        case .triceps:    return loc.localized("muscle_triceps")
        case .lats:       return loc.localized("muscle_lats")
        case .middleBack: return loc.localized("muscle_middle_back")
        case .lowerBack:  return loc.localized("muscle_lower_back")
        case .quadriceps: return loc.localized("muscle_quadriceps")
        case .hamstrings: return loc.localized("muscle_hamstrings")
        case .glutes:     return loc.localized("muscle_glutes")
        case .calves:     return loc.localized("muscle_calves")
        case .forearms:   return loc.localized("muscle_forearms")
        case .traps:      return loc.localized("muscle_traps")
        case .neck:       return loc.localized("muscle_neck")
        case .abductors:  return loc.localized("muscle_abductors")
        case .adductors:  return loc.localized("muscle_adductors")
        }
    }

    var icon: String {
        switch self {
        case .chest:      return "figure.strengthtraining.traditional"
        case .abdominals: return "figure.core.training"
        case .shoulders:  return "figure.arms.open"
        case .biceps:     return "figure.boxing"
        case .triceps:    return "figure.mixed.cardio"
        case .lats:       return "figure.rowing"
        case .middleBack: return "figure.rowing"
        case .lowerBack:  return "figure.flexibility"
        case .quadriceps: return "figure.walk"
        case .hamstrings: return "figure.run"
        case .glutes:     return "figure.step.training"
        case .calves:     return "figure.run"
        case .forearms:   return "hand.raised.fill"
        case .traps:      return "figure.arms.open"
        case .neck:       return "person.fill"
        case .abductors:  return "figure.walk"
        case .adductors:  return "figure.walk"
        }
    }

    var color: Color {
        switch self {
        case .chest:      return .red
        case .abdominals: return .orange
        case .shoulders:  return .blue
        case .biceps:     return .purple
        case .triceps:    return .indigo
        case .lats:       return .cyan
        case .middleBack: return .teal
        case .lowerBack:  return .teal
        case .quadriceps: return .green
        case .hamstrings: return .green
        case .glutes:     return .mint
        case .calves:     return .cyan
        case .forearms:   return .pink
        case .traps:      return .indigo
        case .neck:       return .gray
        case .abductors:  return .mint
        case .adductors:  return .mint
        }
    }
}

// MARK: - Translators (EN → Localized)
enum MuscleTranslator {
    private static let keyMap: [String: String] = [
        "chest": "muscle_chest", "abdominals": "muscle_abdominals", "shoulders": "muscle_shoulders",
        "biceps": "muscle_biceps", "triceps": "muscle_triceps", "lats": "muscle_lats",
        "middle back": "muscle_middle_back", "lower back": "muscle_lower_back",
        "quadriceps": "muscle_quadriceps", "hamstrings": "muscle_hamstrings",
        "glutes": "muscle_glutes", "calves": "muscle_calves", "forearms": "muscle_forearms",
        "traps": "muscle_traps", "neck": "muscle_neck",
        "abductors": "muscle_abductors", "adductors": "muscle_adductors"
    ]
    static func translate(_ muscle: String) -> String {
        guard let key = keyMap[muscle.lowercased()] else { return muscle.capitalized }
        return LocalizationManager.shared.localized(key)
    }
}

enum EquipmentTranslator {
    private static let keyMap: [String: String] = [
        "barbell": "equip_barbell", "dumbbell": "equip_dumbbell", "cable": "equip_cable",
        "machine": "equip_machine", "body only": "equip_body_only",
        "bands": "equip_bands", "kettlebells": "equip_kettlebells",
        "medicine ball": "equip_medicine_ball", "exercise ball": "equip_exercise_ball",
        "foam roll": "equip_foam_roll", "e-z curl bar": "equip_ez_bar",
        "other": "equip_other"
    ]
    static func translate(_ equipment: String) -> String {
        guard let key = keyMap[equipment.lowercased()] else { return equipment.capitalized }
        return LocalizationManager.shared.localized(key)
    }
}

enum LevelTranslator {
    private static let keyMap: [String: String] = [
        "beginner": "level_beginner", "intermediate": "level_intermediate", "expert": "level_expert"
    ]
    static func translate(_ level: String) -> String {
        guard let key = keyMap[level.lowercased()] else { return level.capitalized }
        return LocalizationManager.shared.localized(key)
    }
}

enum CategoryTranslator {
    private static let keyMap: [String: String] = [
        "strength": "cat_strength", "stretching": "cat_stretching",
        "plyometrics": "cat_plyometrics", "strongman": "cat_strongman",
        "powerlifting": "cat_powerlifting", "cardio": "cat_cardio",
        "olympic weightlifting": "cat_olympic",
        "crossfit": "cat_crossfit"
    ]
    static func translate(_ category: String) -> String {
        guard let key = keyMap[category.lowercased()] else { return category.capitalized }
        return LocalizationManager.shared.localized(key)
    }
}

enum ForceTranslator {
    private static let keyMap: [String: String] = [
        "push": "force_push", "pull": "force_pull", "static": "force_static"
    ]
    static func translate(_ force: String) -> String {
        guard let key = keyMap[force.lowercased()] else { return force.capitalized }
        return LocalizationManager.shared.localized(key)
    }
}
