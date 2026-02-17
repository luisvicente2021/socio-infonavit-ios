//
//  LoginStrings.swift
//  SocioInfonavit
//
//  Created by luisr on 15/02/26.
//


import Foundation

struct LoginStrings {
    
    let welcomeTitle = NSLocalizedString("login.title", comment: "")
    let welcomeSubtitle = NSLocalizedString("login.subtitle", comment: "")
    
    let usernamePlaceholder = NSLocalizedString("login.username.placeholder", comment: "")
    let passwordPlaceholder = NSLocalizedString("login.password.placeholder", comment: "")
    
    let usernameError = NSLocalizedString("login.error.username", comment: "")
    let passwordError = NSLocalizedString("login.error.password", comment: "")
    
    let loginButton = NSLocalizedString("login.button", comment: "")
    
    let invalidCredentials = NSLocalizedString("login.error.unauthorized", comment: "")
    let noInternet = NSLocalizedString("login.error.noInternet", comment: "")
    let timeout = NSLocalizedString("login.error.timeout", comment: "")
    let tokenError = NSLocalizedString("login.error.encryption", comment: "")
    let authTokenError = NSLocalizedString("login.authTokenError", comment: "")
    let loginFailed = NSLocalizedString("login.failed", comment: "")
    let unexpectedError = NSLocalizedString("login.error.unexpected", comment: "")
    
    func serverError(code: Int) -> String {
        return String(format: NSLocalizedString("login.error.server", comment: ""), code)
    }
}
