//
//  ButtonManager.swift
//  ToDo
//
//  Created by TerryTorres on 6/28/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class ButtonManager: LoginButtonHandler, HideCompleteTasksButtonHandler, EditingButtonHandler, DeleteCompletedButtonHandler {
    
    let controller : TaskTableViewController
    let dataManager : TaskDataManager
    var deleteToolbar : UIToolbar?
    var completedTasksHidden = false
    
    init(controller: TaskTableViewController, dataManager: TaskDataManager) {
        self.controller = controller
        self.dataManager = dataManager
        
        // Add login bar button to cotroller
        setUpTitleButton()
        setUpBarButtons()
        setUpDeleteToolbar()
    }
    private func setUpRefreshControl() {
        // Pull down tableview to refresh from remote store
        controller.refreshControl?.addTarget(self, action: #selector(dataManager.refreshWrapper), for: UIControlEvents.valueChanged )
        controller.refreshControl?.tintColor = USER_COLOR
    }
    private func setUpBarButtons() {
        controller.navigationItem.leftBarButtonItem = hideCompletedBarButton
        controller.navigationItem.rightBarButtonItem = editBarButton
    }
    
    // MARK: - Login button
    
    var loginButton : UIButton {
        let loginButton = UIButton(type: .custom)
        loginButton.setTitleColor(GUEST_COLOR, for: .normal)
        loginButton.setTitleColor(.clear, for: .highlighted)
        loginButton.showsTouchWhenHighlighted = true
        loginButton.frame = controller.navigationItem.titleView?.frame ?? CGRect(x: 0, y: 0, width: 100, height: 40)
        loginButton.addTarget(self, action: #selector(showLoginAlert), for: .touchUpInside)
        return loginButton
    }
    public func setUpTitleButton(forUser username: String? = "To Do") {
        loginButton.setTitle(username, for: .normal)
        controller.navigationItem.titleView = loginButton
    }
    @objc func showLoginAlert() {
        dataManager.authenticationHandler.authenticationAlertHandler.present(alertType: .login)
    }
    
    
    // MARK: - Hide completed tasks button
    
    var hideCompletedBarButton : UIBarButtonItem {
        let button = UIBarButtonItem(customView: hideCompletedCustomView(image: #imageLiteral(resourceName: "completionTrue")))
        return button
    }
    func hideCompletedCustomView(image: UIImage) -> UIImageView {
        let view = UIImageView(image: image)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideCompletedTasks))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        return view
    }
    @objc func hideCompletedTasks() {
        completedTasksHidden = completedTasksHidden ? false : true
        let image : UIImage = completedTasksHidden ? #imageLiteral(resourceName: "completionFalse") : #imageLiteral(resourceName: "completionTrue")
        controller.navigationItem.leftBarButtonItem?.customView = hideCompletedCustomView(image: image)
        dataManager.update()
    }
    
    
    // MARK: - Editing mode button
    
    var editBarButton : UIBarButtonItem {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "editFalse"), style: .plain, target: self, action: #selector(setEditing))
        return button
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
    
    
    // MARK: - Delete completed tasks button
    
    private func setUpDeleteToolbar() {
        let button = UIBarButtonItem(title: "Delete Completed Tasks", style: .plain, target: self, action: #selector(presentDeleteCompletedTasksAlert))
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
    @objc func presentDeleteCompletedTasksAlert() {
        controller.present(deleteAlert, animated: true)
    }
    var deleteAlert: UIAlertController {
        let alertController = UIAlertController(title: nil, message: "Delete all completed tasks?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Delete", style: .default, handler: {
            alert -> Void in
            self.dataManager.deleteCompletedTasks()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    
}
