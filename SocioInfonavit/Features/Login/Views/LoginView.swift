//
//  LoginView.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?
    
    private let strings = LoginStrings()
    
    enum Field {
        case username
        case password
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    formSection
                    loginButton
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }
            .hideKeyboardOnTap()
            
            if let errorMessage = viewModel.errorMessage {
                errorOverlay(message: errorMessage)
            }
        }
        .onChange(of: viewModel.isAuthenticated) { _, isAuth in
            if isAuth {
                // La navegación se maneja en el App principal
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.primaryRed)
            
            VStack(spacing: 8) {
                Text(strings.welcomeTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text(strings.welcomeSubtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondaryGray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, 20)
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            CustomTextField(
                placeholder: strings.usernamePlaceholder,
                text: $viewModel.username,
                keyboardType: .numberPad,
                returnKeyType: .next,
                isValid: viewModel.isUsernameValid,
                errorMessage: strings.usernameError,
                onReturn: {
                    focusedField = .password
                },
                onTextChange: { newValue in
                    viewModel.validateUsernameInput(newValue)
                }
            )
            .focused($focusedField, equals: .username)
            
            CustomTextField(
                placeholder: strings.passwordPlaceholder,
                text: $viewModel.password,
                isSecure: true,
                returnKeyType: .go,
                isValid: viewModel.isPasswordValid,
                errorMessage: strings.passwordError,
                onReturn: {
                    if viewModel.isLoginButtonEnabled {
                        Task {
                            await viewModel.login()
                        }
                    }
                }
            )
            .focused($focusedField, equals: .password)
        }
    }
    
    private var loginButton: some View {
        PrimaryButton(
            strings.loginButton,
            isLoading: viewModel.isLoading,
            isEnabled: viewModel.isLoginButtonEnabled
        ) {
            Task {
                await viewModel.login()
            }
        }
        .padding(.top, 12)
    }
    
    private func errorOverlay(message: String) -> some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewModel.clearError()
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .padding()
            .background(Color.red)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding()
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .ignoresSafeArea(.keyboard)
    }
}


#Preview {
    LoginView()
}
