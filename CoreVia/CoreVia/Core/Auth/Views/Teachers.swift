//
//  TeachersView.swift
//  CoreVia
//
//  İNTERAKTİV VƏ RESPONSİV - Müəllimlər Səhifəsi
//

import SwiftUI

struct TeachersView: View {
    
    @State private var searchText: String = ""
    @State private var selectedCategory: TeacherCategory = .all
    @State private var selectedTeacher: Teacher? = nil
    @State private var showTeacherDetail: Bool = false
    
    // Demo data
    let teachers: [Teacher] = [
        Teacher(
            name: "Elvin Məmmədov",
            specialty: "Fitness Coach",
            category: .fitness,
            rating: 4.9,
            students: 156,
            experience: "8 il təcrübə",
            bio: "Professional bodybuilding və güc məşqləri üzrə mütəxəssis",
            imageIcon: "💪"
        ),
        Teacher(
            name: "Aysel Quliyeva",
            specialty: "Nutrition Specialist",
            category: .nutrition,
            rating: 4.8,
            students: 203,
            experience: "6 il təcrübə",
            bio: "Qidalanma və dieta planlaşdırması üzrə ekspert",
            imageIcon: "🥗"
        ),
        Teacher(
            name: "Rauf Əliyev",
            specialty: "Strength Trainer",
            category: .strength,
            rating: 5.0,
            students: 98,
            experience: "10 il təcrübə",
            bio: "Güc məşqləri və atletik performans təlimçisi",
            imageIcon: "🏋️"
        ),
        Teacher(
            name: "Leyla Həsənova",
            specialty: "Yoga Instructor",
            category: .yoga,
            rating: 4.7,
            students: 187,
            experience: "5 il təcrübə",
            bio: "Yoga və çeviklik məşqləri mütəxəssisi",
            imageIcon: "🧘"
        ),
        Teacher(
            name: "Kamran Səlimov",
            specialty: "Cardio Expert",
            category: .cardio,
            rating: 4.6,
            students: 134,
            experience: "7 il təcrübə",
            bio: "Kardio və dözümlülük məşqləri təlimçisi",
            imageIcon: "🏃"
        )
    ]
    
    var filteredTeachers: [Teacher] {
        var result = teachers
        
        // Category filter
        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.specialty.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                searchBar
                categoryFilter
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredTeachers) { teacher in
                            TeacherCard(teacher: teacher) {
                                withAnimation(.spring(response: 0.4)) {
                                    selectedTeacher = teacher
                                    showTeacherDetail = true
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                if filteredTeachers.isEmpty {
                    emptyState
                }
            }
        }
        .sheet(item: $selectedTeacher) { teacher in
            TeacherDetailView(teacher: teacher)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Müəllimlər")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: 16) {
                StatBadge(icon: "person.2.fill", value: "\(teachers.count)", label: "Müəllim")
                StatBadge(icon: "star.fill", value: "4.8", label: "Orta Reytinq")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            TextField("Müəllim axtar...", text: $searchText)
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
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TeacherCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.tertiaryText)
            
            Text("Müəllim tapılmadı")
                .font(.headline)
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            Text("Axtarış kriteriyalarını dəyişin")
                .font(.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Teacher Model
struct Teacher: Identifiable {
    let id = UUID()
    let name: String
    let specialty: String
    let category: TeacherCategory
    let rating: Double
    let students: Int
    let experience: String
    let bio: String
    let imageIcon: String
}

enum TeacherCategory: String, CaseIterable {
    case all = "Hamısı"
    case fitness = "Fitness"
    case strength = "Güc"
    case cardio = "Kardio"
    case yoga = "Yoga"
    case nutrition = "Qidalanma"
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .fitness: return "figure.strengthtraining.traditional"
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .yoga: return "figure.yoga"
        case .nutrition: return "fork.knife"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .fitness: return .red
        case .strength: return .orange
        case .cardio: return .pink
        case .yoga: return .purple
        case .nutrition: return .green
        }
    }
}

// MARK: - Components

struct TeacherCard: View {
    let teacher: Teacher
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
                                colors: [teacher.category.color.opacity(0.3), teacher.category.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Text(teacher.imageIcon)
                        .font(.system(size: 35))
                }
                .shadow(color: teacher.category.color.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(teacher.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    
                    Text(teacher.specialty)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    HStack(spacing: 12) {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", teacher.rating))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                        }
                        
                        // Students
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                            Text("\(teacher.students)")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                        
                        // Experience
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                            Text(teacher.experience)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(teacher.category.color)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(teacher.category.color.opacity(0.3), lineWidth: 1)
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

struct CategoryChip: View {
    let category: TeacherCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                category.color :
                AppTheme.Colors.secondaryBackground
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? category.color : AppTheme.Colors.separator, lineWidth: 1)
            )
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(10)
    }
}

// MARK: - Teacher Detail View
struct TeacherDetailView: View {
    let teacher: Teacher
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [teacher.category.color.opacity(0.3), teacher.category.color],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Text(teacher.imageIcon)
                                .font(.system(size: 60))
                        }
                        .shadow(color: teacher.category.color.opacity(0.4), radius: 20, x: 0, y: 10)
                        
                        // Name & Specialty
                        VStack(spacing: 8) {
                            Text(teacher.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            Text(teacher.specialty)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", teacher.rating))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                Text("(\(teacher.students) tələbə)")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                        }
                        
                        // Stats
                        HStack(spacing: 12) {
                            DetailStatCard(
                                icon: "graduationcap.fill",
                                value: teacher.experience,
                                label: "Təcrübə"
                            )
                            
                            DetailStatCard(
                                icon: "person.2.fill",
                                value: "\(teacher.students)",
                                label: "Tələbə"
                            )
                            
                            DetailStatCard(
                                icon: "star.fill",
                                value: String(format: "%.1f", teacher.rating),
                                label: "Reytinq"
                            )
                        }
                        
                        // Bio
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Haqqında")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            Text(teacher.bio)
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(16)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button {
                                print("Müəllimlə əlaqə")
                            } label: {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                    Text("Müəllimlə Əlaqə")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [teacher.category.color, teacher.category.color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: teacher.category.color.opacity(0.4), radius: 8)
                            }
                            
                            Button {
                                print("Proqrama bax")
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("Proqrama Bax")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(teacher.category.color)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(teacher.category.color, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Müəllim Profili")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }
        }
    }
}

struct DetailStatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.red)
            
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

#Preview {
    TeachersView()
}
