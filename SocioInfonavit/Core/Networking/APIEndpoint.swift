import Foundation

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: [String: Any]? { get }
    
    func asURLRequest() throws -> URLRequest
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum SocioInfonavitEndpoint: APIEndpoint {
    
    case login(credentials: String, username: String, password: String)
    case landingBenevits
    case searchBenevits(query: String)
    
    var baseURL: String {
        "https://qa-api.socioinfonavit.com"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/api/v2/member/authentication"
        case .landingBenevits:
            return "/api/v1/member/landing_benevits"
        case .searchBenevits:
            return "/api/v1/member/member_benevits/search"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .searchBenevits:
            return .post
        case .landingBenevits:
            return .get
        }
    }
    
    var headers: [String: String]? {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if case .login = self {
            return headers
        }
        
        if let token = UserSessionManager.shared.getToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    var body: [String: Any]? {
        switch self {
        case .login(let credentials, let username, let password):
            return [
                "credentials": credentials,      // ← Para API real
                "_mockUsername": username,        // ← Solo para Mock
                "_mockPassword": password         // ← Solo para Mock
            ]
        case .searchBenevits(let query):
            return ["query": query]
        case .landingBenevits:
            return nil
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            let apiBody = body.filter { !$0.key.hasPrefix("_mock") }
            request.httpBody = try JSONSerialization.data(withJSONObject: apiBody)
        }
        
        return request
    }
}
