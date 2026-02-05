
import SwiftUI

struct AddWorkoutView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = WorkoutManager.shared
    
    // MARK: - Form State
    @State private var title: String = ""
    @State private var selectedCategory: WorkoutCategory = .strength
    @State private var duration: Int = 30
    @State private var caloriesBurned: String = ""
    @State private var notes: String = ""
    @State private var selectedDate: Date = Date()
    
    @State private var showSuccessAlert: Bool = false
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // MARK: - Title Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_name"))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .font(.subheadline)

                            TextField("", text: $title, prompt: Text("məs: Biceps Training").foregroundColor(AppTheme.Colors.tertiaryText))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(title.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent, lineWidth: 1)
                                )
                        }
                        
                        // MARK: - Category Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_category"))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .font(.subheadline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(WorkoutCategory.allCases, id: \.self) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedCategory = category
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Duration Stepper
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_duration"))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .font(.subheadline)

                            HStack {
                                Button {
                                    if duration > 5 {
                                        duration -= 5
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.Colors.accent)
                                }

                                Spacer()

                                Text("\(duration) \(loc.localized("common_min"))")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(AppTheme.Colors.primaryText)

                                Spacer()

                                Button {
                                    if duration < 1440 { duration += 5 }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(duration >= 1440 ? .gray : AppTheme.Colors.accent)
                                }
                            }
                            .padding()
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                        }
                        
                        // MARK: - Calories (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_calories_optional"))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .font(.subheadline)

                            TextField("", text: $caloriesBurned, prompt: Text("məs: 250").foregroundColor(AppTheme.Colors.tertiaryText))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                        }
                        
                        // MARK: - Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_date"))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .font(.subheadline)

                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .tint(AppTheme.Colors.accent)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                        }
                        
                        // MARK: - Notes (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_notes"))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .font(.subheadline)

                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text(loc.localized("workout_notes_placeholder"))
                                        .foregroundColor(AppTheme.Colors.tertiaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                }

                                TextEditor(text: $notes)
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(height: 100)
                                    .padding(4)
                            }
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.Colors.separator, lineWidth: 1)
                            )
                        }
                        
                        // MARK: - Save Button
                        Button {
                            saveWorkout()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text(loc.localized("workout_save"))
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8)
                        }
                        .disabled(!isWorkoutFormValid)
                        .opacity(isWorkoutFormValid ? 1.0 : 0.5)
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("workout_new"))
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: caloriesBurned) { _, val in
                caloriesBurned = val.filter { $0.isNumber }
                if let n = Int(caloriesBurned), n > 10000 { caloriesBurned = "10000" }
            }
            .onChange(of: notes) { _, val in
                if val.count > 1000 { notes = String(val.prefix(1000)) }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .alert("\(loc.localized("common_success")) ✅", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(loc.localized("workout_added"))
            }
        }
    }
    
    private var isWorkoutFormValid: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= 200 else { return false }
        guard duration >= 1, duration <= 1440 else { return false }
        if let cal = Int(caloriesBurned), (cal < 0 || cal > 10000) { return false }
        return true
    }

    private func saveWorkout() {
        let workout = Workout(
            title: title,
            category: selectedCategory,
            duration: duration,
            caloriesBurned: Int(caloriesBurned),
            notes: notes.isEmpty ? nil : notes,
            date: selectedDate,
            isCompleted: false
        )
        
        manager.addWorkout(workout)
        
        withAnimation {
            showSuccessAlert = true
        }
    }
}

// MARK: - Category Button Component
struct CategoryButton: View {
    let category: WorkoutCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)

                Text(category.localizedName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
            }
            .frame(width: 80, height: 80)
            .background(
                isSelected ?
                LinearGradient(colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [AppTheme.Colors.secondaryBackground, AppTheme.Colors.secondaryBackground], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.separator, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    AddWorkoutView()
}
