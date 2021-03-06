//
//  TaskTableViewDataSource.swift
//  ToDo
//
//  Created by TerryTorres on 4/18/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskDataManager : TaskDataSource, TaskDataSynchronizer {
    
    let controller : TaskTableViewController
    var failedRequestCatcher : FailedRequestCatcher!
    var authenticationHandler : AuthenticationHandler!

    var tasks : [Task] = []
    
    // MARK: - Init and setup
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        let coreService = CoreService()
        self.tasks = coreService.getTasks()

        let networkCoordinator = NetworkCoordinator(dataSource: self)
        self.failedRequestCatcher = networkCoordinator
        self.authenticationHandler = networkCoordinator
        
        // Pass self to app delegate for persistence methods
        (UIApplication.shared.delegate as! AppDelegate).taskDataSynchronizer = self
        setUpRefreshControl()
    }
    
    private func setUpRefreshControl() {
        // Pull down tableview to refresh from remote store
        controller.refreshControl?.addTarget(self, action: #selector(refreshWrapper), for: UIControlEvents.valueChanged )
        controller.refreshControl?.tintColor = USER_COLOR
    }
    
    func deleteCompletedTasks() {
        tasks = tasks.filter { $0.userCompleted == nil }
        update()
        DispatchQueue.global(qos: .background).async {
            let predicate = NSPredicate(format: "userCompleted != nil")
            let coreService = CoreService()
            coreService.deleteAllTasks(withPredicate: predicate)
            
            let apiService = APIService(responseHandler: nil, catcher: self.failedRequestCatcher)
            apiService.deleteCompleted(forUser: UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as! String)
        }
    }
    
    @objc func refreshWrapper() {
        refresh()
    }
    
    // MARK: - TaskDataSynchronizer Protocol
    
    // Called on entering foreground OR on pulling down on the tableview
    func refresh() {
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
    
    
    
    
}
