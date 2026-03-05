//
//  RestaurantView.swift
//  Restoran_listApp
//
//  Created by Vusal Dadashov on 05.03.26.
//


import SwiftUI

struct RestaurantView: View {

    @Binding var restaurant: Restaurant

    @State private var showShareSheet = false
    @State private var showReserveAlert = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
           
            Image(restaurant.image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(16)
                .clipped()

           
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.title)
                    .font(.system(.headline, design: .rounded))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(restaurant.type.icon)
                        .font(.system(size: 12))
                    Text(restaurant.type.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Text(restaurant.location)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.gray)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: Double(star) <= restaurant.rating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if restaurant.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button {
                showReserveAlert.toggle()
            } label: {
                Label("Masa rezerv et", systemImage: "phone")
            }

            Button {
                restaurant.isFavorite.toggle()
            } label: {
                Label(
                    restaurant.isFavorite ? "Favoritdən çıxar" : "Favorit et",
                    systemImage: restaurant.isFavorite ? "heart.slash" : "heart"
                )
            }

            Button {
                showShareSheet.toggle()
            } label: {
                Label("Paylaş", systemImage: "square.and.arrow.up")
            }
        }
        .alert("Tezliklə", isPresented: $showReserveAlert) {
            Button("OK") {}
        } message: {
            Text("Bu funksiya tezliklə əlavə olunacaq.")
        }
        .sheet(isPresented: $showShareSheet) {
            let text = "\(restaurant.title) - \(restaurant.location) ⭐️ \(restaurant.rating)"

            if let image = UIImage(named: restaurant.image) {
                ActivityView(activityItems: [text, image])
            } else {
                ActivityView(activityItems: [text])
            }
        }
    }
}
