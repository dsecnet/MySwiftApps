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
                    RegisterScreen(showRegister: $showRegister)
                } else {
                    LoginScreen(isLoggedIn: $isLoggedIn, showRegister: $showRegister)
                }
            }
        }
    }
}

// MARK: - Login Ekranı
struct LoginScreen: View {
    
    @Binding var isLoggedIn: Bool
    @Binding var showRegister: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    Spacer().frame(height: 40)
                    
                    // Logo - Sizin icon
                    VStack(spacing: 16) {
                        Image("corevia_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(12)
                            .background(Color.red)
                            .cornerRadius(20)
                        
                        Text("CoreVia")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("GÜCƏ GEDƏN YOL")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red)
                            .tracking(2)
                    }
                    
                    // Inputs
                    VStack(spacing: 16) {
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            TextField("Email", text: $email)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            SecureField("Şifrə", text: $password)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    HStack {
                        Spacer()
                        Button {
                            print("Şifrəni unutdum")
                        } label: {
                            Text("Şifrəni unutdum?")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    // Düymələr
                    VStack(spacing: 12) {
                        
                        Button {
                            loginAction()
                        } label: {
                            Text(isLoading ? "Gözləyin..." : "Daxil ol")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            isLoggedIn = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                Text("Demo Versiya (Test)")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    HStack(spacing: 12) {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Text("və ya")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.horizontal, 32)
                    
                    HStack(spacing: 4) {
                        Text("Hesabınız yoxdur?")
                            .foregroundColor(.gray)
                        
                        Button {
                            showRegister = true
                        } label: {
                            Text("Qeydiyyatdan keç")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                    .font(.system(size: 15))
                    
                    Spacer()
                }
            }
        }
    }
    
    private func loginAction() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            isLoggedIn = true
        }
    }
}

// MARK: - Register Ekranı
struct RegisterScreen: View {
    
    @Binding var showRegister: Bool
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        showRegister = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Geri")
                        }
                        .foregroundColor(.red)
                    }
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Qeydiyyat")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 16) {
                            TextField("Ad Soyad", text: $name)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            
                            TextField("Email", text: $email)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            
                            SecureField("Şifrə", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                        
                        Button {
                            showRegister = false
                        } label: {
                            Text("Qeydiyyatdan keç")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)
                }
            }
        }
    }
}

// MARK: - Tab View
struct MainTabView: View {
    
    @Binding var isLoggedIn: Bool
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
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
                            isLoggedIn = false
                        } label: {
                            Text("Çıxış")
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.white.opacity(0.1))
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
            
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("Məşq").foregroundColor(.white)
                }
                .navigationTitle("Məşq")
            }
            .tabItem {
                Label("Məşq", systemImage: "figure.strengthtraining.traditional")
            }
            .tag(1)
            
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("Qida").foregroundColor(.white)
                }
                .navigationTitle("Qida")
            }
            .tabItem {
                Label("Qida", systemImage: "fork.knife")
            }
            .tag(2)
            
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("Müəllimlər").foregroundColor(.white)
                }
                .navigationTitle("Müəllimlər")
            }
            .tabItem {
                Label("Müəllimlər", systemImage: "person.2.fill")
            }
            .tag(3)
            
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("Profil").foregroundColor(.white)
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
