//
//  APIEndpoint.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//
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
    case login(credentials: String)
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
        case .login(let credentials):
            return ["credentials": credentials]
        case .searchBenevits(let query):
            return ["query": query]
        case .landingBenevits:
            return nil
        }
    }
    
    // MARK: - URL Request Builder
    
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        
        // Agregar headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Agregar body si existe
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        return request
    }
}
