import SwiftUI

struct FoodView: View {

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Qida Tracking")
                            .font(.title)
                            .bold()
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text("Kalori və makro izləyin")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .font(.caption)
                    }

                    // Daily calories
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Günlük Kalori")
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .font(.headline)

                        ProgressView(value: 0.65)
                            .tint(.red)

                        Text("65% tamamlandı")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .font(.caption)
                    }
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(14)

                    // Meal Cards
                    VStack(spacing: 12) {
                        MealCard(title: "Səhər yeməyi", calories: 350, icon: "sunrise.fill")
                        MealCard(title: "Nahaar", calories: 520, icon: "sun.max.fill")
                        MealCard(title: "Axşam yeməyi", calories: 430, icon: "moon.fill")
                    }

                    // Quick action
                    Button {
                        // Add new meal action
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Yeni Qida Əlavə et")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.85))
                        .cornerRadius(14)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
    }
}

// MARK: - Meal Card Component
struct MealCard: View {
    let title: String
    let calories: Int
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.green)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .bold()
                Text("\(calories) kcal")
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .font(.caption)
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(14)
    }
}

#Preview {
    FoodView()
}
