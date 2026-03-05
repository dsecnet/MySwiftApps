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

                        RestaurantView(restaurant: $list[index])
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




#Preview {
    RestaurantListView()
}
