//
//  MockNetworkService.swift
//  SocioInfonavit
//
//  Created by luisr on 13/02/26.
//

import Foundation

/*
 CONFIGURACIÓN DE ENTORNO
 
 
 PARA CAMBIAR ENTRE MOCK Y PRODUCCIÓN:
 Cambia el valor de `useMockData` abajo.
 
 1. DESARROLLO (Mock):
 static let useMockData: Bool = true
 
 2. PRODUCCIÓN (API Real):
 static let useMockData: Bool = false
 (Requiere llave RSA configurada en RSAEncryption.swift)
 
 LAS CREDENCIALES PARA TESTING :
 (Solo cuando useMockData = true)
 
 
 ✅ LOGIN EXITOSO:
 61917612998 / Contrasena01
 61998018420 / Contrasena02
 
 ❌ CREDENCIALES INCORRECTAS:
 Cualquier combinación no registrada arriba
 
 🔴 ERROR DE SERVIDOR (500):
 61900000000 / ServerError
 
 ⏱️ TIMEOUT:
 61922222222 / Timeout0000
 
 📡 SIN INTERNET:
 Desactiva WiFi/datos en el dispositivo
 (La detección es REAL usando NWPathMonitor)
 */

/// Configuración global de red
struct NetworkConfiguration {
    
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
