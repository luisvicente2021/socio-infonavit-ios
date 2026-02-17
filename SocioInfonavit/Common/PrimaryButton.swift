//
//  PrimaryButton.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//
import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(buttonBackground)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
    
    private var buttonBackground: some View {
        Group {
            if isEnabled && !isLoading {
                Color.primaryRed
            } else {
                Color.secondaryGray.opacity(0.5)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Iniciar sesión") {
            print("Tapped")
        }
        
        PrimaryButton("Cargando...", isLoading: true) {
            print("Tapped")
        }
        
        PrimaryButton("Deshabilitado", isEnabled: false) {
            print("Tapped")
        }
    }
    .padding()
}
