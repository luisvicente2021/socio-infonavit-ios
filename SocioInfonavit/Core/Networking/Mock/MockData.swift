//
//  MockData.swift
//  SocioInfonavit
//
//  Created by luisr on 13/02/26.
//
import Foundation

struct MockData {
    
    // MARK: - Valid Credentials (según documento Nextia)
    
    struct ValidCredential {
        let username: String
        let password: String
        let scenario: CredentialScenario
    }
    
    enum CredentialScenario {
        case success
        case serverError
        case timeout
    }
    
    /// Credenciales válidas con diferentes comportamientos
    static let validCredentials: [ValidCredential] = [
        // Usuarios del documento Nextia - Login EXITOSO
        ValidCredential(username: "61917612998", password: "Contrasena01", scenario: .success),
        ValidCredential(username: "61998018420", password: "Contrasena02", scenario: .success),
        
        // Usuario para probar error de servidor
        ValidCredential(username: "61900000000", password: "ServerError", scenario: .serverError),
        
        // Usuario para probar timeout
        ValidCredential(username: "61922222222", password: "Timeout0000", scenario: .timeout)
    ]
    
    /// Valida si las credenciales son correctas y retorna el escenario
    static func validateCredentials(username: String, password: String) -> CredentialScenario? {
        return validCredentials.first(where: {
            $0.username == username && $0.password == password
        })?.scenario
    }
    
    // MARK: - Mock Benevits Response
    
    static func createBenevitsResponse() -> BenevitsResponse {
        // Crear allies (empresas)
        let devlynAlly = Ally(
            id: 1,
            name: "Devlyn",
            logoFullPath: "https://via.placeholder.com/200x100/0066CC/FFFFFF?text=Devlyn",
            miniLogoFullPath: "https://via.placeholder.com/100x50/0066CC/FFFFFF?text=Devlyn"
        )
        
        let rappiAlly = Ally(
            id: 2,
            name: "Rappi",
            logoFullPath: "https://via.placeholder.com/200x100/FF6B00/FFFFFF?text=Rappi",
            miniLogoFullPath: "https://via.placeholder.com/100x50/FF6B00/FFFFFF?text=Rappi"
        )
        
        let izziAlly = Ally(
            id: 3,
            name: "Izzi",
            logoFullPath: "https://via.placeholder.com/200x100/00A651/FFFFFF?text=izzi",
            miniLogoFullPath: "https://via.placeholder.com/100x50/00A651/FFFFFF?text=izzi"
        )
        
        let xboxAlly = Ally(
            id: 4,
            name: "Xbox",
            logoFullPath: "https://via.placeholder.com/200x100/107C10/FFFFFF?text=XBOX",
            miniLogoFullPath: "https://via.placeholder.com/100x50/107C10/FFFFFF?text=XBOX"
        )
        
        // Benevits locked
        let locked: [Benevit] = [
            Benevit(
                id: 1,
                name: "20% en lentes Devlyn",
                description: "20% de descuento en lentes oftálmicos y lentes de sol",
                vectorFullPath: "https://via.placeholder.com/300x150/EC5056/FFFFFF?text=Devlyn+20%25",
                ally: nil,
                category: "Salud",
                expirationDate: "2024-12-31"
            ),
            Benevit(
                id: 2,
                name: "Xbox Game Pass Ultimate",
                description: "3 meses de Xbox Game Pass Ultimate con 25% de descuento",
                vectorFullPath: "https://via.placeholder.com/300x150/EC5056/FFFFFF?text=Xbox+Pass",
                ally: nil,
                category: "Entretenimiento",
                expirationDate: "2024-11-30"
            ),
            Benevit(
                id: 3,
                name: "Rappi Prime gratis",
                description: "30 días de Rappi Prime sin costo para socios",
                vectorFullPath: "https://via.placeholder.com/300x150/EC5056/FFFFFF?text=Rappi+Prime",
                ally: nil,
                category: "Servicios",
                expirationDate: "2024-10-31"
            )
        ]
        
        // Benevits unlocked
        let unlocked: [Benevit] = [
            Benevit(id: 4, name: "15% en armazones y micas", description: "Descuento especial en toda la línea de armazones y micas oftálmicas", vectorFullPath: nil, ally: devlynAlly, category: "Salud", expirationDate: "2024-12-31"),
            Benevit(id: 5, name: "Internet 100 Mbps con descuento", description: "Contrata Izzi 100 Mbps con 20% de descuento durante 6 meses", vectorFullPath: nil, ally: izziAlly, category: "Telecomunicaciones", expirationDate: "2024-11-15"),
            Benevit(id: 6, name: "Xbox Series S con ahorro", description: "Consola Xbox Series S con 15% de descuento y meses sin intereses", vectorFullPath: nil, ally: xboxAlly, category: "Electrónicos", expirationDate: "2024-10-31"),
            Benevit(id: 7, name: "Envíos gratis en Rappi", description: "Envíos gratis ilimitados durante todo el mes con Rappi Prime", vectorFullPath: nil, ally: rappiAlly, category: "Servicios", expirationDate: "2024-12-31"),
            Benevit(id: 8, name: "Examen de la vista gratis", description: "Examen de la vista sin costo con la compra de armazón", vectorFullPath: nil, ally: devlynAlly, category: "Salud", expirationDate: "2024-09-30"),
            Benevit(id: 9, name: "Rappi Turbo sin costo", description: "Entregas ultra rápidas sin costo adicional por 60 días", vectorFullPath: nil, ally: rappiAlly, category: "Servicios", expirationDate: "2024-11-30"),
            Benevit(id: 10, name: "Micas transition gratis", description: "Micas fotocromáticas sin costo extra en armazones seleccionados", vectorFullPath: nil, ally: devlynAlly, category: "Salud", expirationDate: "2024-12-15"),
            Benevit(id: 11, name: "Xbox Game Pass 3 meses", description: "3 meses de acceso a más de 100 juegos con Game Pass", vectorFullPath: nil, ally: xboxAlly, category: "Entretenimiento", expirationDate: "2024-10-20"),
            Benevit(id: 12, name: "Internet fibra óptica 200 Mbps", description: "Upgrade a 200 Mbps fibra óptica con instalación gratis", vectorFullPath: nil, ally: izziAlly, category: "Telecomunicaciones", expirationDate: "2024-11-25"),
            Benevit(id: 13, name: "Rappi Restaurantes 2x1", description: "2x1 en restaurantes seleccionados todos los martes", vectorFullPath: nil, ally: rappiAlly, category: "Alimentos", expirationDate: "2024-12-20"),
            Benevit(id: 14, name: "Lentes de contacto con descuento", description: "20% en lentes de contacto mensuales y desechables", vectorFullPath: nil, ally: devlynAlly, category: "Salud", expirationDate: "2024-10-15"),
            Benevit(id: 15, name: "Control Xbox sin costo", description: "Control inalámbrico gratis en compra de Xbox Series", vectorFullPath: nil, ally: xboxAlly, category: "Accesorios", expirationDate: "2024-11-10")
        ]
        
        return BenevitsResponse(locked: locked, unlocked: unlocked)
    }
    
    // MARK: - Mock Search Response
    
    static func createSearchResponse() -> SearchResponse {
        let xboxAlly = Ally(
            id: 1,
            name: "Microsoft",
            logoFullPath: "https://via.placeholder.com/200x100/0078D4/FFFFFF?text=Microsoft",
            miniLogoFullPath: "https://via.placeholder.com/100x50/0078D4/FFFFFF?text=MS"
        )
        
        let benevits: [Benevit] = [
            Benevit(
                id: 1,
                name: "Xbox Game Pass Ultimate",
                description: "3 meses de Xbox Game Pass Ultimate con descuento",
                vectorFullPath: nil,
                ally: xboxAlly,
                category: "Gaming",
                expirationDate: "2024-12-31"
            ),
            Benevit(
                id: 2,
                name: "Xbox Series S",
                description: "Consola Xbox Series S con 15% de descuento",
                vectorFullPath: nil,
                ally: xboxAlly,
                category: "Consolas",
                expirationDate: "2024-11-30"
            )
        ]
        
        return SearchResponse(benevits: benevits)
    }
    
    // MARK: - Mock Headers
    
    static var mockHeaders: [AnyHashable: Any] {
        return [
            "Authorization": "Bearer mock-jwt-token-12345",
            "Content-Type": "application/json"
        ]
    }
}
