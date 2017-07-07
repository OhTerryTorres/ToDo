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

class NetworkCoordinator: APIResponseHandler, AuthenticationResponseHandler, FailedRequestCatcher {
    
    var currentUser : String? = nil
    var dataSource : TaskTableViewDataSource
    var authenticationAlertHandler : AuthenticationAlertHandler!
    var failedRequestPackages : [(urlRequest: URLRequest, username: String, method: APIService.PostMethod)] = []
        
    init(dataSource: TaskTableViewDataSource) {
        self.dataSource = dataSource
        self.authenticationAlertHandler = AuthenticationAlertHandler(coordinator: self)
        checkSession()
    }
    
    // On launch, log in automatically or ask user for credentials
    private func checkSession() {
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
    
    // Used to get remote tasks on 1) a successful login or 2) a succesful refresh
    func getDataFromAPI(forUser username: String, completion:(()->())? = nil) {
        // Look for new tasks in database
        let apiService = APIService(responseHandler: self)
        apiService.getTasks(forUser: username)
        
        DispatchQueue.main.async {
            completion?()
        }
        
    }
    
    func acknowledgeConnection(forUser username: String) {
        self.dataSource.buttonManager.setUpTitleButton(forUser: username)
        self.acknowledgeNotification(forUser: username)
    }
    
    // Used to acknowlege any push notification for this device on 1) a successful login or 2) a succesful refresh
    func acknowledgeNotification(forUser username: String) {
        guard let deviceToken = UserDefaults.standard.object(forKey: UserKeys.deviceToken.rawValue) as? String else { return }
        let pns = PushNotificationService()
        pns.acknowledgeNotification(username: username, token: deviceToken)
    }
    
    
}
