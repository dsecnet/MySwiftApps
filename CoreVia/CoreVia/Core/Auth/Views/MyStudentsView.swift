//
//  MyStudentsView.swift
//  CoreVia
//
//  Müəllimin tələbə siyahısı - Tab 3 (Trainer mode)
//

import SwiftUI

// MARK: - My Students View
struct MyStudentsView: View {

    @State private var searchText: String = ""
    @State private var selectedStudent: DemoStudent? = nil
    @State private var showAddTrainingPlan: Bool = false
    @State private var showAddMealPlan: Bool = false
    @ObservedObject private var loc = LocalizationManager.shared

    // Data source
    var students: [DemoStudent] {
        DemoStudent.demoStudents
    }

    // Filtered students based on search
    var filteredStudents: [DemoStudent] {
        if searchText.isEmpty {
            return students
        }
        return students.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.goal.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Average progress across all students
    var averageProgress: Int {
        guard !students.isEmpty else { return 0 }
        let total = students.reduce(0.0) { $0 + $1.progress }
        return Int((total / Double(students.count)) * 100)
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Search
                searchBar
                    .padding(.top, 8)

                // Student List
                if filteredStudents.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredStudents) { student in
                                MyStudentCard(student: student) {
                                    withAnimation(.spring(response: 0.4)) {
                                        selectedStudent = student
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(item: $selectedStudent) { student in
            StudentDetailView(student: student)
        }
        .sheet(isPresented: $showAddTrainingPlan) {
            if let student = selectedStudent {
                AddTrainingPlanView(preSelectedStudent: student)
            }
        }
        .sheet(isPresented: $showAddMealPlan) {
            if let student = selectedStudent {
                AddMealPlanView(preSelectedStudent: student)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("my_students_title"))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 16) {
                // Total students badge
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(students.count)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Text(loc.localized("my_students_total"))
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.Colors.accent.opacity(0.1))
                .cornerRadius(12)

                // Avg progress badge
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.success)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(averageProgress)%")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Text(loc.localized("my_students_avg_progress"))
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.Colors.success.opacity(0.1))
                .cornerRadius(12)

                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondaryText)

            TextField(loc.localized("my_students_search"), text: $searchText)
                .foregroundColor(AppTheme.Colors.primaryText)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(loc.localized("my_students_no_results"))
                .font(.headline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(loc.localized("my_students_change_search"))
                .font(.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - My Student Card
struct MyStudentCard: View {
    let student: DemoStudent
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [student.progressColor.opacity(0.3), student.progressColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Text(student.avatarEmoji)
                        .font(.system(size: 30))
                }
                .shadow(color: student.progressColor.opacity(0.3), radius: 8, x: 0, y: 4)

                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(student.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(student.goal)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    HStack(spacing: 12) {
                        // Age
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text("\(student.age)")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(AppTheme.Colors.tertiaryText)

                        // Progress
                        HStack(spacing: 6) {
                            ProgressView(value: student.progress)
                                .tint(student.progressColor)
                                .frame(width: 50)

                            Text("\(student.progressPercent)%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(student.progressColor)
                        }
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(student.progressColor)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(student.progressColor.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Student Detail View
struct StudentDetailView: View {
    let student: DemoStudent
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var loc = LocalizationManager.shared
    @StateObject private var trainingPlanManager = TrainingPlanManager.shared
    @StateObject private var mealPlanManager = MealPlanManager.shared

    // Mock training statistics (seeded by student id for consistency)
    private var workoutsThisWeek: Int {
        abs(student.id.hashValue % 4) + 2  // 2-5
    }
    private var totalWorkouts: Int {
        abs(student.id.hashValue % 60) + 20  // 20-80
    }
    private var caloriesBurned: Int {
        (abs(student.id.hashValue % 100) + 50) * 100  // 5000-15000
    }

    // Assigned plans for this student
    var assignedTrainingPlans: [TrainingPlan] {
        trainingPlanManager.plansForStudent(student.name)
    }

    var assignedMealPlans: [MealPlan] {
        mealPlanManager.plansForStudent(student.name)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        studentHeader
                        progressOverview
                        trainingStats
                        assignedPlansSection
                        createPlanButtons
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("student_detail_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }
        }
    }

    // MARK: - Student Header
    private var studentHeader: some View {
        VStack(spacing: 16) {
            // Large Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [student.progressColor.opacity(0.3), student.progressColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Text(student.avatarEmoji)
                    .font(.system(size: 60))
            }
            .shadow(color: student.progressColor.opacity(0.4), radius: 20, x: 0, y: 10)

            // Name
            Text(student.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            // Age & Goal badges
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                    Text("\(student.age) \(loc.localized("my_students_age"))")
                        .font(.system(size: 14))
                }
                .foregroundColor(AppTheme.Colors.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.Colors.accent.opacity(0.1))
                .cornerRadius(20)

                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.system(size: 13))
                    Text(student.goal)
                        .font(.system(size: 14))
                }
                .foregroundColor(AppTheme.Colors.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.Colors.accent.opacity(0.1))
                .cornerRadius(20)
            }
        }
    }

    // MARK: - Progress Overview
    private var progressOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("student_detail_progress_overview"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 24) {
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.separator, lineWidth: 10)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: student.progress)
                        .stroke(
                            student.progressColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(student.progressPercent)%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(student.progressColor)
                        Text(loc.localized("my_students_progress"))
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }

                Spacer()

                // Info column
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text(student.goal)
                            .font(.system(size: 14))
                    } icon: {
                        Image(systemName: "target")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(AppTheme.Colors.secondaryText)

                    Label {
                        Text("\(student.age) \(loc.localized("common_year"))")
                            .font(.system(size: 14))
                    } icon: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(AppTheme.Colors.secondaryText)

                    Label {
                        Text(student.name)
                            .font(.system(size: 14))
                    } icon: {
                        Image(systemName: "person.text.rectangle")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(16)
        }
    }

    // MARK: - Training Statistics
    private var trainingStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("student_detail_training_stats"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 12) {
                StudentDetailStatCard(
                    icon: "flame.fill",
                    value: "\(workoutsThisWeek)",
                    label: loc.localized("student_detail_workouts_week"),
                    color: AppTheme.Colors.accent
                )
                StudentDetailStatCard(
                    icon: "figure.strengthtraining.traditional",
                    value: "\(totalWorkouts)",
                    label: loc.localized("student_detail_total_workouts"),
                    color: AppTheme.Colors.accent
                )
                StudentDetailStatCard(
                    icon: "bolt.fill",
                    value: "\(caloriesBurned)",
                    label: loc.localized("student_detail_calories_burned"),
                    color: AppTheme.Colors.accent
                )
            }
        }
    }

    // MARK: - Assigned Plans Section
    private var assignedPlansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("student_detail_assigned_plans"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            if assignedTrainingPlans.isEmpty && assignedMealPlans.isEmpty {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text(loc.localized("student_detail_no_plans"))
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
            } else {
                // Training plans
                ForEach(assignedTrainingPlans) { plan in
                    AssignedPlanRow(
                        title: plan.title,
                        type: plan.planType.localizedName,
                        icon: "figure.strengthtraining.traditional",
                        color: plan.planType.color
                    )
                }

                // Meal plans
                ForEach(assignedMealPlans) { plan in
                    AssignedPlanRow(
                        title: plan.title,
                        type: plan.planType.localizedName,
                        icon: "fork.knife",
                        color: plan.planType.color
                    )
                }
            }
        }
    }

    // MARK: - Create Plan Buttons
    private var createPlanButtons: some View {
        VStack(spacing: 12) {
            // Create Training Plan
            Button {
                showAddTrainingPlan = true
            } label: {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                    Text(loc.localized("student_detail_create_training"))
                        .font(.system(size: 16, weight: .bold))
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

            // Create Meal Plan
            Button {
                showAddMealPlan = true
            } label: {
                HStack {
                    Image(systemName: "fork.knife")
                    Text(loc.localized("student_detail_create_meal"))
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(AppTheme.Colors.accent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.accent, lineWidth: 2)
                )
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Student Detail Stat Card
struct StudentDetailStatCard: View {
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
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Assigned Plan Row
struct AssignedPlanRow: View {
    let title: String
    let type: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(type)
                    .font(.system(size: 13))
                    .foregroundColor(color)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.Colors.success)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    MyStudentsView()
}
