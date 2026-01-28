//
//  ContentView.swift
//  CoreVia
//
//

import SwiftUI

struct ContentView: View {
    
    @State private var isLoggedIn: Bool = false
    @State private var showRegister: Bool = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
            } else {
                if showRegister {
                    RegisterView(showRegister: $showRegister)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn, showRegister: $showRegister)
                }
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    
    @Binding var isLoggedIn: Bool
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Tab 1: Ana Səhifə
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Ana Səhifə")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Xoş gəldiniz! 💪")
                            .foregroundColor(.gray)
                        
                        Button {
                            withAnimation {
                                isLoggedIn = false
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Çıxış")
                            }
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                .navigationTitle("Ana")
            }
            .tabItem {
                Label("Ana", systemImage: "house.fill")
            }
            .tag(0)
            
            // Tab 2: Məşq
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("Məşq Tracking")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Tezliklə...")
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Məşq")
            }
            .tabItem {
                Label("Məşq", systemImage: "figure.strengthtraining.traditional")
            }
            .tag(1)
            
            // Tab 3: Qida
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Qida Tracking")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Tezliklə...")
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Qida")
            }
            .tabItem {
                Label("Qida", systemImage: "fork.knife")
            }
            .tag(2)
            
            // Tab 4: Müəllimlər
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("Müəllimlər")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Tezliklə...")
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Müəllimlər")
            }
            .tabItem {
                Label("Müəllimlər", systemImage: "person.2.fill")
            }
            .tag(3)
            
            // Tab 5: Profil
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Profilim")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Button {
                            withAnimation {
                                isLoggedIn = false
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Çıxış")
                            }
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                .navigationTitle("Profil")
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(.red)
    }
}

#Preview {
    ContentView()
}


