//
//  NetworkError.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//


import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case decodingError
    case noInternetConnection
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL es inválida"
        case .invalidResponse:
            return "Respuesta del servidor inválida"
        case .unauthorized:
            return "Usuario o contraseña incorrectos"
        case .serverError(let code):
            return "Error del servidor (código: \(code))"
        case .decodingError:
            return "Error al procesar la respuesta"
        case .noInternetConnection:
            return "No hay conexión a internet"
        case .timeout:
            return "La solicitud tardó demasiado tiempo"
        case .unknown(let error):
            return "Error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Verifica tus credenciales e intenta de nuevo"
        case .noInternetConnection:
            return "Verifica tu conexión a internet"
        case .timeout:
            return "Intenta de nuevo más tarde"
        case .serverError:
            return "Intenta de nuevo en unos momentos"
        default:
            return "Por favor intenta de nuevo"
        }
    }
}
