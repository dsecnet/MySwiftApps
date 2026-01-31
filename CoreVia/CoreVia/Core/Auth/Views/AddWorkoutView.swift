
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
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Title Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_name"))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .font(.subheadline)
                            
                            TextField("", text: $title, prompt: Text("məs: Biceps Training").foregroundColor(Color(UIColor.tertiaryLabel)))
                                .foregroundColor(Color(UIColor.label))
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(title.isEmpty ? Color(UIColor.separator) : Color.red, lineWidth: 1)
                                )
                        }
                        
                        // MARK: - Category Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_category"))
                                .foregroundColor(Color(UIColor.secondaryLabel))
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
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .font(.subheadline)
                            
                            HStack {
                                Button {
                                    if duration > 5 {
                                        duration -= 5
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                }
                                
                                Spacer()
                                
                                Text("\(duration) \(loc.localized("common_min"))")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(Color(UIColor.label))
                                
                                Spacer()
                                
                                Button {
                                    duration += 5
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        
                        // MARK: - Calories (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_calories_optional"))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .font(.subheadline)
                            
                            TextField("", text: $caloriesBurned, prompt: Text("məs: 250").foregroundColor(Color(UIColor.tertiaryLabel)))
                                .foregroundColor(Color(UIColor.label))
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        
                        // MARK: - Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_date"))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .font(.subheadline)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .tint(.red)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        
                        // MARK: - Notes (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("workout_notes"))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .font(.subheadline)
                            
                            ZStack(alignment: .topLeading) {
                                // Placeholder text
                                if notes.isEmpty {
                                    Text(loc.localized("workout_notes_placeholder"))
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                }
                                
                                TextEditor(text: $notes)
                                    .foregroundColor(Color(UIColor.label))
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(height: 100)
                                    .padding(4)
                            }
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(UIColor.separator), lineWidth: 1)
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
                                    colors: [Color.red, Color.red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .red.opacity(0.4), radius: 8)
                        }
                        .disabled(title.isEmpty)
                        .opacity(title.isEmpty ? 0.5 : 1.0)
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("workout_new"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) {
                        dismiss()
                    }
                    .foregroundColor(.red)
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
    
    // MARK: - Save Action
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
                    .foregroundColor(isSelected ? .white : Color(UIColor.secondaryLabel))
                
                Text(category.localizedName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : Color(UIColor.secondaryLabel))
            }
            .frame(width: 80, height: 80)
            .background(
                isSelected ?
                LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [Color(UIColor.secondarySystemBackground), Color(UIColor.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.red : Color(UIColor.separator), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    AddWorkoutView()
}
