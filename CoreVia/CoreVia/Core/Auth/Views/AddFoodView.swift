//
//  AddFoodView.swift
//  CoreVia
//
//  Sadələşdirilmiş versiya - compiler error həlli
//

import SwiftUI

struct AddFoodView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var mealName: String = ""
    @State private var calories: String = ""
    @State private var selectedMealType: MealType = .breakfast
    
    var body: some View {
        NavigationStack {
            contentView
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
    
    // MARK: - Content View
    private var contentView: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    comingSoonBanner
                    featuresList
                    placeholderForm
                }
                .padding()
            }
        }
    }
    
    // MARK: - Coming Soon Banner
    private var comingSoonBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Tezliklə!")
                .font(.title2)
                .bold()
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text("Qida tracking funksiyası hal-hazırda hazırlanır. Məşq tracking-i test edin!")
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Features List
    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gələcək Funksiyalar:")
                .foregroundColor(AppTheme.Colors.primaryText)
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
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
    }
    
    // MARK: - Placeholder Form
    private var placeholderForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Önizləmə (işləmir)")
                .foregroundColor(AppTheme.Colors.secondaryText)
                .font(.caption)
            
            mealTypeSelector
            
            TextField("Qida adı", text: $mealName)
                .foregroundColor(AppTheme.Colors.primaryText)
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .disabled(true)
            
            TextField("Kalori", text: $calories)
                .foregroundColor(AppTheme.Colors.primaryText)
                .keyboardType(.numberPad)
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .disabled(true)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(14)
        .opacity(0.5)
    }
    
    // MARK: - Meal Type Selector
    private var mealTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MealType.allCases, id: \.self) { type in
                    mealTypeButton(for: type)
                }
            }
        }
    }
    
    private func mealTypeButton(for type: MealType) -> some View {
        Button {
            selectedMealType = type
        } label: {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.title3)
                
                Text(type.rawValue)
                    .font(.caption)
            }
            .foregroundColor(selectedMealType == type ? .white : AppTheme.Colors.secondaryText)
            .frame(width: 70, height: 70)
            .background(
                selectedMealType == type ?
                Color.green.opacity(0.3) :
                AppTheme.Colors.secondaryBackground
            )
            .cornerRadius(12)
        }
        .disabled(true)
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

// MARK: - Feature Preview Row
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
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .font(.subheadline)
                    .bold()
                
                Text(description)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .font(.caption)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AddFoodView()
}
