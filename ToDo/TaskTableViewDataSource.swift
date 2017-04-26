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
    var tasks : [Task] = []
    var hideTasks = false
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        let coreService = CoreService()
        self.tasks = coreService.getTasksSortedByDate()
        
        for task in tasks {
            print(task.name ?? "")
            print(task.order)
        }
        
        self.networkCoordinator = NetworkCoordinator(dataSource: self)
        
        // Pull down tableview to refresh from remote store
        controller.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged )
        // Add observer, notified in App Delegate's applicationDidBecomeActive 
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        // Add login bar button to cotroller
        setUpLoginBarButton()
        setUpRightBarButtons()
    }
    
    func update(method: ReloadMethod = .full) {
        let coreService = CoreService()
        let predicate : NSPredicate? = hideTasks ? NSPredicate(format: "userCompleted == nil") : nil
        tasks = coreService.getTasksSortedByDate(withPredicate: predicate)
        controller.reload(method: method)
    }
    
    func delete(task: Task) {
        let apiService = APIService()
        apiService.delete(task: task)
        
        let coreService = CoreService()
        coreService.delete(task: task)
        
        update()
    }
    
    @objc func refresh() {
        networkCoordinator.getDataFromRemoteServer() {
            self.controller.refreshControl?.endRefreshing()
        }
    }
    
    func setUpLoginBarButton() {
        let loginButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showLoginAlert))
        controller.navigationItem.leftBarButtonItem = loginButton
    }
    
    func setUpRightBarButtons() {
        controller.navigationItem.rightBarButtonItems = [editBarButton, hideCompletedBarButton]
    }
    
    var hideCompletedBarButton : UIBarButtonItem {
        let hideCompletedButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(hideCompletedTasks))
        return hideCompletedButton
    }
    var editBarButton : UIBarButtonItem {
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(setEditing))
        return editButton
    }
    
    @objc func showLoginAlert() {
        networkCoordinator.authenticationAlertHandler.present(alertController: networkCoordinator.authenticationAlertHandler.loginAlertController)
    }
    
    @objc func hideCompletedTasks() {
        hideTasks = hideTasks ? false : true
        update()
    }
    
    @objc func setEditing() {
        let editing = controller.tableView.isEditing ? false : true
        controller.tableView.setEditing(editing, animated: true)
    }
}
