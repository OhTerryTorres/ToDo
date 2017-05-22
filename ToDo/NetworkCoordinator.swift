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
        if let username = UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as? String {
            currentUser = username
            getDataFromAPI() {
            }
        } else {
            authenticationAlertHandler.present()
        }
    }
    
    func getDataFromAPI(completion:(()->())? = nil) {
        guard let username = currentUser else { completion?(); return }
        
        // Look for new tasks in database
        let apiService = APIService(responseHandler: self)
        apiService.getTasks(forUser: username)
        
        DispatchQueue.main.async {
            self.dataSource.setUpTitleButton()
        }
        
        completion?()
    }
    
    
}
