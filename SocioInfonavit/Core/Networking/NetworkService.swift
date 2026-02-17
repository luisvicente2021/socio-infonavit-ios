
import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T
    
    func requestWithHeaders<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> (data: T, headers: [AnyHashable: Any])
}

// MARK: - Network Service

final class NetworkService: NetworkServiceProtocol, ObservableObject {
    
    static let shared = NetworkService()
    
    // MARK: - Configuration
    
    var useMockData: Bool = true
    var mockDelay: TimeInterval = 0.5
    
    // MARK: - Dependencies
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    
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
        
        if useMockData {
            return try await handleMockRequest(endpoint: endpoint, responseType: T.self)
        } else {
            return try await handleRealRequest(endpoint: endpoint, responseType: T.self)
        }
    }
    
    // MARK: - Mock Request Handler
    
    private func handleMockRequest<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> (data: T, headers: [AnyHashable: Any]) {
        
        // Validar internet REAL
        guard NetworkReachability.shared.isConnected else {
            print("❌ Sin conexión a internet REAL")
            throw NetworkError.noInternetConnection
        }
        
        
        // Simular delay de red
        try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        
        // Para LOGIN: validar credenciales
        if endpoint.path.contains("authentication") {
            return try await handleMockLogin(endpoint: endpoint, responseType: T.self)
        }
        // Para otros endpoints
        else {
            return try await handleMockOtherEndpoints(endpoint: endpoint, responseType: T.self)
        }
    }
    
    // MARK: - Real Request Handler
    
    private func handleRealRequest<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> (data: T, headers: [AnyHashable: Any]) {
        
        let request = try endpoint.asURLRequest()
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        let headers = httpResponse.allHeaderFields
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return (decodedData, headers)
            } catch {
                print("❌ Decoding error: \(error)")
                throw NetworkError.decodingError
            }
            
        case 401:
            throw NetworkError.unauthorized
            
        case 400...499:
            throw NetworkError.serverError(httpResponse.statusCode)
            
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
            
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Mock Login Handler
    
    private func handleMockLogin<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> (data: T, headers: [AnyHashable: Any]) {
        
        guard let body = endpoint.body,
              let username = body["_mockUsername"] as? String,
              let password = body["_mockPassword"] as? String else {
            print("❌ Mock: No se pudieron extraer credenciales")
            throw NetworkError.invalidResponse
        }
        
        print("🔍 Mock: Validando usuario: \(username)")
        
        if let scenario = MockData.validateCredentials(username: username, password: password) {
            return try await handleMockCredentialScenario(scenario: scenario, responseType: T.self)
        } else {
            print("❌ Mock: Credenciales incorrectas")
            throw NetworkError.unauthorized
        }
    }
    
    // MARK: - Mock Credential Scenarios
    
    private func handleMockCredentialScenario<T: Decodable>(
        scenario: MockData.CredentialScenario,
        responseType: T.Type
    ) async throws -> (data: T, headers: [AnyHashable: Any]) {
        
        switch scenario {
        case .success:
            print("✅ Mock: Login exitoso")
            guard let response = EmptyResponse(success: true, message: "Login exitoso") as? T else {
                throw NetworkError.invalidResponse
            }
            return (response, MockData.mockHeaders)
            
        case .serverError:
            print("🔴 Mock: Error del servidor (500)")
            throw NetworkError.serverError(500)
            
        case .timeout:
            print("⏱️ Mock: Timeout - esperando 5 segundos...")
            try await Task.sleep(nanoseconds: 5_000_000_000)
            print("❌ Mock: Timeout")
            throw NetworkError.timeout
        }
    }
    
    // MARK: - Mock Other Endpoints
    
    private func handleMockOtherEndpoints<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> (data: T, headers: [AnyHashable: Any]) {
        
        let path = endpoint.path
        
        if path.contains("landing_benevits"), T.self == BenevitsResponse.self {
            print("✅ Mock: Cargando benevits")
            guard let response = MockData.createBenevitsResponse() as? T else {
                throw NetworkError.invalidResponse
            }
            return (response, MockData.mockHeaders)
        }
        
        if path.contains("member_benevits/search"), T.self == SearchResponse.self {
            print("✅ Mock: Búsqueda de benevits")
            guard let response = MockData.createSearchResponse() as? T else {
                throw NetworkError.invalidResponse
            }
            return (response, MockData.mockHeaders)
        }
        
        print("❌ Mock: Endpoint no soportado - \(path)")
        throw NetworkError.invalidResponse
    }
}
