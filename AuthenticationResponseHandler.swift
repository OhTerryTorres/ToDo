//
//  AuthenticationResponseHandler.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation


protocol AuthenticationResponseHandler {
    var currentUser : String? { get set }
    var authenticationAlertHandler : AuthenticationAlertHandler! { get set }
    
    // Handle JSON dict from AuthenticationService
    mutating func authenticate(user: String, password: String, method: AuthenticationMethod)
    func handleAuthenticationResponse(status: String, message: String)
    func getDataFromAPI(completion:(()->())?)
}

extension AuthenticationResponseHandler {
    
    mutating func authenticate(user: String, password: String, method: AuthenticationMethod) {
        if currentUser != nil && currentUser != user {
            // If logging in as new user, erase records in local store
            let coreService = CoreService()
            coreService.deleteAllTasks()
        }
        currentUser = user
        let authenticator = AuthenticationService(withController: self)
        authenticator.authenticate(user: user, password: password, method: method)
    }
    
    func handleAuthenticationResponse(status : String, message: String) {
        switch status {
        case "success":
            UserDefaults.standard.set(currentUser, forKey: UserKeys.user.rawValue)
            getDataFromAPI(completion: nil)
        case "error":
            DispatchQueue.main.async {
                self.authenticationAlertHandler.present(message: message)
            }
        default:
            return
        }
    }
    
}
