import SwiftUI

struct HomeView: View {

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Salam 👋")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)

                        Text("Bu gün hədəflərinə fokuslan!")
                            .foregroundColor(.gray)
                    }

                    // MARK: - Stats
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Məşq",
                            value: "45 dəq",
                            icon: "flame.fill",
                            color: .red
                        )

                        StatCard(
                            title: "Kalori",
                            value: "520",
                            icon: "bolt.fill",
                            color: .orange
                        )
                    }

                    // MARK: - Daily Goal
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Günlük Hədəf")
                            .foregroundColor(.white)
                            .font(.headline)

                        ProgressView(value: 0.6)
                            .tint(.red)

                        Text("60% tamamlandı")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(14)

                    // MARK: - Quick Actions
                    Text("Tez Əməliyyatlar")
                        .foregroundColor(.white)
                        .font(.headline)

                    HStack(spacing: 12) {
                        QuickActionButton(
                            title: "Məşq Əlavə et",
                            icon: "plus.circle.fill"
                        )

                        QuickActionButton(
                            title: "Qida Əlavə et",
                            icon: "fork.knife"
                        )
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text(title)
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button {} label: {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.85))
            .cornerRadius(12)
        }
    }
}

#Preview {
    HomeView()
}
