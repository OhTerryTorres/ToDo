//
//  AuthenticationResponseHandler.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation


protocol AuthenticationResponseHandler: class {
    var dataSource : TaskTableViewDataSource { get set }
    var currentUser : String? { get set }
    var authenticationAlertHandler : AuthenticationAlertHandler! { get set }
    
    // Handle JSON dict from AuthenticationService
    func handleAuthenticationResponse(username: String, status: String, message: String, completion:(()->())?)
    func presentAlertOnMainQueue(message: String)
    func getDataFromAPI(completion:(()->())?)
    
}

extension AuthenticationResponseHandler {
    
    
     func handleAuthenticationResponse(username: String, status: String, message: String, completion:(()->())? = nil) {
        switch status {
        case "success":
            if currentUser != nil && currentUser != username {
                // If logging in as new user, erase records in local store
                let coreService = CoreService()
                coreService.deleteAllTasks()
                
                dataSource.tasks = []
            }
            currentUser = username
            UserDefaults.standard.set(currentUser, forKey: UserKeys.username.rawValue)
            
            // If user agreed to receive notifications, add their device token to user table.
            if let token = UserDefaults.standard.object(forKey: UserKeys.deviceToken.rawValue) as? String {
                let pns = PushNotificationService()
                pns.uploadDeviceToken(token: token, forUser: username)
            }
            
            getDataFromAPI(completion: nil)
        case "error":
            self.presentAlertOnMainQueue(message: message)
        default:
            return
        }
        completion?()
    }
    
    func presentAlertOnMainQueue(message: String) {
        DispatchQueue.main.async {
            self.authenticationAlertHandler.present(message: message)
        }
        
    }
    
}
