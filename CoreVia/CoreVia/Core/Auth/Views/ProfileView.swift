import SwiftUI

struct ProfileView: View {

    @Binding var isLoggedIn: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Avatar & Name
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 90))
                            .foregroundColor(.orange)

                        Text("Vusal")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)

                        Text("Fitness Level: Beginner 💪")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }

                    // MARK: - Stats
                    HStack(spacing: 12) {
                        ProfileStatCard(title: "Məşq", value: "24")
                        ProfileStatCard(title: "Gün", value: "18")
                        ProfileStatCard(title: "Kalori", value: "9.2k")
                    }

                    // MARK: - Settings
                    VStack(spacing: 12) {
                        ProfileRow(icon: "gearshape.fill", title: "Ayarlar")
                        ProfileRow(icon: "bell.fill", title: "Bildirişlər")
                        ProfileRow(icon: "lock.fill", title: "Təhlükəsizlik")
                        ProfileRow(icon: "star.fill", title: "Premium")
                    }

                    // MARK: - Logout
                    Button {
                        withAnimation {
                            isLoggedIn = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Çıxış")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(14)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
    }
}

// MARK: - Components

struct ProfileStatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.headline)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 24)

            Text(title)
                .foregroundColor(.white)

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
    ProfileView(isLoggedIn: .constant(true))
}
