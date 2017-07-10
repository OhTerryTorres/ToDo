//
//  TaskTableViewDataSource.swift
//  ToDo
//
//  Created by TerryTorres on 4/18/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskDataManager : TaskDataSource {
    
    let controller : TaskTableViewController
    var failedRequestCatcher : FailedRequestCatcher!
    var authenticationHandler : AuthenticationHandler!

    var tasks : [Task] = []
    
    // MARK: - Init and setup
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        let coreService = CoreService()
        self.tasks = coreService.getTasks()

        let networkCoordinator = NetworkCoordinator(dataManager: self)
        self.failedRequestCatcher = networkCoordinator
        self.authenticationHandler = networkCoordinator
                
        setUpNotifications()
    }
    
    private func setUpNotifications() {
        // Add observer, notified in App Delegate's applicationDidBecomeActive
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("refresh"), object: nil)
        // Add observer, notified in App Delegate's applicationDidEnterBackground
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: Notification.Name("saveData"), object: nil)
    }
    
    
    // MARK: - Data persistence
    
    // Called on entering foreground OR on pulling down on the tableview
    @objc func refresh() {
        // Try submitting previously failed task insert and set requests
        self.failedRequestCatcher.retryFailedRequests() {
            
            // Synchronize local tasks with remote tasks
            guard let username = self.authenticationHandler.currentUser else { return }
            self.authenticationHandler.getDataFromAPI(forUser: username) {
                
                // Remove refresh indicator
                self.controller.refreshControl?.endRefreshing()
                
                // Acknowledge push notifications for this device and prepare to receive new ones
                self.authenticationHandler.acknowledgeNotification(forUser: username)
                
            }
        }
    }
    
    // Called on entering background or termination
    @objc func saveData() {
        let coreService = CoreService()
        coreService.syncTasksToCoreData(tasks: tasks)
    }
    
    
}
