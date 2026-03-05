//
//  RestaurantView.swift
//  Restoran_listApp
//
//  Created by Vusal Dadashov on 05.03.26.
//
//  NOTE: Bu view hazırda heç yerdə istifadə olunmur.
//  BasicTextImageRow eyni funksiyanı yerinə yetirir.
//

import SwiftUI

struct RestaurantView: View {

    @State private var showOptions = false
    @State private var showError = false

    @Binding var restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(restaurant.image)
                .resizable()
                .frame(height: 250)
                .cornerRadius(20)

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading) {
                    Text(restaurant.title)
                        .font(.system(.title2, design: .rounded))

                    Text(restaurant.type.rawValue)
                        .font(.system(.body, design: .rounded))

                    Text(restaurant.location)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom)

                if restaurant.isFavorite {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .foregroundColor(.yellow)
                        .padding(.trailing, 16)
                }
            }
        }
        .contextMenu {
            Button {
                showError.toggle()
            } label: {
                Label("Reserve", systemImage: "phone")
            }

            Button {
                restaurant.isFavorite.toggle()
            } label: {
                Label(
                    restaurant.isFavorite ? "Remove favorite" : "Mark as favorite",
                    systemImage: restaurant.isFavorite ? "heart.slash" : "heart"
                )
            }
        }
        .alert("Alert", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text("Sorry")
        }
    }
}
