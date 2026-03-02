import SwiftUI
import AVFoundation

struct ContentView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    
    //regular,  tam genis ekrana oturusmus
    
    //compact olcu  daha kicik ekran  width  landscape portrait
    
    //width
    //height
    
    
    let synthesizer = AVSpeechSynthesizer()
    // svg pdf sekilleri qoyuruq
    //option command + <-
    var body: some View {
        VStack(spacing: 30) {
            TeamMembersView()
            
            if verticalSizeClass == .compact{
                
            } else{
                
            }
            
            Text("Salam, We are Team")
                .fontWeight(.black)
                .font(.largeTitle)
            
          
                
                
            }
       
        CallButtonsview()
        
            //.padding(.horizontal, 50)
            Spacer()
        }
    }


#Preview {
    ContentView()
}
