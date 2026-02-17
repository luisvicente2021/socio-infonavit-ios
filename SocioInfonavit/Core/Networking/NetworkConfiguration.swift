//
//  MockNetworkService.swift
//  SocioInfonavit
//
//  Created by luisr on 13/02/26.
//

import Foundation

/// Configuración global de red
struct NetworkConfiguration {
    
    /// CAMBIAR AQUÍ para usar Mock o Real
    ///
    /// true  = Usa datos MOCK (para desarrollo/testing)
    /// false = Usa API REAL (requiere llave RSA)
    static let useMockData: Bool = true
    
    /// Delay simulado para mock (en segundos)
    static let mockDelay: TimeInterval = 0.5
    
    /// Crea el servicio de red configurado
    static func createService() -> NetworkService {
        let service = NetworkService.shared
        service.useMockData = useMockData
        service.mockDelay = mockDelay
        return service
    }
}
