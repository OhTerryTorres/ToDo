//
//  AuthenticationResponseHandler.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation


protocol AuthenticationHandler: class {
    var dataSource : TaskDataSource { get set }
    var currentUser : String? { get set }
    var authenticationAlertHandler : AuthenticationAlertHandler! { get set }
    
    // On launch, log in automatically or ask user for credentials
    func checkSession()
    
    // Handle JSON dict from AuthenticationService
    func handleAuthenticationResponse(username: String, status: String, message: String, completion:(()->())?)
    
    // Redisplay alert in case of error
    func presentAlertOnMainQueue(message: String)
    
    // Get tasks on success (defined in NetworkCoordinator)
    func getDataFromAPI(forUser username: String, completion:(()->())?)
    
    // Updates title to username and acknowledge notifcations
    func acknowledgeConnection(forUser: String)
    // Used to acknowlege any push notification for this device on 1) a successful login or 2) a succesful refresh
    func acknowledgeNotification(forUser username: String)
}

extension AuthenticationHandler {
    
    func checkSession() {
        if let username = UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as? String {
            currentUser = username
            // Get online, baby!
            getDataFromAPI(forUser: username) {
                self.acknowledgeConnection(forUser: username)
            }
        } else {
            authenticationAlertHandler.present()
        }
    }
    
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
            
            getDataFromAPI(forUser: username) {
                self.acknowledgeConnection(forUser: username)
            }
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
    
    func acknowledgeConnection(forUser username: String) {
        self.dataSource.acknowledgeConnection(forUser: username)
        self.acknowledgeNotification(forUser: username)
    }
    
    func acknowledgeNotification(forUser username: String) {
        guard let deviceToken = UserDefaults.standard.object(forKey: UserKeys.deviceToken.rawValue) as? String else { return }
        let pns = PushNotificationService()
        pns.acknowledgeNotification(username: username, token: deviceToken)
    }
    
}
