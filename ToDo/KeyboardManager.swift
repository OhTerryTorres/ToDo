//
//  KeyboardManager.swift
//  ToDo
//
//  Created by TerryTorres on 4/19/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class KeyboardManager {
    
    let controller : TaskTableViewController
    let textFieldManager : TaskTextFieldManager
    var oldInsets : (contentInset: UIEdgeInsets, scrollIndicatorInsets: UIEdgeInsets)? = nil
    
    init(controller: TaskTableViewController, textFieldManager: TaskTextFieldManager) {
        self.controller = controller
        self.textFieldManager = textFieldManager
        // Know when to move the tableview out from behind the keyboard
        registerForKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        // Get keyboard size
        var info = notification.userInfo!
        guard let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        
        // Change tableview insets for the first time
        if oldInsets == nil {
            // Save default insets on first change
            oldInsets = (controller.tableView.contentInset, controller.tableView.scrollIndicatorInsets)
        }
        
        // Move tableview's insets to make froom for the keyboard
        var contentInsets = controller.tableView.contentInset
        contentInsets.bottom = keyboardSize.height
        controller.tableView.contentInset = contentInsets
        controller.tableView.scrollIndicatorInsets = contentInsets
        
        // Move active text field to a visible area if its blocked by the keyboard
        guard let activeField = textFieldManager.activeTextField else { return }
        guard let activePoint = activeField.superview?.superview?.convert(activeField.frame.origin, to: controller.view) else { return }
        let keyRect = CGRect(x: controller.view.frame.origin.x, y: (controller.view.frame.size.height - keyboardSize.height), width: controller.view.frame.size.width, height: keyboardSize.height)
        if (keyRect.contains(activePoint)){
            controller.tableView.scrollRectToVisible(activeField.frame, animated: true)
        }
        
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        guard let insets = oldInsets else { return }
        (controller.tableView.contentInset, controller.tableView.scrollIndicatorInsets) = insets
    }
    
}
