//
//  BenevitsResponse.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//
import Foundation

struct BenevitsResponse: Codable {
    let locked: [Benevit]
    let unlocked: [Benevit]
}

struct Benevit: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let vectorFullPath: String?
    let ally: Ally?
    let category: String?
    let expirationDate: String?
    
    var isLocked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case vectorFullPath = "vector_full_path"
        case ally
        case category
        case expirationDate = "expiration_date"
    }
    
    var imageURL: String? {
        if isLocked {
            return vectorFullPath
        } else {
            return ally?.miniLogoFullPath
        }
    }
}


struct Ally: Codable {
    let id: Int
    let name: String
    let logoFullPath: String?
    let miniLogoFullPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoFullPath = "logo_full_path"
        case miniLogoFullPath = "mini_logo_full_path"
    }
}


struct SearchResponse: Codable {
    let benevits: [Benevit]
}


extension Benevit {
    func withLockState(_ locked: Bool) -> Benevit {
        var copy = self
        copy.isLocked = locked
        return copy
    }
}


extension Benevit {
    static let mock = Benevit(
        id: 1,
        name: "Descuento en Xbox",
        description: "20% de descuento en consolas Xbox Series X",
        vectorFullPath: "https://example.com/vector.png",
        ally: Ally.mock,
        category: "Electrónicos",
        expirationDate: "2024-12-31"
    )
    
    static let mockLocked = Benevit(
        id: 2,
        name: "Descuento en Muebles",
        description: "15% de descuento en muebles para el hogar",
        vectorFullPath: "https://example.com/vector2.png",
        ally: nil,
        category: "Hogar",
        expirationDate: "2024-11-30"
    ).withLockState(true)
}

extension Ally {
    static let mock = Ally(
        id: 1,
        name: "Microsoft",
        logoFullPath: "https://example.com/logo.png",
        miniLogoFullPath: "https://example.com/mini-logo.png"
    )
}
