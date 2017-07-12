//
//  ButtonManager.swift
//  ToDo
//
//  Created by TerryTorres on 6/28/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class ButtonManager: LoginButtonHandler, HideCompletedTasksButtonHandler, EditingButtonHandler, DeleteCompletedButtonHandler {
    
    let controller : TaskTableViewController
    let dataManager : TaskDataManager
    var completedTasksHidden = false
    var deleteToolbar: UIToolbar!
    
    init(controller: TaskTableViewController, dataManager: TaskDataManager) {
        self.controller = controller
        self.dataManager = dataManager
        
        // Add login bar button to cotroller
        setUpLoginButton()
        setUpBarButtons()
        self.deleteToolbar = setUpDeleteToolbar()
    }
    
    private func setUpBarButtons() {
        controller.navigationItem.leftBarButtonItem = hideCompletedBarButton
        controller.navigationItem.rightBarButtonItem = editBarButton
    }
    
    // MARK: - LoginButtonHandler Protocol
    func showLoginAlert() {
        dataManager.authenticationHandler.authenticationAlertHandler.present(alertType: .login)
    }    
    
    // MARK: - HideCompletedTasksButton Protocol
    
    func hideCompletedTasks() {
        completedTasksHidden = completedTasksHidden ? false : true
        let image : UIImage = completedTasksHidden ? #imageLiteral(resourceName: "completionFalse") : #imageLiteral(resourceName: "completionTrue")
        controller.navigationItem.leftBarButtonItem?.customView = hideCompletedCustomView(image: image)
        dataManager.update()
    }
    
    
    // MARK: - EditingButtonHandler Protocol
    
    func setEditing() {
        let editing = controller.tableView.isEditing ? false : true
        let image : UIImage = editing ? #imageLiteral(resourceName: "editFalse") : #imageLiteral(resourceName: "editTrue")
        
        controller.navigationItem.rightBarButtonItem?.image = image
        controller.tableView.setEditing(editing, animated: true)
        
        let hidden = editing ? false : true
        let yOffset = editing ? deleteToolbar.frame.height : -1 * deleteToolbar.frame.height
        var frame = deleteToolbar.frame
        frame.origin.y -= yOffset
        UIView.transition(with: deleteToolbar, duration: 0.5, options: .curveEaseOut, animations: { _ in
            self.deleteToolbar.frame = frame
        }, completion: nil)
        deleteToolbar.isHidden = hidden
    }
    
    
    
    // MARK: - DeleteCompletedButtonHandler Protocol
    
    func presentDeleteCompletedTasksAlert() {
        controller.present(deleteAlert, animated: true)
    }
    
    
}
