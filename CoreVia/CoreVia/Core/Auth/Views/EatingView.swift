
import SwiftUI

struct FoodView: View {
    
    @StateObject private var foodManager = FoodManager.shared
    @State private var showAddFood = false
    @State private var showEditGoal = false
    @State private var selectedEntry: FoodEntry? = nil
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    dailyProgressSection
                    macroBreakdownSection
                    
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        mealSection(for: mealType)
                    }
                    
                    addButton
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAddFood) {
            AddFoodView()
        }
        .sheet(isPresented: $showEditGoal) {
            EditGoalView()
        }
        .sheet(item: $selectedEntry) { entry in
            FoodDetailView(entry: entry)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Qida Tracking")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text("Bugünkü qidalanmanızı izləyin")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Daily Progress Section
    private var dailyProgressSection: some View {
        VStack(spacing: 16) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.separator, lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: min(foodManager.todayProgress, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: progressGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: foodManager.todayProgress)
                
                VStack(spacing: 4) {
                    Text("\(foodManager.todayTotalCalories)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    
                    Text("/ \(foodManager.dailyCalorieGoal)")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Text("kcal")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }
            }
            .padding(.vertical, 20)
            
            // Stats Row
            HStack(spacing: 20) {
                CalorieStat(
                    icon: "flame.fill",
                    value: "\(foodManager.remainingCalories)",
                    label: "Qalıb",
                    color: .green
                )
                
                CalorieStat(
                    icon: "target",
                    value: "\(Int(foodManager.todayProgress * 100))%",
                    label: "Tamamlandı",
                    color: .blue
                )
                
                CalorieStat(
                    icon: "fork.knife",
                    value: "\(foodManager.todayEntries.count)",
                    label: "Öğün",
                    color: .orange
                )
            }
            
            // Edit Goal Button
            Button {
                showEditGoal = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.circle.fill")
                    Text("Hədəfi Dəyiş")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Macro Breakdown Section
    private var macroBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Makro Qırılması")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 12) {
                MacroCard(
                    icon: "💪",
                    label: "Protein",
                    value: "\(Int(foodManager.todayTotalProtein))q",
                    color: .blue
                )
                
                MacroCard(
                    icon: "🍞",
                    label: "Karb",
                    value: "\(Int(foodManager.todayTotalCarbs))q",
                    color: .orange
                )
                
                MacroCard(
                    icon: "🥑",
                    label: "Yağ",
                    value: "\(Int(foodManager.todayTotalFats))q",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Meal Section
    private func mealSection(for mealType: MealType) -> some View {
        let entries = foodManager.entriesForMealType(mealType)
        let totalCalories = foodManager.caloriesForMealType(mealType)
        
        return VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: mealType.icon)
                    .foregroundColor(mealType.color)
                
                Text(mealType.rawValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Spacer()
                
                Text("\(totalCalories) kcal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(mealType.color)
            }
            
            // Entries or Empty State
            if entries.isEmpty {
                Button {
                    showAddFood = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(mealType.color)
                        
                        Text("Qida əlavə et")
                            .foregroundColor(AppTheme.Colors.primaryText)
                        
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(mealType.color.opacity(0.3), lineWidth: 1)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(entries) { entry in
                        FoodEntryRow(entry: entry) {
                            selectedEntry = entry
                        } onDelete: {
                            foodManager.deleteEntry(entry)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Add Button
    private var addButton: some View {
        Button {
            showAddFood = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                
                Text("Yeni Qida Əlavə Et")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.green, .green.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .green.opacity(0.3), radius: 8)
        }
    }
    
    // MARK: - Helpers
    private var progressGradientColors: [Color] {
        if foodManager.todayProgress < 0.5 {
            return [.green, .yellow]
        } else if foodManager.todayProgress < 1.0 {
            return [.yellow, .orange]
        } else {
            return [.orange, .red]
        }
    }
}

// MARK: - Components

struct CalorieStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MacroCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 28))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 2)
        )
    }
}

struct FoodEntryRow: View {
    let entry: FoodEntry
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(entry.mealType.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: entry.mealType.icon)
                        .font(.system(size: 16))
                        .foregroundColor(entry.mealType.color)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    
                    if let protein = entry.protein, let carbs = entry.carbs, let fats = entry.fats {
                        Text("P:\(Int(protein)) C:\(Int(carbs)) F:\(Int(fats))")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    
                    Text(entry.formattedDate)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }
                
                Spacer()
                
                // Calories
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(entry.calories)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(entry.mealType.color)
                    
                    Text("kcal")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
}

// MARK: - Edit Goal View
struct EditGoalView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var foodManager = FoodManager.shared
    @State private var goalText: String
    
    init() {
        _goalText = State(initialValue: "\(FoodManager.shared.dailyCalorieGoal)")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Günlük kalori hədəfinizi təyin edin")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    TextField("", text: $goalText)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(12)
                    
                    Text("kcal")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    // Quick selections
                    VStack(spacing: 12) {
                        Text("Sürətli seçim:")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        
                        HStack(spacing: 12) {
                            ForEach([1500, 2000, 2500, 3000], id: \.self) { goal in
                                Button {
                                    goalText = "\(goal)"
                                } label: {
                                    Text("\(goal)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(goalText == "\(goal)" ? .white : AppTheme.Colors.primaryText)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(goalText == "\(goal)" ? Color.green : AppTheme.Colors.secondaryBackground)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Kalori Hədəfi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Saxla") {
                        if let goal = Int(goalText), goal > 0 {
                            foodManager.updateDailyGoal(goal)
                            dismiss()
                        }
                    }
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Food Detail View
struct FoodDetailView: View {
    let entry: FoodEntry
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(entry.mealType.color.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: entry.mealType.icon)
                                .font(.system(size: 40))
                                .foregroundColor(entry.mealType.color)
                        }
                        
                        // Name
                        Text(entry.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        
                        // Calories
                        VStack(spacing: 4) {
                            Text("\(entry.calories)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(entry.mealType.color)
                            
                            Text("kalori")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                        
                        // Macros
                        if let protein = entry.protein, let carbs = entry.carbs, let fats = entry.fats {
                            HStack(spacing: 12) {
                                DetailMacroCard(icon: "💪", label: "Protein", value: "\(Int(protein))q", color: .blue)
                                DetailMacroCard(icon: "🍞", label: "Karb", value: "\(Int(carbs))q", color: .orange)
                                DetailMacroCard(icon: "🥑", label: "Yağ", value: "\(Int(fats))q", color: .green)
                            }
                        }
                        
                        // Notes
                        if let notes = entry.notes {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Qeydlər")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                
                                Text(notes)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                        }
                        
                        // Meta info
                        VStack(spacing: 8) {
                            InfoRow(icon: "calendar", label: "Öğün", value: entry.mealType.rawValue)
                            InfoRow(icon: "clock", label: "Vaxt", value: entry.formattedDate)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Detallar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bağla") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct DetailMacroCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
            
            Text(label)
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            Spacer()
            
            Text(value)
                .foregroundColor(AppTheme.Colors.primaryText)
                .fontWeight(.semibold)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    FoodView()
}
