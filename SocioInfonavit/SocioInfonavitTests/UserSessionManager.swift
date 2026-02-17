//
//  UserSessionManager.swift
//  SocioInfonavit
//
//  Created by luisr on 14/02/26.
import XCTest
@testable import SocioInfonavit


final class MockSessionManager: UserSessionManaging {
    
    var savedToken: String?
    var activeSession: Bool = false
    
    func saveToken(_ token: String) {
        savedToken = token
        activeSession = true
    }
    
    func getToken() -> String? {
        return savedToken
    }
    
    func deleteToken() {
        savedToken = nil
        activeSession = false
    }
    
    func hasActiveSession() -> Bool {
        return activeSession
    }
    
    func logout() {
        deleteToken()
    }
}
