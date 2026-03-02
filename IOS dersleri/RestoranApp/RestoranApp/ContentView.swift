import SwiftUI
import AVFoundation

struct ContentView: View {
    let synthesizer = AVSpeechSynthesizer()
    // svg pdf sekilleri qoyuruq
    var body: some View {
        VStack {
            HStack{
                Image("user1")
                    .resizable()
                    .scaledToFit()
                Image("user2")
                    .resizable()
                    .scaledToFit()
                Image("user3")
                    .resizable()
                    .scaledToFit()
            }
            
            Text("Salam, We are Team")
                .fontWeight(.black)
                .font(.largeTitle)
           
            HStack {
                Button {
                    let utterance = AVSpeechUtterance(string: "Salam, I am Vusal")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    synthesizer.speak(utterance)
                } label: {
                    Text("klik et")
                        .fontWeight(.bold)
                        .font(.system(.title, design: .monospaced))
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Color.purple)
                .cornerRadius(6)

                Button {
                    let utterance = AVSpeechUtterance(string: "Salam, I am Vusal")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    synthesizer.speak(utterance)
                } label: {
                    Text("Cancel")
                        .fontWeight(.bold)
                        .font(.system(.title, design: .monospaced))
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(6)
            }
        }
    }
}

#Preview {
    ContentView()
}
