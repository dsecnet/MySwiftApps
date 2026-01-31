//
//  AddMealPlanView.swift
//  CoreVia
//
//  Yeni qida planı əlavə etmə formu
//

import SwiftUI

struct AddMealPlanView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = MealPlanManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var title: String = ""
    @State private var selectedPlanType: PlanType = .weightLoss
    @State private var selectedStudent: String? = nil
    @State private var dailyCalorieTarget: String = "2000"
    @State private var notes: String = ""
    @State private var meals: [MealPlanItem] = []

    // Add meal sheet
    @State private var showAddMeal: Bool = false
    @State private var newMealName: String = ""
    @State private var newMealCalories: String = ""
    @State private var newMealProtein: String = ""
    @State private var newMealCarbs: String = ""
    @State private var newMealFats: String = ""
    @State private var newMealType: MealType = .breakfast

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: - Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("trainer_plan_title"))
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            TextField(loc.localized("trainer_meal_plan_title_placeholder"), text: $title)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .foregroundColor(Color(UIColor.label))
                        }

                        // MARK: - Plan Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("trainer_plan_type"))
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            HStack(spacing: 10) {
                                ForEach(PlanType.allCases, id: \.self) { type in
                                    PlanTypeButton(
                                        type: type,
                                        isSelected: selectedPlanType == type
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedPlanType = type
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: - Daily Calorie Target
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("trainer_daily_calorie"))
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            HStack {
                                TextField("2000", text: $dailyCalorieTarget)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .foregroundColor(Color(UIColor.label))

                                Text(loc.localized("common_kcal"))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .font(.body)
                            }
                        }

                        // MARK: - Student Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("trainer_assign_student"))
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            ForEach(DemoStudent.demoStudents) { student in
                                StudentSelectRow(
                                    student: student,
                                    isSelected: selectedStudent == student.name
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        if selectedStudent == student.name {
                                            selectedStudent = nil
                                        } else {
                                            selectedStudent = student.name
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: - Meals List
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(loc.localized("trainer_meals"))
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.secondaryLabel))

                                Spacer()

                                Button(action: { showAddMeal = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text(loc.localized("trainer_add_meal"))
                                    }
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                }
                            }

                            if meals.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "fork.knife")
                                            .font(.title2)
                                            .foregroundColor(Color(UIColor.tertiaryLabel))
                                        Text(loc.localized("trainer_no_meals"))
                                            .font(.caption)
                                            .foregroundColor(Color(UIColor.tertiaryLabel))
                                    }
                                    .padding(.vertical, 20)
                                    Spacer()
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            } else {
                                ForEach(meals) { meal in
                                    MealItemRow(meal: meal) {
                                        meals.removeAll { $0.id == meal.id }
                                    }
                                }

                                // Totals
                                HStack {
                                    Text(loc.localized("trainer_total_calories"))
                                        .font(.caption)
                                        .foregroundColor(Color(UIColor.secondaryLabel))

                                    Spacer()

                                    Text("\(meals.reduce(0) { $0 + $1.calories }) \(loc.localized("common_kcal"))")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.orange)
                                }
                                .padding(.horizontal, 8)
                            }
                        }

                        // MARK: - Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(loc.localized("trainer_notes")) (\(loc.localized("common_optional")))")
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            TextEditor(text: $notes)
                                .frame(minHeight: 80)
                                .padding(8)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .foregroundColor(Color(UIColor.label))
                        }

                        // MARK: - Save Button
                        Button(action: savePlan) {
                            Text(loc.localized("common_save"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(title.isEmpty ? Color.gray : Color.orange)
                                .cornerRadius(14)
                        }
                        .disabled(title.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("trainer_new_meal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
            .sheet(isPresented: $showAddMeal) {
                addMealSheet
            }
        }
    }

    // MARK: - Add Meal Sheet
    var addMealSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("trainer_meal_name"))
                            .font(.caption)
                            .foregroundColor(Color(UIColor.secondaryLabel))

                        TextField(loc.localized("trainer_meal_name_placeholder"), text: $newMealName)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(Color(UIColor.label))
                    }

                    // Meal Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("trainer_meal_type"))
                            .font(.caption)
                            .foregroundColor(Color(UIColor.secondaryLabel))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(MealType.allCases, id: \.self) { type in
                                    Button(action: { newMealType = type }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: type.icon)
                                            Text(type.rawValue)
                                        }
                                        .font(.caption)
                                        .foregroundColor(newMealType == type ? .white : type.color)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(newMealType == type ? type.color : type.color.opacity(0.15))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }

                    // Calories
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("food_calories"))
                            .font(.caption)
                            .foregroundColor(Color(UIColor.secondaryLabel))

                        TextField("250", text: $newMealCalories)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(Color(UIColor.label))
                    }

                    // Macros
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("food_protein"))
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            TextField("0", text: $newMealProtein)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .foregroundColor(Color(UIColor.label))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("food_carbs"))
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            TextField("0", text: $newMealCarbs)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .foregroundColor(Color(UIColor.label))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("food_fats"))
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            TextField("0", text: $newMealFats)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .foregroundColor(Color(UIColor.label))
                        }
                    }

                    Button(action: addMeal) {
                        Text(loc.localized("trainer_add_meal"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(newMealName.isEmpty || newMealCalories.isEmpty ? Color.gray : Color.orange)
                            .cornerRadius(14)
                    }
                    .disabled(newMealName.isEmpty || newMealCalories.isEmpty)
                }
                .padding()
            }
            .navigationTitle(loc.localized("trainer_add_meal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_close")) {
                        showAddMeal = false
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }

    // MARK: - Actions
    func addMeal() {
        let meal = MealPlanItem(
            name: newMealName,
            calories: Int(newMealCalories) ?? 0,
            protein: Double(newMealProtein),
            carbs: Double(newMealCarbs),
            fats: Double(newMealFats),
            mealType: newMealType
        )
        meals.append(meal)
        newMealName = ""
        newMealCalories = ""
        newMealProtein = ""
        newMealCarbs = ""
        newMealFats = ""
        newMealType = .breakfast
        showAddMeal = false
    }

    func savePlan() {
        let plan = MealPlan(
            title: title,
            planType: selectedPlanType,
            meals: meals,
            assignedStudentName: selectedStudent,
            dailyCalorieTarget: Int(dailyCalorieTarget) ?? 2000,
            notes: notes.isEmpty ? nil : notes
        )
        manager.addPlan(plan)
        dismiss()
    }
}

// MARK: - Meal Item Row
struct MealItemRow: View {
    let meal: MealPlanItem
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: meal.mealType.icon)
                .foregroundColor(meal.mealType.color)
                .font(.caption)
                .frame(width: 28, height: 28)
                .background(meal.mealType.color.opacity(0.15))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                    .font(.body)
                    .foregroundColor(Color(UIColor.label))

                HStack(spacing: 8) {
                    Text("\(meal.calories) kcal")
                        .font(.caption)
                        .foregroundColor(.orange)

                    if let protein = meal.protein, protein > 0 {
                        Text("P: \(String(format: "%.0f", protein))g")
                            .font(.caption2)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
