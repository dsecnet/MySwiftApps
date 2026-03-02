//
//  TeamMembersView.swift
//  RestoranApp
//
//  Created by Vusal Dadashov on 02.03.26.
//

import SwiftUI
import AVFoundation

struct TeamMembersView: View {
    var body: some View {
        
        HStack{
            VStack{
                Image("user1")
                    .resizable()
                    .scaledToFit()
                Text("VUSAL")
            }
            VStack{
                Image("user2")
                    .resizable()
                    .scaledToFit()
                Text("ALI")
            }
            VStack{
                Image("user3")
                    .resizable()
                    .scaledToFit()
                Text("Elmir")
            }
        }
        
    }
}
