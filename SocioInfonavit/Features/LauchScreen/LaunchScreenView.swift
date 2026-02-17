//
//  LaunchScreenView.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//
import SwiftUI

struct LaunchScreenView: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.primaryRed
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .scaleEffect(scale)
                
                VStack(spacing: 8) {
                    Text("Socio Infonavit")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Tu programa de beneficios")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(opacity)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.top, 40)
                    .opacity(opacity)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeIn(duration: 0.8)) {
            opacity = 1
            scale = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.4)) {
                isPresented = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LaunchScreenView(isPresented: .constant(true))
}
