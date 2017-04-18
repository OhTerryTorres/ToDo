//
//  AuthenticationDelegate.swift
//  ToDo
//
//  Created by TerryTorres on 4/17/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

class AuthenticationDelegate: APIResponseHandler, AuthenticationResponseHandler {
    
    var currentUser : String? = nil
    var controller : TaskTableViewController
    var alertDelegate : AuthenticationAlertDelegate!
        
    init(forController controller: TaskTableViewController) {
        self.controller = controller
        self.alertDelegate = AuthenticationAlertDelegate(forController: self)
        checkSession()
    }
    
    func checkSession() {
        if let user = UserDefaults.standard.object(forKey: UserKeys.user.rawValue) as? String {
            currentUser = user
        } else {
            presentLoginAlert()
        }
    }
    
    func presentLoginAlert() {
        self.controller.present(alertDelegate.loginAlertController, animated: true, completion: nil)
    }
    
    func presentRegisterAlert() {
        self.controller.present(alertDelegate.registerAlertController, animated: true, completion: nil)
    }
    
    func login(email: String, password: String) {
        currentUser = email
        let authenticator = AuthenticationService(withController: self)
        authenticator.login(email: email, password: password)
    }
    
    func register(email: String, password: String) {
        currentUser = email
        let authenticator = AuthenticationService(withController: self)
        authenticator.register(email: email, password: password)
    }
    
    func handleLoginResponse(status : String, message: String) {
        switch status {
            case "success":
                UserDefaults.standard.set(currentUser, forKey: UserKeys.user.rawValue)
                getDataFromRemoteServer()
            case "error":
                DispatchQueue.main.async {
                    self.alertDelegate.loginAlertController.message = message
                    self.presentLoginAlert()
                }
            default:
                return
        }
    }
    
    func handleRegisterResponse(status : String, message: String) {
        switch status {
        case "success":
            UserDefaults.standard.set(currentUser, forKey: UserKeys.user.rawValue)
            getDataFromRemoteServer()
        case "error":
            DispatchQueue.main.async {
                self.alertDelegate.registerAlertController.message = message
                self.presentRegisterAlert()
            }
        default:
            return
        }
    }
    
    func getDataFromRemoteServer() {
        guard let _ = currentUser else { return }
        
        // Look for new tasks in database
        let apiService = APIService(withController: self)
        apiService.getTasks()
        print("refresh completed")
        controller.refreshControl?.endRefreshing()
    }
    
    // Called from a URL Session data task, so can be assume to
    // alway run on a background thread.
    func handleAPIResponse(jsonArray: [[String : Any]]) {
        let coreService = CoreService()
        controller.dataSource.tasks = coreService.integrateTasks(tasks: controller.dataSource.tasks, withJSONArray: jsonArray)
        
        DispatchQueue.main.async {
            self.controller.tableView.reloadData()
        }
    }
    
    
    
}
