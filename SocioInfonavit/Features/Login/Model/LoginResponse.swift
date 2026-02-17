//
//  LoginResponse.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//


import Foundation

struct LoginResponse: Codable {
    let success: Bool
    let message: String?
    let data: UserData?
}

struct UserData: Codable {
    let id: Int?
    let name: String?
    let email: String?
}

struct EmptyResponse: Codable {
    let success: Bool?
    let message: String?
}
