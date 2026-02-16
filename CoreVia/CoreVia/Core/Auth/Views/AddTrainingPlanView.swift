//
//  AddTrainingPlanView.swift
//  CoreVia
//

import SwiftUI

struct CreateTrainingPlanRequest: Encodable {
    let title: String
    let plan_type: String
    let student_id: String
    let notes: String
}

struct AddTrainingPlanView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = TrainingPlanManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var title: String = ""
    @State private var selectedPlanType: PlanType = .weightLoss
    @State private var selectedStudent: String? = nil
    @State private var notes: String = ""
    @State private var workouts: [PlanWorkout] = []

    @State private var showAddWorkout: Bool = false
    @State private var newWorkoutName: String = ""
    @State private var newWorkoutSets: String = "3"
    @State private var newWorkoutReps: String = "12"
    @State private var newWorkoutDuration: String = ""

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

                            TextField(loc.localized("trainer_plan_title_placeholder"), text: $title)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .foregroundColor(Color(UIColor.label))
                        }

                        // MARK: - Plan Type Selection
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
                                        withAnimation(.spring()) {
                                            selectedPlanType = type
                                        }
                                    }
                                }
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
                                    withAnimation(.spring()) {
                                        if selectedStudent == student.name {
                                            selectedStudent = nil
                                        } else {
                                            selectedStudent = student.name
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: - Workouts List
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(loc.localized("trainer_exercises"))
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.secondaryLabel))

                                Spacer()

                                Button(action: { showAddWorkout = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text(loc.localized("trainer_add_exercise"))
                                    }
                                    .font(.caption)
                                    .foregroundColor(AppTheme.Colors.accent)
                                }
                            }

                            if workouts.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "dumbbell")
                                            .font(.title2)
                                            .foregroundColor(Color(UIColor.tertiaryLabel))
                                        Text(loc.localized("trainer_no_exercises"))
                                            .font(.caption)
                                            .foregroundColor(Color(UIColor.tertiaryLabel))
                                    }
                                    .padding(.vertical, 20)
                                    Spacer()
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            } else {
                                ForEach(workouts) { workout in
                                    ExerciseRow(workout: workout) {
                                        workouts.removeAll { $0.id == workout.id }
                                    }
                                }
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
                                .background(title.isEmpty ? Color.gray : AppTheme.Colors.accent)
                                .cornerRadius(14)
                        }
                        .disabled(title.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("trainer_new_training"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .sheet(isPresented: $showAddWorkout) {
                addWorkoutSheet
            }
        }
    }

    // MARK: - Add Workout Sheet
    var addWorkoutSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(loc.localized("trainer_exercise_name"))
                        .font(.caption)
                        .foregroundColor(Color(UIColor.secondaryLabel))

                    TextField(loc.localized("trainer_exercise_name_placeholder"), text: $newWorkoutName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .foregroundColor(Color(UIColor.label))
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("trainer_sets"))
                            .font(.caption)
                            .foregroundColor(Color(UIColor.secondaryLabel))

                        TextField("3", text: $newWorkoutSets)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(Color(UIColor.label))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.localized("trainer_reps"))
                            .font(.caption)
                            .foregroundColor(Color(UIColor.secondaryLabel))

                        TextField("12", text: $newWorkoutReps)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(Color(UIColor.label))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(loc.localized("common_min"))")
                            .font(.caption)
                            .foregroundColor(Color(UIColor.secondaryLabel))

                        TextField("-", text: $newWorkoutDuration)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(Color(UIColor.label))
                    }
                }

                Button(action: addWorkout) {
                    Text(loc.localized("trainer_add_exercise"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(newWorkoutName.isEmpty ? Color.gray : AppTheme.Colors.accent)
                        .cornerRadius(14)
                }
                .disabled(newWorkoutName.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle(loc.localized("trainer_add_exercise"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_close")) {
                        showAddWorkout = false
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
    }

    // MARK: - Actions
    func addWorkout() {
        let sets = max(1, min(100, Int(newWorkoutSets) ?? 3))
        let reps = max(1, min(1000, Int(newWorkoutReps) ?? 12))
        var dur: Int? = nil
        if let d = Int(newWorkoutDuration), d > 0 { dur = min(d, 1440) }

        let workout = PlanWorkout(
            name: newWorkoutName.trimmingCharacters(in: .whitespaces),
            sets: sets,
            reps: reps,
            duration: dur
        )
        workouts.append(workout)
        newWorkoutName = ""
        newWorkoutSets = "3"
        newWorkoutReps = "12"
        newWorkoutDuration = ""
        showAddWorkout = false
    }

    func savePlan() {
        let plan = TrainingPlan(
            title: title,
            planType: selectedPlanType,
            workouts: workouts,
            assignedStudentName: selectedStudent,
            notes: notes.isEmpty ? nil : notes
        )
        manager.addPlan(plan)

        // NEW: Save to backend if student is selected
        if let studentName = selectedStudent, !studentName.isEmpty {
            Task {
                await saveToBackend(plan: plan, studentName: studentName)
            }
        }
        struct CreateTrainingPlanRequest: Encodable {
            let title: String
            let plan_type: String
            let student_id: String
            let notes: String
        }

        dismiss()
    }

    // NEW: Backend API integration
    @MainActor
    private func saveToBackend(plan: TrainingPlan, studentName: String) async {
        // Find student ID from TrainerManager
        let students = TrainerManager.shared.myStudents
        guard let student = students.first(where: { $0.name == studentName }) else {
            print("⚠️ Student not found: \(studentName)")
            return
        }

        do {
            let endpoint = "/api/v1/training-plans"
            let body = CreateTrainingPlanRequest(
                title: plan.title,
                plan_type: plan.planType.rawValue,
                student_id: student.id,
                notes: plan.notes ?? ""
            )

            let _: [String: String] = try await APIService.shared.request(
                endpoint: endpoint,
                method: "POST",
                body: body
            )
            print("✅ Training plan saved to backend for student: \(studentName)")
        } catch {
            print("❌ Failed to save training plan: \(error.localizedDescription)")
        }
    }
}

// MARK: - Plan Type Button
struct PlanTypeButton: View {
    let type: PlanType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.title3)
                Text(type.localizedName)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .white : type.color)
            .background(isSelected ? type.color : type.color.opacity(0.15))
            .cornerRadius(12)
        }
    }
}

// MARK: - Student Select Row
struct StudentSelectRow: View {
    let student: DemoStudent
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(student.avatarEmoji)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(student.name)
                        .font(.body)
                        .foregroundColor(Color(UIColor.label))

                    Text(student.goal)
                        .font(.caption)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? AppTheme.Colors.accent : Color(UIColor.tertiaryLabel))
                    .font(.title3)
            }
            .padding()
            .background(isSelected ? AppTheme.Colors.accent.opacity(0.08) : Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.Colors.accent.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Exercise Row
struct ExerciseRow: View {
    let workout: PlanWorkout
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "dumbbell.fill")
                .foregroundColor(AppTheme.Colors.accent)
                .font(.caption)
                .frame(width: 28, height: 28)
                .background(AppTheme.Colors.accent.opacity(0.15))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name)
                    .font(.body)
                    .foregroundColor(Color(UIColor.label))

                Text("\(workout.sets) set × \(workout.reps) rep")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))
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
