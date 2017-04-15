//
//  TaskTextFieldDelegate.swift
//  ToDo
//
//  Created by TerryTorres on 4/5/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskTextFieldDelegate: NSObject, UITextFieldDelegate {

    
    let controller : TableViewController
    var activeTextField : UITextField?
    var oldInsets : (contentInset: UIEdgeInsets, scrollIndicatorInsets: UIEdgeInsets)? = nil
    
    init(forController controller: TableViewController) {
        self.controller = controller
        super.init()
        if let nc = self.controller.navigationController {
            // Touching anyhwere but a textfield will dismiss the keyboard
            nc.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        }
        // Know when to move the tableview out from behind the keyboard
        registerForKeyboardNotifications()
    }
    
    // MARK: - Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        print("text field is active")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
        print("active text field is now nil")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitChangesInTextField(textField: textField)
        // If a new task is properly added,
        // this text field should now be in the second to last row.
        // We want to make the the new text field active on hitting return.
        if textField.tag == controller.lastRow-1 {
            if let cell = controller.tableView.cellForRow(at: IndexPath(row: controller.lastRow, section: 0)) as? TaskTableViewCell {
                print("switching first responder to new text field")
                cell.textField.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
            print("resigning first responder")
        }
        return true
    }
    
    // Modify current tasks, and update tableview controller
    func commitChangesInTextField(textField: UITextField) {
        var add = false
        if let _ = resolveTaskForTextField(textField: textField) {
            add = true
        }
        
        controller.update(addingNewTask: add)
    }
    
    // Add or update Task
    // Return nil unless adding new task
    func resolveTaskForTextField(textField : UITextField) -> Task? {
        // The tag should be set properly in the controller's cellForRow %%
        let tag = textField.tag
        let coreService = CoreService()
        let apiService = APIService(withController: self.controller)
        
        // New task
        guard tag != self.controller.lastRow else {
            guard let text = textField.text  else { return nil }
            guard let task = coreService.insert(taskWithName: text) else { return nil }
            
            // Send task to database
            apiService.insert(task: task)
            
            return task
        }
        
        // Update task
        let task = controller.tasks[tag]
        // If task is given a new name
        guard task.name != textField.text else { return nil }
        coreService.set(task: task, withName: textField.text!)
        
        // Update task to database
        apiService.set(task: task)
        
        return nil
        
    }
    
    // Keyboard dismissal works like hitting Return:
    // whatever is in the text field at the time will be saved.
    func dismissKeyboard() {
        if let textField = self.activeTextField {
            commitChangesInTextField(textField: textField)
        }
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
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
        guard let activeField = self.activeTextField else { return }
        guard let activePoint = activeField.superview?.superview?.convert(activeField.frame.origin, to: controller.view) else { return }
        let keyRect = CGRect(x: controller.view.frame.origin.x, y: (controller.view.frame.size.height - keyboardSize.height), width: controller.view.frame.size.width, height: keyboardSize.height)
        if (keyRect.contains(activePoint)){
            controller.tableView.scrollRectToVisible(activeField.frame, animated: true)
        }

    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        guard let insets = oldInsets else { return }
        (controller.tableView.contentInset, controller.tableView.scrollIndicatorInsets) = insets
    }
    
    
}
