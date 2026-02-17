//
//  CustomTextField.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//
import SwiftUI

struct CustomTextField: View {
    
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var returnKeyType: UIReturnKeyType = .default
    var isValid: Bool = true
    var errorMessage: String?
    var onReturn: (() -> Void)?
    var onTextChange: ((String) -> Void)?
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle()
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle()
                        .keyboardType(keyboardType)
                        .textContentType(
                            keyboardType == .emailAddress ? .emailAddress : .none
                        )
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                }
                
                if !text.isEmpty {
                    Image(
                        systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
                    )
                    .foregroundColor(isValid ? .green : .red)
                    .font(.system(size: 20))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isFocused ? 2 : 0)
            )
            
            if let errorMessage = errorMessage, !isValid && !text.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isValid)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .onChange(of: text) { _, newValue in
            onTextChange?(newValue)
        }
        .onSubmit {
            onReturn?()
        }
    }
    
    private var borderColor: Color {
        if !isValid && !text.isEmpty {
            return .red
        }
        return isFocused ? .primaryRed : .clear
    }
}

private extension View {
    func textFieldStyle() -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(.textPrimary)
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            placeholder: "Usuario",
            text: .constant(""),
            keyboardType: .numberPad
        )
        
        CustomTextField(
            placeholder: "Contraseña",
            text: .constant("test123"),
            isSecure: true,
            isValid: false,
            errorMessage: "La contraseña debe tener al menos 8 caracteres"
        )
        
        CustomTextField(
            placeholder: "Email",
            text: .constant("test@example.com"),
            keyboardType: .emailAddress,
            isValid: true
        )
    }
    .padding()
}
