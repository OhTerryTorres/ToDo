//
//  TaskTableViewDataSource.swift
//  ToDo
//
//  Created by TerryTorres on 4/18/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskTableViewDataSource {
    
    let controller : TaskTableViewController
    var networkCoordinator : NetworkCoordinator!
    var buttonManager : ButtonManager!
    var tasks : [Task] = []
    var completedTasksHidden = false
    
    
    // MARK: - Init and setup
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        let coreService = CoreService()
        self.tasks = coreService.getTasks()

        self.buttonManager = ButtonManager(controller: controller, dataSource: self)
        self.networkCoordinator = NetworkCoordinator(dataSource: self)
        
        setUpNotifications()
    }
    
    private func setUpNotifications() {
        // Add observer, notified in App Delegate's applicationDidBecomeActive
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("refresh"), object: nil)
        // Add observer, notified in App Delegate's applicationDidEnterBackground
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: Notification.Name("saveData"), object: nil)
        // Add observer, notified in TaskTableVieCell's completedButtonAction
        NotificationCenter.default.addObserver(self, selector: #selector(toggleTaskCompletion), name: Notification.Name("toggleTaskCompletion"), object: nil)
    }
    
    
    // MARK: - Data altering methods
    
    func update(method: ReloadMethod = .full) {
        controller.reload(method: method)
    }
    
    func delete(taskAtIndex index: Int) {
        let task = tasks.remove(at: index)
        let apiService = APIService(responseHandler: nil, catcher: networkCoordinator)
        apiService.delete(task: task, forUser: UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as! String)
    }
    
    // Called from TaskTableViewCell when a user marks a task as completed
    @objc func toggleTaskCompletion(_ notification: Notification) {
        guard let tag = notification.userInfo?["tag"] as? Int else { return }
        let task = self.tasks[tag]
        task.userCompleted = task.userCompleted == nil ? USER_ID : nil  // Add your ID if you completed it
        task.dateCompleted = task.userCompleted == nil ? nil : Date() // Add current date if completed
        
        // Update cell appearance
        if let completion = notification.userInfo?["completion"] as? (TaskTableViewCellStyle) -> Void {
            let style = TaskTableViewCellStyle(task: task)
            completion(style)
        }
        
        // Update task's completed status in database
        let apiService = APIService(responseHandler: nil, catcher: networkCoordinator)
        apiService.set(task: task, forUser: UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as! String)
    }
    
    
    // MARK: - Data persistence
    
    // Called on entering foreground OR on pulling down on the tableview
    @objc func refresh() {
        // Try submitting previously failed task insert and set requests
        self.networkCoordinator.retryFailedRequests() {
            
            // Synchronize local tasks with remote tasks
            guard let username = self.networkCoordinator.currentUser else { return }
            self.networkCoordinator.getDataFromAPI(forUser: username) {
                
                // Remove refresh indicator
                self.controller.refreshControl?.endRefreshing()
                
                // Acknowledge push notifications for this device and prepare to receive new ones
                self.networkCoordinator.acknowledgeNotification(forUser: username)
                
            }
        }
    }
    
    // Called on entering background or termination
    @objc func saveData() {
        let coreService = CoreService()
        coreService.syncTasksToCoreData(tasks: tasks)
    }
    
    
}
