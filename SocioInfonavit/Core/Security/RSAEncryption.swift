//
//  RSAEncryption.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//


import Foundation
import Security

final class RSAEncryption {
    
    // MARK: - Public Key
    
    private static let publicKeyPEM = """
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuIGVY6DVBZ/X4rWIOC5B
    kwXupvlRDZibogBmdkoER0Z3WX8PtyWcpf09fcvjaBw6Xwcw73E6uQMWMbSYR/Q8
    /6lk7TjQ7bDBnJ5M2ZI3cXhVEth2sGPfdrTWwiDjmyTOCtUUrs7DkC1vwV/uWQNo
    /Ed2wTdY6VKk8Dnkg4yZwqfzwFzJ82dh8zh0l08UHP+35B5SqDkbi4x/xCf7Qgp4
    g7omgBLfxqsTAllWAs2Ra+1jn3xzr4gOdbNZpXuoCRfrcrE/EcXbTxaPqArXSzff
    VZqjR5ulv5o5dRPT4vu7f2RKAhheXfWjQ3fzmlrckBfQf2EC3aBUu4mZmnzMIYJt
    MQIDAQAB
    -----END PUBLIC KEY-----
    """
    
    // MARK: - Encryption Method
    
    /// Encripta las credenciales usando RSA y retorna base64
    /// - Parameters:
    ///   - username: Nombre de usuario
    ///   - password: Contraseña
    /// - Returns: String encriptado en base64 o nil si falla
    static func encryptCredentials(username: String, password: String) -> String? {
        // Formato: "usuario:password"
        let credentials = "\(username):\(password)"
        
        guard let credentialsData = credentials.data(using: .utf8) else {
            print("❌ Error: No se pudo convertir credenciales a Data")
            return nil
        }
        
        // Obtener SecKey de la llave pública
        guard let publicKey = getPublicKey(from: publicKeyPEM) else {
            print("❌ Error: No se pudo obtener la llave pública")
            return nil
        }
        
        // Encriptar con RSA
        guard let encryptedData = encrypt(data: credentialsData, publicKey: publicKey) else {
            print("❌ Error: No se pudo encriptar los datos")
            return nil
        }
        
        // Convertir a base64
        let base64String = encryptedData.base64EncodedString()
        
#if DEBUG
        print("✅ Credenciales encriptadas exitosamente")
        print("📏 Longitud base64: \(base64String.count)")
#endif
        
        return base64String
    }
    
    // MARK: - Private Helper Methods
    
    /// Obtiene SecKey desde string PEM
    private static func getPublicKey(from pemString: String) -> SecKey? {
        // Remover headers y footers del PEM
        let pemBody = pemString
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Decodificar de base64
        guard let keyData = Data(base64Encoded: pemBody) else {
            print("❌ Error: No se pudo decodificar base64 del PEM")
            return nil
        }
        
        // Atributos de la llave
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(
            keyData as CFData,
            attributes as CFDictionary,
            &error
        ) else {
            if let error = error?.takeRetainedValue() {
                print("❌ Error creando SecKey: \(error)")
            }
            return nil
        }
        
        return secKey
    }
    
    /// Encripta datos usando la llave pública RSA
    private static func encrypt(data: Data, publicKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        
        guard let encryptedData = SecKeyCreateEncryptedData(
            publicKey,
            .rsaEncryptionPKCS1, // Algoritmo PKCS1 para compatibilidad con OpenSSL
            data as CFData,
            &error
        ) as Data? else {
            if let error = error?.takeRetainedValue() {
                print("❌ Error encriptando: \(error)")
            }
            return nil
        }
        
        return encryptedData
    }
}

// MARK: - Alternative Implementation (sin llave real)

extension RSAEncryption {
    /// Método temporal para testing sin llave real
    /// IMPORTANTE: Reemplazar con encriptación real antes de producción
    static func mockEncryptCredentials(username: String, password: String) -> String {
        let credentials = "\(username):\(password)"
        let data = credentials.data(using: .utf8) ?? Data()
        return data.base64EncodedString()
    }
    
    /// Desencripta credenciales en formato mock (base64 simple)
    /// - Parameter encryptedCredentials: Credenciales en base64
    /// - Returns: String desencriptado en formato "usuario:password" o nil
    static func mockDecrypt(encryptedCredentials: String) -> String? {
        guard let data = Data(base64Encoded: encryptedCredentials),
              let decoded = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        // Verificar que tenga formato correcto "usuario:password"
        let parts = decoded.components(separatedBy: ":")
        guard parts.count == 2 else {
            return nil
        }
        
        return decoded
    }
}
