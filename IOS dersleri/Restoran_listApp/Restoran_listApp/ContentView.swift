//
//  ContentView.swift
//  Restoran_listApp
//
//  Created by Vusal Dadashov on 03.03.26.
//

import SwiftUI

struct ContentView: View {
    var restorantsList = ["Resroan1", "Restoran2", "Restoran4", "Restoran5"]
    var body: some View {
      
        List{
            ForEach(0...restorantsList.count-1, id: \.self) { index in
                
                HStack{
                    Image("restaurant")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text(restorantsList[index])
                }
            }
        
        }
    }
}

#Preview {
    ContentView()
}
