//
//  ExerciseModels.swift
//  CoreVia
//
//  Məşq kitabxanası data modelləri — free-exercise-db (GitHub)
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

    /// İlk şəklin tam URL-i (GitHub CDN)
    var imageUrl: String? {
        guard let firstImage = images?.first, !firstImage.isEmpty else { return nil }
        return "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/\(firstImage)"
    }

    /// İkinci şəklin tam URL-i (son pozisiya)
    var imageUrl2: String? {
        guard let imgs = images, imgs.count > 1 else { return nil }
        return "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/\(imgs[1])"
    }

    /// Əsas əzələlər tekst olaraq (Azərbaycanca)
    var primaryMusclesText: String {
        primaryMuscles.map { MuscleTranslator.translate($0) }.joined(separator: ", ")
    }

    /// Əsas bədən hissəsi
    var bodyPart: String {
        primaryMuscles.first ?? ""
    }

    /// Hədəf əzələlər
    var target: String {
        primaryMusclesText
    }

    /// Avadanlıq tekst olaraq (Azərbaycanca)
    var equipmentText: String {
        EquipmentTranslator.translate(equipment ?? "body only")
    }

    /// Səviyyə (Azərbaycanca)
    var levelText: String {
        LevelTranslator.translate(level ?? "")
    }

    /// Kateqoriya (Azərbaycanca)
    var categoryText: String {
        CategoryTranslator.translate(category ?? "strength")
    }

    /// Qüvvə (Azərbaycanca)
    var forceText: String? {
        guard let f = force else { return nil }
        return ForceTranslator.translate(f)
    }

    /// İkinci əzələlər (Azərbaycanca)
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
        switch self {
        case .chest:      return "Sinə"
        case .abdominals: return "Qarın"
        case .shoulders:  return "Çiyin"
        case .biceps:     return "Biseps"
        case .triceps:    return "Triseps"
        case .lats:       return "Kürək"
        case .middleBack: return "Orta Bel"
        case .lowerBack:  return "Alt Bel"
        case .quadriceps: return "Ön Ayaq"
        case .hamstrings: return "Arxa Ayaq"
        case .glutes:     return "Kalça"
        case .calves:     return "Baldır"
        case .forearms:   return "Bilək"
        case .traps:      return "Trapez"
        case .neck:       return "Boyun"
        case .abductors:  return "Abduktor"
        case .adductors:  return "Adduktor"
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

// MARK: - Translators (EN → AZ)
enum MuscleTranslator {
    private static let map: [String: String] = [
        "chest": "Sinə", "abdominals": "Qarın", "shoulders": "Çiyin",
        "biceps": "Biseps", "triceps": "Triseps", "lats": "Kürək",
        "middle back": "Orta Bel", "lower back": "Alt Bel",
        "quadriceps": "Ön Ayaq", "hamstrings": "Arxa Ayaq",
        "glutes": "Kalça", "calves": "Baldır", "forearms": "Bilək",
        "traps": "Trapez", "neck": "Boyun",
        "abductors": "Abduktor", "adductors": "Adduktor"
    ]
    static func translate(_ muscle: String) -> String {
        map[muscle.lowercased()] ?? muscle.capitalized
    }
}

enum EquipmentTranslator {
    private static let map: [String: String] = [
        "barbell": "Ştanq", "dumbbell": "Gantel", "cable": "Kabel",
        "machine": "Maşın", "body only": "Bədən çəkisi",
        "bands": "Rezin lent", "kettlebells": "Girya",
        "medicine ball": "Tibb topu", "exercise ball": "Fitbol",
        "foam roll": "Foam roller", "e-z curl bar": "EZ Bar",
        "other": "Digər"
    ]
    static func translate(_ equipment: String) -> String {
        map[equipment.lowercased()] ?? equipment.capitalized
    }
}

enum LevelTranslator {
    private static let map: [String: String] = [
        "beginner": "Başlanğıc", "intermediate": "Orta", "expert": "Peşəkar"
    ]
    static func translate(_ level: String) -> String {
        map[level.lowercased()] ?? level.capitalized
    }
}

enum CategoryTranslator {
    private static let map: [String: String] = [
        "strength": "Güc", "stretching": "Gərmə",
        "plyometrics": "Pliometrika", "strongman": "Strongman",
        "powerlifting": "Pauerliftinq", "cardio": "Kardio",
        "olympic weightlifting": "Olimpik Ağırlıq",
        "crossfit": "CrossFit"
    ]
    static func translate(_ category: String) -> String {
        map[category.lowercased()] ?? category.capitalized
    }
}

enum ForceTranslator {
    private static let map: [String: String] = [
        "push": "İtələmə", "pull": "Çəkmə", "static": "Statik"
    ]
    static func translate(_ force: String) -> String {
        map[force.lowercased()] ?? force.capitalized
    }
}
