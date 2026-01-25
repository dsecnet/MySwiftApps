//
//  ContentView.swift
//  MyIosApp
//
//  Created by Vusal Dadashov on 25.01.26.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
           
            Text("Salam Vusal")                //ui element
                .fontWeight(.black)
                .font(.largeTitle)
                .font(.system(.largeTitle, design: .monospaced ))
                
            //bunlar modifierdi
            
            Button {
                let utterance = AVSpeechUtterance(string: "salam men Vusalam")
                utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
                synthesizer.speak(utterance)
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
