//
//  AddFoodView.swift
//  CoreVia
//
//  Qida əlavə etmək view (Placeholder - gələcək inkişaf üçün)
//

import SwiftUI

struct AddFoodView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var mealName: String = ""
    @State private var calories: String = ""
    @State private var selectedMealType: MealType = .breakfast
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Coming Soon Banner
                        VStack(spacing: 12) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Tezliklə!")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Qida tracking funksiyası hal-hazırda hazırlanır. Məşq tracking-i test edin!")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 40)
                        
                        // MARK: - Preview UI (Demo)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Gələcək Funksiyalar:")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            FeaturePreviewRow(
                                icon: "plus.circle.fill",
                                title: "Qida əlavə et",
                                description: "Kalori və makro hesablama"
                            )
                            
                            FeaturePreviewRow(
                                icon: "chart.bar.fill",
                                title: "Günlük tracking",
                                description: "Səhər, günorta, axşam"
                            )
                            
                            FeaturePreviewRow(
                                icon: "target",
                                title: "Məqsəd təyini",
                                description: "Kalori və makro hədəfləri"
                            )
                            
                            FeaturePreviewRow(
                                icon: "camera.fill",
                                title: "Şəkil tanıma",
                                description: "AI ilə qida tanıma (gələcək)"
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(14)
                        
                        // MARK: - Placeholder Form
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Önizləmə (işləmir)")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            // Meal Type
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(MealType.allCases, id: \.self) { type in
                                        MealTypeButton(
                                            type: type,
                                            isSelected: selectedMealType == type
                                        ) {
                                            selectedMealType = type
                                        }
                                    }
                                }
                            }
                            
                            // Food Name
                            TextField("Qida adı", text: $mealName)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .disabled(true)
                            
                            // Calories
                            TextField("Kalori", text: $calories)
                                .foregroundColor(.white)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .disabled(true)
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(14)
                        .opacity(0.5)
                    }
                    .padding()
                }
            }
            .navigationTitle("Qida Əlavə Et")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Bağla") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

// MARK: - Meal Type
enum MealType: String, CaseIterable {
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
}

// MARK: - Components
struct FeaturePreviewRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .bold()
                
                Text(description)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Spacer()
        }
    }
}

struct MealTypeButton: View {
    let type: MealType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.title3)
                
                Text(type.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(width: 70, height: 70)
            .background(
                isSelected ?
                Color.green.opacity(0.3) :
                Color.white.opacity(0.05)
            )
            .cornerRadius(12)
        }
        .disabled(true)
    }
}

#Preview {
    AddFoodView()
}
