//
//  LoginViewModelTests.swift
//  SocioInfonavit
//
//  Created by luisr on 14/02/26.
//

import XCTest
@testable import SocioInfonavit

@MainActor
final class LoginViewModelTests: XCTestCase {
    
    // MARK: - SUT y Mocks
    var viewModel: LoginViewModel!
    var mockNetwork: MockNetworkService!
    var mockSession: MockSessionManager!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkService()
        mockSession = MockSessionManager()
        viewModel = LoginViewModel(
            networkManager: mockNetwork,
            sessionManager: mockSession
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetwork = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Computed Properties Tests
    
    func test_isLoginButtonEnabled_validInputs_returnsTrue() {
        viewModel.username = "12345678901"
        viewModel.password = "password123"
        viewModel.isLoading = false
        
        XCTAssertTrue(viewModel.isLoginButtonEnabled)
    }
    
    func test_isLoginButtonEnabled_loading_returnsFalse() {
        viewModel.username = "12345678901"
        viewModel.password = "password123"
        viewModel.isLoading = true
        
        XCTAssertFalse(viewModel.isLoginButtonEnabled)
    }
    
    func test_isUsernameValid_correct11Digits_returnsTrue() {
        viewModel.username = "12345678901"
        XCTAssertTrue(viewModel.isUsernameValid)
    }
    
    func test_isUsernameValid_invalidCharacters_returnsFalse() {
        viewModel.username = "12345abc901"
        XCTAssertFalse(viewModel.isUsernameValid)
    }
    
    func test_isPasswordValid_8CharactersOrMore_returnsTrue() {
        viewModel.password = "12345678"
        XCTAssertTrue(viewModel.isPasswordValid)
    }
    
    func test_isPasswordValid_lessThan8Characters_returnsFalse() {
        viewModel.password = "1234"
        XCTAssertFalse(viewModel.isPasswordValid)
    }
    
    // MARK: - validateUsernameInput
    func test_validateUsernameInput_filtersNonNumbersAndLimitsTo11() {
        viewModel.validateUsernameInput("abc1234567890123xyz")
        XCTAssertEqual(viewModel.username, "12345678901")
    }
    
    // MARK: - clearError
    func test_clearError_setsErrorMessageToNil() {
        viewModel.errorMessage = "Some error"
        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - login() Validation Errors
    
    func test_login_invalidUsername_setsErrorMessage() async {
        viewModel.username = "123"
        viewModel.password = "password123"
        
        await viewModel.login()
        XCTAssertEqual(viewModel.errorMessage, "El usuario debe tener 11 dígitos")
    }
    
    func test_login_invalidPassword_setsErrorMessage() async {
        viewModel.username = "12345678901"
        viewModel.password = "123"
        
        await viewModel.login()
        XCTAssertEqual(viewModel.errorMessage, "La contraseña debe tener al menos 8 caracteres")
    }
    
    // MARK: - login() Success
    
    func test_login_success_setsAuthenticatedAndSavesToken() async {
        mockNetwork.shouldSucceed = true
        
        viewModel.username = "12345678901"
        viewModel.password = "password123"
        
        await viewModel.login()
        
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockSession.savedToken, "test-token-12345")
        XCTAssertTrue(mockNetwork.requestCalled)
    }

    // MARK: - login() Timeout Error
    
    
}
