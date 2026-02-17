//
//  SearchBar.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//
import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    var placeholder: String = "Buscar benevits..."
    var onSearch: (String) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondaryGray)
                .font(.system(size: 18))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(.textPrimary)
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    onSearch(newValue)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearch("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondaryGray)
                        .font(.system(size: 18))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isFocused ? Color.primaryRed : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SearchBar(text: .constant("")) { query in
            print("Searching: \(query)")
        }
        
        SearchBar(text: .constant("xbox")) { query in
            print("Searching: \(query)")
        }
    }
    .padding()
}
