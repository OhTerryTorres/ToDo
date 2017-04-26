//
//  NetworkCoordinator.swift
//  ToDo
//
//  Created by TerryTorres on 4/17/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

/*
 1. On creation, coordinator checks what the last username was
  1a. If the user is found, they are authenticated automatically (no token yet) and remote data is fetched
  1b. If there is no user yet, the Authentication Alert process begins
 2. When the user logs in or registers successfully, remote data is fetched.
 3. When new data is fetched, it is integrated with local data.
 4. When that's done, the data source is called for an update.
 
 
*/

class NetworkCoordinator: APIResponseHandler, AuthenticationResponseHandler {
    
    var currentUser : String? = nil
    var dataSource : TaskTableViewDataSource
    var authenticationAlertHandler : AuthenticationAlertHandler!
        
    init(dataSource: TaskTableViewDataSource) {
        self.dataSource = dataSource
        self.authenticationAlertHandler = AuthenticationAlertHandler(coordinator: self)
        checkSession()
    }
    
    func checkSession() {
        if let user = UserDefaults.standard.object(forKey: UserKeys.user.rawValue) as? String {
            currentUser = user
            getDataFromRemoteServer()
        } else {
            authenticationAlertHandler.present()
        }
    }
    
    func authenticate(user: String, password: String, method: AuthenticationMethod) {
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
                getDataFromRemoteServer()
            case "error":
                DispatchQueue.main.async {
                    self.authenticationAlertHandler.present(message: message)
                }
            default:
                return
        }
    }

    
    func getDataFromRemoteServer(completion:(()->())? = nil) {
        guard let _ = currentUser else { return }
        
        // Look for new tasks in database
        let apiService = APIService(responseHandler: self)
        apiService.getTasks()
        
        completion?()
    }
    
    // Called from a URL Session data task, so can be assumed to
    // alway run on a background thread.
    func handleAPIResponse(jsonArray: [[String : Any]]) {
        let coreService = CoreService()
        coreService.integrateTasks(tasks: dataSource.tasks, withJSONArray: jsonArray)
        
        DispatchQueue.main.async {
            self.dataSource.update()
        }
    }
    
    
    
}
