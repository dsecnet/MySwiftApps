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

    // NEW: Real API data manager
    @StateObject private var trainerManager = TrainerManager.shared

    // Data source - Use real API data if available, fallback to demo
    var students: [DemoStudent] {
        // Convert UserResponse to DemoStudent for compatibility
        if !trainerManager.myStudents.isEmpty {
            return trainerManager.myStudents.map { user in
                DemoStudent(
                    id: user.id,
                    name: user.name,
                    progress: 0.65,        // ✅ 3-cü - DÜZ!
                    avatarEmoji: "👤",     // ✅ 4-cü - DÜZ!
                    age: user.age ?? 25,
                    goal: user.goal ?? "Sağlam yaşam"
                )
            }
        }
        // Fallback to demo data
        return DemoStudent.demoStudents
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
                                    withAnimation(.spring()) {
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
            AddTrainingPlanView()
        }
        .sheet(isPresented: $showAddMealPlan) {
            AddMealPlanView()
        }
        .onAppear {
            // NEW: Fetch real students from backend
            Task {
                await trainerManager.fetchMyStudents()
            }
            TrainingPlanManager.shared.loadPlans()
            MealPlanManager.shared.loadPlans()
        }
        .overlay(alignment: .top) {
            // NEW: Show loading indicator while fetching
            if trainerManager.isLoadingStudents {
                ProgressView()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.Colors.cardBackground)
                            .shadow(radius: 4)
                    )
                    .padding(.top, 100)
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
        .animation(.spring(), value: isPressed)
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

    @State private var showAddTrainingPlan: Bool = false
    @State private var showAddMealPlan: Bool = false
    @State private var showAddTask: Bool = false
    @State private var newTaskTitle: String = ""
    @State private var newTaskDescription: String = ""
    @State private var newTaskType: StudentTaskType = .workout

    // Task data (lokal state — backend olmadığı üçün)
    @State private var tasks: [StudentTask] = []
    @State private var tasksInitialized: Bool = false

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
                        taskSection
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
            .sheet(isPresented: $showAddTrainingPlan) {
                AddTrainingPlanView()
            }
            .sheet(isPresented: $showAddMealPlan) {
                AddMealPlanView()
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

    // MARK: - Task Section (Trainer → Tələbəyə tapşırıq)
    private var taskSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loc.localized("student_tasks_title"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                Button {
                    showAddTask = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        Text(loc.localized("student_tasks_add"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }

            if tasks.isEmpty {
                HStack {
                    Image(systemName: "checklist")
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text(loc.localized("student_tasks_empty"))
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Spacer()
                }
                .padding()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
            } else {
                VStack(spacing: 10) {
                    ForEach(tasks) { task in
                        StudentTaskCard(
                            title: task.title,
                            type: task.type,
                            isCompleted: task.isCompleted
                        ) {
                            toggleTask(task.id)
                        }
                    }
                }
            }
        }
        .onAppear { initializeTasksIfNeeded() }
        .sheet(isPresented: $showAddTask) {
            AddStudentTaskSheet(
                studentName: student.name,
                taskTitle: $newTaskTitle,
                taskDescription: $newTaskDescription,
                taskType: $newTaskType
            ) {
                // Task əlavə et
                let newTask = StudentTask(
                    title: newTaskTitle,
                    type: newTaskType,
                    isCompleted: false
                )
                tasks.append(newTask)
                saveTasks()
                showAddTask = false
                newTaskTitle = ""
                newTaskDescription = ""
            }
        }
    }

    private func initializeTasksIfNeeded() {
        guard !tasksInitialized else { return }
        tasksInitialized = true
        tasks = StudentTask.load(forStudentId: student.id)
        if tasks.isEmpty {
            // Default tapşırıqlar
            tasks = [
                StudentTask(title: "Gündəlik 30 dəq məşq", type: .workout, isCompleted: false),
                StudentTask(title: "2L su iç", type: .nutrition, isCompleted: false),
                StudentTask(title: "7 saat yuxu", type: .lifestyle, isCompleted: false)
            ]
            saveTasks()
        }
    }

    private func toggleTask(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            withAnimation(.spring(response: 0.3)) {
                tasks[index].isCompleted.toggle()
            }
            saveTasks()
        }
    }

    private func saveTasks() {
        StudentTask.save(tasks, forStudentId: student.id)
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

// MARK: - Student Task Model (lokal persist)
struct StudentTask: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var type: StudentTaskType
    var isCompleted: Bool

    private static func storageKey(forStudentId studentId: String) -> String {
        "student_tasks_\(studentId)"
    }

    static func load(forStudentId studentId: String) -> [StudentTask] {
        guard let data = UserDefaults.standard.data(forKey: storageKey(forStudentId: studentId)),
              let tasks = try? JSONDecoder().decode([StudentTask].self, from: data) else {
            return []
        }
        return tasks
    }

    static func save(_ tasks: [StudentTask], forStudentId studentId: String) {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: storageKey(forStudentId: studentId))
        }
    }
}

// MARK: - Student Task Type
enum StudentTaskType: String, CaseIterable, Codable {
    case workout = "workout"
    case nutrition = "nutrition"
    case lifestyle = "lifestyle"

    var icon: String {
        switch self {
        case .workout: return "figure.strengthtraining.traditional"
        case .nutrition: return "fork.knife"
        case .lifestyle: return "moon.stars.fill"
        }
    }

    var color: Color {
        switch self {
        case .workout: return AppTheme.Colors.accent
        case .nutrition: return .green
        case .lifestyle: return .purple
        }
    }

    var localizedName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .workout: return loc.localized("task_type_workout")
        case .nutrition: return loc.localized("task_type_nutrition")
        case .lifestyle: return loc.localized("task_type_lifestyle")
        }
    }
}

// MARK: - Student Task Card
struct StudentTaskCard: View {
    let title: String
    let type: StudentTaskType
    let isCompleted: Bool
    var onToggle: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Button {
                onToggle?()
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isCompleted ? AppTheme.Colors.success : AppTheme.Colors.separator)
            }

            Image(systemName: type.icon)
                .font(.system(size: 16))
                .foregroundColor(type.color)
                .frame(width: 32, height: 32)
                .background(type.color.opacity(0.1))
                .cornerRadius(8)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isCompleted ? AppTheme.Colors.secondaryText : AppTheme.Colors.primaryText)
                .strikethrough(isCompleted)

            Spacer()

            Text(type.localizedName)
                .font(.system(size: 11))
                .foregroundColor(type.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(type.color.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Add Student Task Sheet
struct AddStudentTaskSheet: View {
    let studentName: String
    @Binding var taskTitle: String
    @Binding var taskDescription: String
    @Binding var taskType: StudentTaskType
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Kimin üçün
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .foregroundColor(AppTheme.Colors.accent)
                            Text("\(studentName) \(loc.localized("student_tasks_for"))")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                            Spacer()
                        }
                        .padding()
                        .background(AppTheme.Colors.accent.opacity(0.1))
                        .cornerRadius(12)

                        // Task növü
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("student_tasks_type"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            HStack(spacing: 10) {
                                ForEach(StudentTaskType.allCases, id: \.self) { type in
                                    Button {
                                        taskType = type
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: type.icon)
                                                .font(.system(size: 20))
                                            Text(type.localizedName)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(taskType == type ? .white : type.color)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(taskType == type ? type.color : type.color.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }

                        // Task başlığı
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("student_tasks_name"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            TextField(loc.localized("student_tasks_name_placeholder"), text: $taskTitle)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.Colors.separator, lineWidth: 1)
                                )
                        }

                        // Əlavə qeyd
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("student_tasks_description"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            TextEditor(text: $taskDescription)
                                .frame(height: 80)
                                .padding(8)
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.Colors.separator, lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("student_tasks_new"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) { dismiss() }
                        .foregroundColor(AppTheme.Colors.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.localized("common_save")) { onSave() }
                        .foregroundColor(AppTheme.Colors.accent)
                        .fontWeight(.bold)
                        .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}

// #Preview { // iOS 17+ only
//     MyStudentsView()
// }
