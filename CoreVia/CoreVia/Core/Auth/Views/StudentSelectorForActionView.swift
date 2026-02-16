//
//  StudentSelectorForActionView.swift
//  CoreVia
//
//  NEW FILE: Student selector for trainer actions (add food/workout for student)
//

import SwiftUI

enum TrainerActionType {
    case food
    case workout
}

struct StudentSelectorForActionView: View {

    let actionType: TrainerActionType

    @Environment(\.dismiss) var dismiss
    @StateObject private var trainerManager = TrainerManager.shared
    @State private var selectedStudentId: String? = nil
    @State private var showActionView = false
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    if trainerManager.isLoadingStudents {
                        ProgressView()
                            .padding()
                    } else if trainerManager.myStudents.isEmpty {
                        emptyState
                    } else {
                        studentsList
                    }
                }
                .padding()
            }
            .navigationTitle(actionType == .food ? "Tələbə Seçin (Qida)" : "Tələbə Seçin (Hərəkət)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showActionView) {
            if let studentId = selectedStudentId {
                if actionType == .food {
                    AddFoodView(forStudentId: studentId)
                } else {
                    AddWorkoutView(forStudentId: studentId)
                }
            }
        }
        .onAppear {
            if trainerManager.myStudents.isEmpty {
                Task {
                    await trainerManager.fetchMyStudents()
                }
            }
        }
    }

    private var studentsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(trainerManager.myStudents, id: \.id) { student in
                    Button {
                        selectedStudentId = student.id
                        showActionView = true
                    } label: {
                        HStack {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.accent.opacity(0.2))
                                    .frame(width: 50, height: 50)

                                Text(String(student.name.prefix(1)).uppercased())
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.accent)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(student.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primaryText)

                                if let goal = student.goal {
                                    Text(goal)
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                        .padding()
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text("Hələ tələbəniz yoxdur")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text("Tələbələr sizə üzv olduqda burada görünəcək")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
