//
//  DeleteCompletedButtonHandler.swift
//  ToDo
//
//  Created by TerryTorres on 7/11/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

typealias DeleteCompletedButtonHandler = DeleteCompletedButtonConfigurable & DeleteAlertPresenter

protocol DeleteCompletedButtonConfigurable {
    var controller : TaskTableViewController { get }
    var dataManager : TaskDataManager { get }
    var deleteToolbar : UIToolbar! { get set }
    func setUpDeleteToolbar() -> UIToolbar
    
}

extension DeleteCompletedButtonConfigurable where Self : DeleteCompletedButtonHandler {
    
    func setUpDeleteToolbar() -> UIToolbar {
        let button = UIBarButtonItem(title: "Delete Completed Tasks", style: .plain, target: self, action: #selector(presentDeleteCompletedTasksAlert))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: controller.view.frame.height, width: controller.view.frame.width, height: 44))
        toolbar.items = [button]
        toolbar.isHidden = true
        toolbar.tintColor = USER_COLOR
        if let superview = self.controller.view.superview {
            superview.addSubview(toolbar)
        } else {
            self.controller.view.addSubview(toolbar)
        }
        return toolbar
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

@objc protocol DeleteAlertPresenter {
    func presentDeleteCompletedTasksAlert()
}
