//
//  UserSessionManager.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//


import Foundation
import Security

protocol UserSessionManaging {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
    func hasActiveSession() -> Bool
    func logout()
}

final class UserSessionManager: UserSessionManaging {
    static let shared = UserSessionManager()
    
    private let service = "com.socioinfonavit.app"
    private let tokenKey = "jwt_token"
    
    private init() {}
    
    func saveToken(_ token: String) {
        deleteToken() // Eliminar token anterior si existe
        
        guard let tokenData = token.data(using: .utf8) else {
            print("❌ Error: No se pudo convertir token a Data")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("✅ Token guardado exitosamente en KeyChain")
        } else {
            print("❌ Error guardando token: \(status)")
        }
    }
    
    /// Obtiene el token JWT del KeyChain
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let tokenData = result as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    /// Elimina el token JWT del KeyChain
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            print("✅ Token eliminado del KeyChain")
        } else {
            print("⚠️ Error eliminando token: \(status)")
        }
    }
    
    /// Verifica si existe una sesión activa
    func hasActiveSession() -> Bool {
        return getToken() != nil
    }
    
    /// Cierra la sesión eliminando el token
    func logout() {
        deleteToken()
        print("👋 Sesión cerrada")
    }
}

// MARK: - UserDefaults Alternative (para desarrollo)

extension UserSessionManager {
    /// Guarda token en UserDefaults (solo para desarrollo/testing)
    func saveTokenUnsafe(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        print("⚠️ Token guardado en UserDefaults (NO SEGURO)")
    }
    
    /// Obtiene token de UserDefaults (solo para desarrollo/testing)
    func getTokenUnsafe() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
}
