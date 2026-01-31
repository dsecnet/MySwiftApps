//
//  DemoStudents.swift
//  CoreVia
//
//  Demo tələbə siyahısı - müəllim planlarında istifadə üçün
//

import Foundation
import SwiftUI

// MARK: - Demo Student Model
struct DemoStudent: Identifiable, Codable {
    let id: String
    var name: String
    var progress: Double // 0.0 - 1.0
    var avatarEmoji: String
    var age: Int
    var goal: String

    init(
        id: String = UUID().uuidString,
        name: String,
        progress: Double,
        avatarEmoji: String = "🏋️",
        age: Int = 25,
        goal: String = ""
    ) {
        self.id = id
        self.name = name
        self.progress = progress
        self.avatarEmoji = avatarEmoji
        self.age = age
        self.goal = goal
    }

    var progressPercent: Int {
        Int(progress * 100)
    }

    var progressColor: Color {
        if progress >= 0.8 {
            return .green
        } else if progress >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Static Demo Data
extension DemoStudent {
    static let demoStudents: [DemoStudent] = [
        DemoStudent(
            name: "Nigar Əliyeva",
            progress: 0.75,
            avatarEmoji: "👩‍🦰",
            age: 22,
            goal: "Arıqlamaq"
        ),
        DemoStudent(
            name: "Rəşad Məmmədov",
            progress: 0.60,
            avatarEmoji: "🧔",
            age: 28,
            goal: "Kökəlmək"
        ),
        DemoStudent(
            name: "Leyla Həsənova",
            progress: 0.90,
            avatarEmoji: "👩",
            age: 24,
            goal: "Güc artırmaq"
        )
    ]
}
