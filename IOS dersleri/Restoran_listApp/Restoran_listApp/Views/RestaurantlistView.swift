//
//  RestaurantListView.swift
//  Restoran_listApp
//
//  Created by Vusal Dadashov on 05.03.26.
//

import SwiftUI

struct RestaurantListView: View {

    @State var list = [
        Restaurant(
            title: "Şirvanşah Muzey Restoranı",
            type: .milli,
            location: "İçərişəhər, Bakı",
            image: "cafedeadend",
            isFavorite: false,
            description: "Qədim İçərişəhərin mərkəzində yerləşən bu restoran Azərbaycan milli mətbəxinin ən dadlı yeməklərini təqdim edir. Tarixi ab-hava ilə müasir servis birləşir.",
            phone: "+994501234567",
            rating: 4.8
        ),
        Restaurant(
            title: "Dolma Restoranı",
            type: .milli,
            location: "Nizami küç., Bakı",
            image: "homei",
            isFavorite: false,
            description: "Ənənəvi Azərbaycan yeməkləri — dolma, plov, kabab və daha çoxu. Ailə ilə axşam yeməyi üçün ideal seçim.",
            phone: "+994551234567",
            rating: 4.5
        ),
        Restaurant(
            title: "Mangal Steakhouse",
            type: .steakhouse,
            location: "Nərimanov, Bakı",
            image: "teakha",
            isFavorite: false,
            description: "Premium keyfiyyətli ət yeməkləri və peşəkar barbekyu. Ən yaxşı steaklər burada bişirilir.",
            phone: "+994701234567",
            rating: 4.7
        ),
        Restaurant(
            title: "Cappuccino Cafe",
            type: .cafe,
            location: "Bulvar, Bakı",
            image: "cafeloisl",
            isFavorite: false,
            description: "Dəniz kənarında rahat kafe. Əla qəhvə, təzə desertlər və gözəl mənzərə.",
            phone: "+994771234567",
            rating: 4.3
        ),
        Restaurant(
            title: "Baku Balıq Evi",
            type: .seafood,
            location: "Səbail, Bakı",
            image: "fiveleaves",
            isFavorite: false,
            description: "Xəzər dənizindən təzə balıq və dəniz məhsulları. Hər gün təzə ovlanmış balıqlar.",
            phone: "+994601234567",
            rating: 4.6
        ),
        Restaurant(
            title: "Pizza Napoli",
            type: .italian,
            location: "28 May, Bakı",
            image: "barrafina",
            isFavorite: false,
            description: "Orijinal İtalyan pizzası odun sobasında bişirilir. Napoli üslubunda nazik xəmir.",
            phone: "+994511234567",
            rating: 4.4
        ),
        Restaurant(
            title: "Wok & Roll",
            type: .asian,
            location: "Gənclik, Bakı",
            image: "confessional",
            isFavorite: false,
            description: "Asiya mətbəxinin ən yaxşıları — ramen, sushi, wok yeməkləri. Sürətli və dadlı.",
            phone: "+994711234567",
            rating: 4.2
        ),
        Restaurant(
            title: "Şirin Künc",
            type: .bakery,
            location: "Həzi Aslanov, Bakı",
            image: "graham",
            isFavorite: false,
            description: "Ev şirniyyatları, tortlar və paxlava. Hər gün təzə bişirilir, əsl ev dadı.",
            phone: "+994561234567",
            rating: 4.9
        )
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(list.indices, id: \.self) { index in
                    ZStack(alignment: .leading) {
                        NavigationLink(destination: RestaurantDetailView(restaurant: list[index])) {
                            EmptyView()
                        }
                        .opacity(0)

                        RestaurantRowView(restaurant: $list[index])
                    }
                }
                .onDelete { indexSet in
                    list.remove(atOffsets: indexSet)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Dadlı Mekan")
            .navigationBarTitleDisplayMode(.automatic)
        }
        .tint(.orange)
    }
}


struct RestaurantRowView: View {

    @Binding var restaurant: Restaurant

    @State private var showShareSheet = false
    @State private var showReserveAlert = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Şəkil
            Image(restaurant.image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(16)
                .clipped()

            // Məlumat
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

                // Rating
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

#Preview {
    RestaurantListView()
}
