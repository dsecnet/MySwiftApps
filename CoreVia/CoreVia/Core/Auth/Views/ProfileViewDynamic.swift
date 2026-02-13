//
//  ProfileView.swift
//  CoreVia
//
//  DİNAMİK PROFİL - Müştəri və ya Müəllim
//

import SwiftUI

struct ProfileView: View {
    
    @Binding var isLoggedIn: Bool
    @StateObject private var profileManager = UserProfileManager.shared
    
    var body: some View {
        Group {
            if profileManager.userProfile.userType == .client {
                ClientProfileView(isLoggedIn: $isLoggedIn)
            } else {
                TrainerProfileView(isLoggedIn: $isLoggedIn)
            }
        }
        .animation(.smooth(duration: 0.3), value: profileManager.userProfile.userType)
    }
}

// #Preview { // iOS 17+ only
//     ProfileView(isLoggedIn: .constant(true))
// }
