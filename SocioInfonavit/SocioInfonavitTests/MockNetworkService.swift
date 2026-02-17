import Foundation
@testable import SocioInfonavit

final class MockNetworkService: NetworkServiceProtocol {
    
    // MARK: - Configuración del comportamiento
    var shouldSucceed: Bool = true
    var mockError: NetworkError = .unauthorized
    var mockDelay: TimeInterval = 0.0
    
    // MARK: - Mock Responses por tipo
    var mockLoginResponse: EmptyResponse?
    var mockBenevitsResponse: BenevitsResponse?
    var mockSearchResponse: SearchResponse?
    
    // MARK: - Headers
    var mockHeaders: [AnyHashable: Any] = [
        "Authorization": "Bearer test-token-12345"
    ]
    
    // MARK: - Tracking
    private(set) var requestCalled = false
    private(set) var requestCallCount = 0
    private(set) var lastEndpoint: APIEndpoint?
    
    // MARK: - Protocol Methods
    
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let result = try await requestWithHeaders(endpoint: endpoint, responseType: T.self)
        return result.data
    }
    
    func requestWithHeaders<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> (data: T, headers: [AnyHashable: Any]) {
        
        // Tracking
        requestCalled = true
        requestCallCount += 1
        lastEndpoint = endpoint
        
        // Simulate delay
        if mockDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        // Check if should fail
        if !shouldSucceed {
            throw mockError
        }
        
        // Return appropriate mock response based on type
        if let response = getMockResponse(for: T.self) {
            return (response, mockHeaders)
        }
        
        throw NetworkError.invalidResponse
    }
    
    // MARK: - Helper Methods
    
    /// Retorna la respuesta mock apropiada según el tipo
    private func getMockResponse<T: Decodable>(for type: T.Type) -> T? {
        // EmptyResponse (Login)
        if T.self == EmptyResponse.self {
            if let response = mockLoginResponse {
                return response as? T
            }
            // Default si no hay mockLoginResponse configurado
            return EmptyResponse(success: true, message: "Login exitoso") as? T
        }
        
        // BenevitsResponse (Landing benevits)
        if T.self == BenevitsResponse.self {
            if let response = mockBenevitsResponse {
                return response as? T
            }
            // Default si no hay mockBenevitsResponse configurado
            return createDefaultBenevitsResponse() as? T
        }
        
        // SearchResponse (Search benevits)
        if T.self == SearchResponse.self {
            if let response = mockSearchResponse {
                return response as? T
            }
            // Default si no hay mockSearchResponse configurado
            return createDefaultSearchResponse() as? T
        }
        
        return nil
    }
    
    /// Crea una respuesta de benevits por defecto para cuando no se configura
    private func createDefaultBenevitsResponse() -> BenevitsResponse {
        let locked = [
            Benevit(
                id: 1,
                name: "Test Locked",
                description: "Test Description",
                vectorFullPath: "path",
                ally: nil,
                category: "Test",
                expirationDate: nil,
                isLocked: true
            )
        ]
        
        let unlocked = [
            Benevit(
                id: 2,
                name: "Test Unlocked 1",
                description: "Test Description",
                vectorFullPath: nil,
                ally: nil,
                category: "Test",
                expirationDate: nil,
                isLocked: false
            ),
            Benevit(
                id: 3,
                name: "Test Unlocked 2",
                description: "Test Description",
                vectorFullPath: nil,
                ally: nil,
                category: "Test",
                expirationDate: nil,
                isLocked: false
            )
        ]
        
        return BenevitsResponse(locked: locked, unlocked: unlocked)
    }
    
    /// Crea una respuesta de búsqueda por defecto
    private func createDefaultSearchResponse() -> SearchResponse {
        let benevits = [
            Benevit(
                id: 4,
                name: "Search Result",
                description: "Test Search",
                vectorFullPath: nil,
                ally: nil,
                category: "Test",
                expirationDate: nil,
                isLocked: false
            )
        ]
        
        return SearchResponse(benevits: benevits)
    }
    
    // MARK: - Test Helpers
    
    /// Resetea el mock a su estado inicial
    func reset() {
        shouldSucceed = true
        mockError = .unauthorized
        mockDelay = 0.0
        mockLoginResponse = nil
        mockBenevitsResponse = nil
        mockSearchResponse = nil
        requestCalled = false
        requestCallCount = 0
        lastEndpoint = nil
    }
}
