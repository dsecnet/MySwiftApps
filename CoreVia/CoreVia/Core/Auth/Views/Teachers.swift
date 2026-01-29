import SwiftUI

struct TeachersView: View {

    // Demo data
    let teachers: [Teacher] = [
        Teacher(name: "Elvin Məmmədov", subject: "Fitness Coach"),
        Teacher(name: "Aysel Quliyeva", subject: "Nutrition Specialist"),
        Teacher(name: "Rauf Əliyev", subject: "Strength Trainer")
    ]

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(teachers) { teacher in
                        TeacherRow(teacher: teacher)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Teacher Model
struct Teacher: Identifiable {
    let id = UUID()
    let name: String
    let subject: String
}

// MARK: - Teacher Row
struct TeacherRow: View {
    let teacher: Teacher

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.purple)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(teacher.name)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .bold()

                Text(teacher.subject)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .font(.caption)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.Colors.secondaryText)
                .font(.caption)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
    }
}

#Preview {
    TeachersView()
}
