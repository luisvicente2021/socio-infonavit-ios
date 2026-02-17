//
//  SocioInfonavitApp.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//
import SwiftUI

@main
struct SocioInfonavitApp: App {
    

    @State private var showSplash = true
    @State private var isAuthenticated = false
    
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var benevitsViewModel = BenevitsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isAuthenticated {
                    HomeView {
                        handleLogout()
                    }
                    .transition(.opacity)
                } else {
                    LoginView()
                        .transition(.opacity)
                        .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { _ in
                            handleLogin()
                        }
                }
                
                if showSplash {
                    LaunchScreenView(isPresented: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .environmentObject(loginViewModel)
            .environmentObject(benevitsViewModel)
            .animation(.easeInOut(duration: 0.3), value: isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: showSplash)
        }
    }
    
    private func handleLogin() {
        withAnimation {
            isAuthenticated = true
        }
    }
    
    private func handleLogout() {
        withAnimation {
            isAuthenticated = false
            benevitsViewModel.clearData()
        }
    }
}

extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
}
