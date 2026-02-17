import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let strings = LoginStrings() 
    
    var isLoginButtonEnabled: Bool {
        !username.isEmpty && !password.isEmpty && !isLoading
    }
    
    var isUsernameValid: Bool {
        username.isEmpty || (username.count == 11 && username.allSatisfy { $0.isNumber })
    }
    
    var isPasswordValid: Bool {
        password.isEmpty || password.count >= 8
    }
    
    private let networkManager: NetworkServiceProtocol
    private let sessionManager: UserSessionManaging
    
    init(
        networkManager: NetworkServiceProtocol = NetworkConfiguration.createService(),
        sessionManager: UserSessionManaging = UserSessionManager.shared
    ) {
        self.networkManager = networkManager
        self.sessionManager = sessionManager
        
        checkExistingSession()
    }
    
    func login()  async {
        guard isLoginButtonEnabled else { return }
        
        guard isUsernameValid else {
            errorMessage = strings.usernameError
            return
        }
        
        guard isPasswordValid else {
            errorMessage = strings.passwordError
            return
        }
        
        await performLogin()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let encryptedCredentials: String
            if let encrypted = RSAEncryption.encryptCredentials(username: username, password: password) {
                encryptedCredentials = encrypted
            } else {
                encryptedCredentials = RSAEncryption.mockEncryptCredentials(username: username, password: password)
            }
            
            let endpoint = SocioInfonavitEndpoint.login(
                credentials: encryptedCredentials,
                username: username,
                password: password
            )
            let response = try await networkManager.requestWithHeaders(
                endpoint: endpoint,
                responseType: EmptyResponse.self
            )
            
            if let token = extractJWT(from: response.headers) {
                sessionManager.saveToken(token)
                isAuthenticated = true
                NotificationCenter.default.post(name: .userDidLogin, object: nil)
                print("✅ Login exitoso")
            } else {
                errorMessage = strings.authTokenError
            }
            
        } catch let error as NetworkError {
            handleLoginError(error)
        } catch {
            errorMessage = "\(strings.unexpectedError): \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func extractJWT(from headers: [AnyHashable: Any]) -> String? {
        let possibleKeys = ["Authorization", "authorization", "Token", "token", "jwt"]
        
        for key in possibleKeys {
            if let value = headers[key] as? String {
                return value.replacingOccurrences(of: "Bearer ", with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
    
    private func handleLoginError(_ error: NetworkError) {
        switch error {
        case .unauthorized:
            errorMessage = strings.loginFailed
        case .noInternetConnection:
            errorMessage = strings.noInternet
        case .timeout:
            errorMessage = strings.timeout
        default:
            errorMessage = error.localizedDescription
        }
        
        print("❌ Login error: \(error.localizedDescription)")
    }
    
    private func checkExistingSession() {
        if sessionManager.hasActiveSession() {
            isAuthenticated = true
        }
    }
    
    func clearCredentials() {
        username = ""
        password = ""
        errorMessage = nil
        isLoading = false
    }
}


extension LoginViewModel {
    func validateUsernameInput(_ newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        username = String(filtered.prefix(11))
    }
}
