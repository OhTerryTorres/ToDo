//
//  ButtonManager.swift
//  ToDo
//
//  Created by TerryTorres on 6/28/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class ButtonManager {
    
    let controller : TaskTableViewController
    let dataSource : TaskTableViewDataSource
    var deleteToolbar : UIToolbar?
    
    
    init(controller: TaskTableViewController, dataSource: TaskTableViewDataSource) {
        self.controller = controller
        self.dataSource = dataSource
        // Add login bar button to cotroller
        setUpTitleButton()
        setUpBarButtons()
        setUpDeleteToolbar()
    }
    
    
    func setUpTitleButton(forUser username: String? = nil) {
        let loginButton = UIButton(type: .custom)
        loginButton.setTitleColor(GUEST_COLOR, for: .normal)
        loginButton.setTitleColor(.clear, for: .highlighted)
        let user = username ?? "To Do"
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
        dataSource.networkCoordinator.authenticationAlertHandler.present(alertType: .login)
    }
    
    @objc func hideCompletedTasks() {
        dataSource.completedTasksHidden = dataSource.completedTasksHidden ? false : true
        let image : UIImage = dataSource.completedTasksHidden ? #imageLiteral(resourceName: "completionFalse") : #imageLiteral(resourceName: "completionTrue")
        controller.navigationItem.leftBarButtonItem?.customView = hideCompletedCustomView(image: image)
        self.dataSource.update()
    }
    
    @objc func deleteCompletedTasks() {
        controller.present(deleteAlert, animated: true)
    }
    
    var deleteAlert: UIAlertController {
        let alertController = UIAlertController(title: nil, message: "Delete all completed tasks?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Delete", style: .default, handler: {
            alert -> Void in
            self.dataSource.tasks = self.dataSource.tasks.filter { $0.userCompleted == nil }
            self.dataSource.update()
            DispatchQueue.global(qos: .background).async {
                let predicate = NSPredicate(format: "userCompleted != nil")
                let coreService = CoreService()
                coreService.deleteAllTasks(withPredicate: predicate)
                
                let apiService = APIService(responseHandler: nil, catcher: self.dataSource.networkCoordinator)
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
