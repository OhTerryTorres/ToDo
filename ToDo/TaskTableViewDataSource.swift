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
    var completedTasksHidden = false
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        let coreService = CoreService()
        self.tasks = coreService.getTasks()
        
        for task in tasks {
            print(task.name)
            print(task.order)
        }
        
        self.networkCoordinator = NetworkCoordinator(dataSource: self)
        
        // Pull down tableview to refresh from remote store
        controller.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged )
        
        // Add observer, notified in App Delegate's applicationDidBecomeActive
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        // Add observer, notified in App Delegate's applicationDidEnterBackground
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "saveData"), object: nil)
        
        // Add login bar button to cotroller
        setUpTitleButton()
        setUpBarButtons()
    }
    
    func update(method: ReloadMethod = .full) {
        /* ----
        let coreService = CoreService()
        let predicate : NSPredicate? = completedTasksHidden ? NSPredicate(format: "userCompleted == nil") : nil
        tasks = coreService.getTasksSortedByDate(withPredicate: predicate)
        */
        controller.reload(method: method)
    }
    
    func delete(taskAtIndex index: Int) {
        let task = tasks.remove(at: index)
        let apiService = APIService()
        apiService.delete(task: task)
        /* ----
        let coreService = CoreService()
        coreService.delete(task: task)
        */
        update()
    }
    
    @objc func refresh() {
        networkCoordinator.getDataFromAPI() {
            self.controller.refreshControl?.endRefreshing()
        }
    }
    
    
    // Buttons - these should probably be refactored eslewhere
    
    func setUpTitleButton() {
        let loginButton = UIButton(type: .custom)
        loginButton.setTitleColor(GUEST_COLOR, for: .normal)
        loginButton.setTitleColor(.clear, for: .highlighted)
        let userName = UserDefaults.standard.object(forKey: UserKeys.user.rawValue) as? String ?? "To Do"
        loginButton.setTitle(userName, for: .normal)
        loginButton.showsTouchWhenHighlighted = true
        loginButton.frame = controller.navigationItem.titleView?.frame ?? CGRect(x: 0, y: 0, width: 100, height: 40)
        loginButton.addTarget(self, action: #selector(showLoginAlert), for: .touchUpInside)
        controller.navigationItem.titleView = loginButton
    }
    
    func setUpBarButtons() {
        controller.navigationItem.rightBarButtonItem = editBarButton
        controller.navigationItem.leftBarButtonItem = hideCompletedBarButton
    }
    
    var hideCompletedBarButton : UIBarButtonItem {
        let hideCompletedButton = UIBarButtonItem(image: #imageLiteral(resourceName: "completionTrue"), style: .plain, target: self, action: #selector(hideCompletedTasks))
        return hideCompletedButton
    }
    var editBarButton : UIBarButtonItem {
        let editButton = UIBarButtonItem(image: #imageLiteral(resourceName: "editFalse"), style: .plain, target: self, action: #selector(setEditing))
        return editButton
    }
    
    @objc func showLoginAlert() {
        networkCoordinator.authenticationAlertHandler.present(alertController: networkCoordinator.authenticationAlertHandler.loginAlertController)
    }
    
    @objc func hideCompletedTasks() {
        completedTasksHidden = completedTasksHidden ? false : true
        let image : UIImage = completedTasksHidden ? #imageLiteral(resourceName: "completionFalse") : #imageLiteral(resourceName: "completionTrue")
        controller.navigationItem.leftBarButtonItem?.image = image
        update()
    }
    
    @objc func setEditing() {
        let editing = controller.tableView.isEditing ? false : true
        let image : UIImage = controller.tableView.isEditing ? #imageLiteral(resourceName: "editFalse") : #imageLiteral(resourceName: "editTrue")
        controller.navigationItem.rightBarButtonItem?.image = image
        controller.tableView.setEditing(editing, animated: true)
    }
}
