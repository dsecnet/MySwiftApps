//
//  CallButtonsview.swift
//  RestoranApp
//
//  Created by Vusal Dadashov on 02.03.26.
//
import SwiftUI
import AVFoundation

struct CallButtonsview: View {
    
    // svg pdf sekilleri qoyuruq
    //option command + <-
    var body: some View {
        
        VStack {
            Button {
               
            } label: {
                Text("Buraya klik et")
                    .fontWeight(.bold)
                    .font(.system(.title, design: .monospaced))
            }
            .padding(10)
            .foregroundColor(.white)
            .background(Color.purple)
            .cornerRadius(6)
            
            Button {
             
            } label: {
                Text("Cancel")
                    .fontWeight(.bold)
                    .font(.system(.title, design: .monospaced))
            }
            .padding(20)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(6)
            
        }
    }
}
