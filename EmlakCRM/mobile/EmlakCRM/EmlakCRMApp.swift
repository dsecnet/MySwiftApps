//
//  EmlakCRMApp.swift
//  EmlakCRM
//
//  Main App Entry
//

import SwiftUI

@main
struct EmlakCRMApp: App {
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                MainTabView()
                    .environmentObject(authVM)
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}
