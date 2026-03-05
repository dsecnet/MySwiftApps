//
//  RestaurantDetailView.swift
//  Restoran_listApp
//
//  Created by Vusal Dadashov on 05.03.26.
//

import SwiftUI

struct RestaurantDetailView: View {
    @Environment(\.dismiss) var dismiss

    var restaurant: Restaurant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Hero Image
                ZStack(alignment: .bottom) {
                    Image(restaurant.image)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 400)
                        .clipped()

                    // Gradient overlay
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    // Title + Type
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(restaurant.type.icon)
                            Text(restaurant.type.rawValue)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }

                        Text(restaurant.title)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)

                        // Rating
                        HStack(spacing: 3) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: Double(star) <= restaurant.rating ? "star.fill" : "star")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                            }
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .padding(.bottom, 8)
                }

                // Favorite badge
                if restaurant.isFavorite {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Favorit")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }

                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Haqqında")
                        .font(.system(.headline, design: .rounded))

                    Text(restaurant.description)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()

           
                HStack(spacing: 12) {
                    InfoCard(
                        icon: "mappin.circle.fill",
                        title: "Ünvan",
                        value: restaurant.location,
                        color: .blue
                    )

                    InfoCard(
                        icon: "phone.circle.fill",
                        title: "Telefon",
                        value: restaurant.phone,
                        color: .green
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }
            }
        }
        .ignoresSafeArea()
    }
}


struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: Restaurant.sample)
    }
    .tint(.orange)
}
