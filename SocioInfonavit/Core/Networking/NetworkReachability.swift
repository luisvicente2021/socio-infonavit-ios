//
//  NetworkTestingConfiguration.swift
//  SocioInfonavit
//
//  Created by luisr on 13/02/26.
//
import Foundation
import Network

final class NetworkReachability {
    
    static let shared = NetworkReachability()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
            
#if DEBUG
            print("Internet:", self?.isConnected == true ? "Disponible ✅" : "No disponible ❌")
#endif
        }
        
        monitor.start(queue: queue)
    }
}
