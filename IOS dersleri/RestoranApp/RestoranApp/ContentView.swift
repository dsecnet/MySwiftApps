//
//  ContentView.swift
//  RestoranApp
//
//  Created by Vusal Dadashov on 27.02.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Salam, I am Vusal")
                .fontWeight(.black)
                .font(.largeTitle)
            Button{
                //what it does
            } label: {
                Text("klik et")
                    .fontWeight(.bold)
                    .font(.system(.title, design: .monospaced))
            }
            .padding(10)
            .foregroundColor(.white)
            .background(Color.purple)
            .cornerRadius(6)
                
        }
       
    }
}

#Preview {
    ContentView()
}
