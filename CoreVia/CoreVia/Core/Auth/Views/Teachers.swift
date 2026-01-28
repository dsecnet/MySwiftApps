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
            Color.black.ignoresSafeArea()

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
                    .foregroundColor(.white)
                    .bold()

                Text(teacher.subject)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

#Preview {
    TeachersView()
}
