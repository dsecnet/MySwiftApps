import SwiftUI
import AVFoundation

struct ContentView: View {
    let synthesizer = AVSpeechSynthesizer()
    // svg pdf sekilleri qoyuruq
    //option command + <-
    var body: some View {
        VStack(spacing: 30) {
           
            
            Text("Salam, We are Team")
                .fontWeight(.black)
                .font(.largeTitle)
            
          
                
                
            }
        TeamMembersView()
        CallButtonsview()
        
            //.padding(.horizontal, 50)
            Spacer()
        }
    }


#Preview {
    ContentView()
}
