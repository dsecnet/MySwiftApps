//
//  ContentView.swift
//  MyIosApp
//
//  Created by Vusal Dadashov on 25.01.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
           
            Text("Salam Vusal")                //ui element
                .fontWeight(.black)
                .font(.largeTitle)
                .font(.system(.largeTitle, design: .monospaced ))
                
            //bunlar modifierdi
            
            Button {
                //what it does
            } label: {
                //how it  looks
                Text("klik et")
                    .fontWeight(.bold)
                    .font(.system(.title, design: .monospaced))
            }
            .padding(10)
            .foregroundColor(.white)
            .background(Color.purple)
            .cornerRadius(20)
        }
        
    }
}

#Preview {
    ContentView()
}
