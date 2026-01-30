//
//  AddFoodView.swift
//  CoreVia
//
//  TAM FUNKSIONAL - Qida əlavə etmək
//

import SwiftUI

struct AddFoodView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var foodManager = FoodManager.shared
    
    // Form state
    @State private var foodName: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fats: String = ""
    @State private var selectedMealType: MealType = .breakfast
    @State private var notes: String = ""
    @State private var showSuccessAlert: Bool = false
    
    // Quick add items
    let quickAddItems: [QuickAddFood] = [
        QuickAddFood(name: "Yumurta (1 ədəd)", calories: 78, protein: 6, carbs: 0.6, fats: 5, icon: "🥚"),
        QuickAddFood(name: "Banan", calories: 105, protein: 1.3, carbs: 27, fats: 0.4, icon: "🍌"),
        QuickAddFood(name: "Toyuq filesi (100q)", calories: 165, protein: 31, carbs: 0, fats: 3.6, icon: "🍗"),
        QuickAddFood(name: "Alma", calories: 95, protein: 0.5, carbs: 25, fats: 0.3, icon: "🍎"),
        QuickAddFood(name: "Oatmeal (100q)", calories: 389, protein: 17, carbs: 66, fats: 7, icon: "🥣"),
        QuickAddFood(name: "Alma şirəsi (200ml)", calories: 117, protein: 0.3, carbs: 29, fats: 0.3, icon: "🧃")
    ]
    
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
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Saxla") {
                            saveFood()
                        }
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                }
                .alert("Uğurlu! ✅", isPresented: $showSuccessAlert) {
                    Button("OK") {
                        dismiss()
                    }
                } message: {
                    Text("Qida uğurla əlavə olundu!")
                }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    quickAddSection
                    mealTypeSelector
                    mainForm
                    macrosSection
                    notesSection
                }
                .padding()
            }
        }
    }
    
    // MARK: - Quick Add Section
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tez Əlavə Et")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickAddItems) { item in
                        QuickAddButton(item: item) {
                            fillForm(with: item)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Meal Type Selector
    private var mealTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Öğün Növü")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 12) {
                ForEach(MealType.allCases, id: \.self) { type in
                    MealTypeButton(
                        type: type,
                        isSelected: selectedMealType == type
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedMealType = type
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Main Form
    private var mainForm: some View {
        VStack(spacing: 16) {
            // Food Name
            FoodInputField(
                label: "Qida Adı",
                icon: "fork.knife",
                placeholder: "məs: Yumurta omlet",
                text: $foodName
            )
            
            // Calories
            FoodInputField(
                label: "Kalori (kcal)",
                icon: "flame.fill",
                placeholder: "məs: 250",
                text: $calories,
                keyboardType: .numberPad
            )
        }
    }
    
    // MARK: - Macros Section
    private var macrosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Makrolar (opsional)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Spacer()
                
                Text("qram")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            
            HStack(spacing: 12) {
                MacroInputField(
                    label: "Protein",
                    icon: "💪",
                    color: .blue,
                    text: $protein
                )
                
                MacroInputField(
                    label: "Karbohidrat",
                    icon: "🍞",
                    color: .orange,
                    text: $carbs
                )
                
                MacroInputField(
                    label: "Yağ",
                    icon: "🥑",
                    color: .green,
                    text: $fats
                )
            }
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Qeydlər (opsional)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Əlavə məlumat yazın...")
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $notes)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .scrollContentBackground(.hidden)
                    .frame(height: 80)
                    .padding(8)
            }
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !foodName.isEmpty && !calories.isEmpty && Int(calories) != nil
    }
    
    // MARK: - Actions
    private func saveFood() {
        guard isFormValid else { return }
        
        let entry = FoodEntry(
            name: foodName,
            calories: Int(calories) ?? 0,
            protein: Double(protein),
            carbs: Double(carbs),
            fats: Double(fats),
            mealType: selectedMealType,
            notes: notes.isEmpty ? nil : notes
        )
        
        foodManager.addEntry(entry)
        
        withAnimation {
            showSuccessAlert = true
        }
    }
    
    private func fillForm(with item: QuickAddFood) {
        foodName = item.name
        calories = "\(item.calories)"
        protein = "\(Int(item.protein))"
        carbs = "\(Int(item.carbs))"
        fats = "\(Int(item.fats))"
    }
}

// MARK: - Quick Add Food Model
struct QuickAddFood: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fats: Double
    let icon: String
}

// MARK: - Components

struct QuickAddButton: View {
    let item: QuickAddFood
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(item.icon)
                    .font(.system(size: 30))
                
                Text(item.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)
                
                Text("\(item.calories) kcal")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.green)
            }
            .frame(width: 100)
            .padding(.vertical, 12)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.separator, lineWidth: 1)
            )
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
                    .font(.system(size: 20))
                
                Text(type.rawValue)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                type.color :
                AppTheme.Colors.secondaryBackground
            )
            .cornerRadius(12)
        }
    }
}

struct FoodInputField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.red)
                    .frame(width: 20)
                
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.Colors.tertiaryText))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        text.isEmpty ? AppTheme.Colors.separator : Color.red.opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct MacroInputField: View {
    let label: String
    let icon: String
    let color: Color
    @Binding var text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            TextField("0", text: $text)
                .foregroundColor(AppTheme.Colors.primaryText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding(8)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(text.isEmpty ? AppTheme.Colors.separator : color, lineWidth: 1)
                )
        }
    }
}

#Preview {
    AddFoodView()
}
