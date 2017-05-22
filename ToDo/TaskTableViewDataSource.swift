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
    var deleteToolbar : UIToolbar?
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        let coreService = CoreService()
        self.tasks = coreService.getTasks()

        self.networkCoordinator = NetworkCoordinator(dataSource: self)
        
        // Pull down tableview to refresh from remote store
        controller.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged )
        controller.refreshControl?.tintColor = GUEST_COLOR
        
        // Add observer, notified in App Delegate's applicationDidBecomeActive
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        // Add observer, notified in App Delegate's applicationDidEnterBackground
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: NSNotification.Name(rawValue: "saveData"), object: nil)
        
        // Add login bar button to cotroller
        setUpTitleButton()
        setUpBarButtons()
        setUpDeleteToolbar()
    }
    
    func update(method: ReloadMethod = .full) {
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
    }
    
    @objc func refresh() {
        networkCoordinator.getDataFromAPI() {
            self.controller.refreshControl?.endRefreshing()
        }
    }
    
    @objc func saveData() {
        let coreService = CoreService()
        coreService.syncTasksToCoreData(tasks: tasks)
    }
    
    
    
    // Buttons - these should probably be refactored eslewhere
    
    func setUpTitleButton() {
        let loginButton = UIButton(type: .custom)
        loginButton.setTitleColor(GUEST_COLOR, for: .normal)
        loginButton.setTitleColor(.clear, for: .highlighted)
        let user = UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as? String ?? "To Do"
        loginButton.setTitle(user, for: .normal)
        loginButton.showsTouchWhenHighlighted = true
        loginButton.frame = controller.navigationItem.titleView?.frame ?? CGRect(x: 0, y: 0, width: 100, height: 40)
        loginButton.addTarget(self, action: #selector(showLoginAlert), for: .touchUpInside)
        controller.navigationItem.titleView = loginButton
    }
    
    func setUpBarButtons() {
        controller.navigationItem.rightBarButtonItem = editBarButton
        controller.navigationItem.leftBarButtonItem = hideCompletedBarButton
    }
    
    func setUpDeleteToolbar() {
        let button = UIBarButtonItem(title: "Delete Completed Tasks", style: .plain, target: self, action: #selector(deleteCompletedTasks))
        self.deleteToolbar = UIToolbar(frame: CGRect(x: 0, y: controller.view.frame.height, width: controller.view.frame.width, height: 44))
        self.deleteToolbar?.items = [button]
        self.deleteToolbar?.isHidden = true
        self.deleteToolbar?.tintColor = USER_COLOR
        if let superview = self.controller.view.superview {
            superview.addSubview(deleteToolbar!)
        } else {
            self.controller.view.addSubview(deleteToolbar!)
        }
    }
    
    var hideCompletedBarButton : UIBarButtonItem {
        let button = UIBarButtonItem(customView: hideCompletedCustomView(image: #imageLiteral(resourceName: "completionTrue")))
        return button
    }
    func hideCompletedCustomView(image: UIImage) -> UIImageView {
        let view = UIImageView(image: image)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideCompletedTasks))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteCompletedTasks))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(longGesture)
        return view
    }
    
    var editBarButton : UIBarButtonItem {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "editFalse"), style: .plain, target: self, action: #selector(setEditing))
        return button
    }
    
    @objc func showLoginAlert() {
        networkCoordinator.authenticationAlertHandler.present(alertType: .login)
    }
    
    @objc func hideCompletedTasks() {
        completedTasksHidden = completedTasksHidden ? false : true
        let image : UIImage = completedTasksHidden ? #imageLiteral(resourceName: "completionFalse") : #imageLiteral(resourceName: "completionTrue")
        controller.navigationItem.leftBarButtonItem?.customView = hideCompletedCustomView(image: image)
        update()
    }
    
    @objc func deleteCompletedTasks() {
        controller.present(deleteAlert, animated: true)
    }
    
    var deleteAlert: UIAlertController {
        let alertController = UIAlertController(title: nil, message: "Delete all completed tasks?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Delete", style: .default, handler: {
            alert -> Void in
            self.tasks = self.tasks.filter { $0.userCompleted == nil }
            self.update()
            DispatchQueue.global(qos: .background).async {
                let predicate = NSPredicate(format: "userCompleted != nil")
                let coreService = CoreService()
                coreService.deleteAllTasks(withPredicate: predicate)
                
                let apiService = APIService()
                apiService.deleteCompleted()
            }            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    @objc func setEditing() {
        let editing = controller.tableView.isEditing ? false : true
        let image : UIImage = editing ? #imageLiteral(resourceName: "editFalse") : #imageLiteral(resourceName: "editTrue")
        
        controller.navigationItem.rightBarButtonItem?.image = image
        controller.tableView.setEditing(editing, animated: true)
        
        if let delete = deleteToolbar {
            let hidden = editing ? false : true
            let yOffset = editing ? delete.frame.height : -1 * delete.frame.height
            var frame = delete.frame
            frame.origin.y -= yOffset
            UIView.transition(with: delete, duration: 0.5, options: .curveEaseOut, animations: { _ in
                delete.frame = frame
            }, completion: nil)
            delete.isHidden = hidden
        }
        
        
    }
}
