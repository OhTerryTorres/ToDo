//
//  TaskTextFieldManager.swift
//  ToDo
//
//  Created by TerryTorres on 4/5/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskTextFieldManager : NSObject, UITextFieldDelegate {

    let controller : TaskTableViewController
    var keyboardManager : KeyboardManager!
    var activeTextField : UITextField?
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        super.init()
        self.keyboardManager = KeyboardManager(controller: controller, textFieldManager: self)
        
        // Touching anywhere but a textfield will dismiss the keyboard
        if let nc = self.controller.navigationController {
            nc.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        }
    }
        
    // MARK: - Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.text != "" else { textField.resignFirstResponder(); return true }
        commitChangesInTextField(textField: textField)
        // If a new task is properly added,
        // this text field should now be in the second to last row.
        // We want to make the the new text field active on hitting return.
        if textField.tag == controller.lastRow-1 {
            if let cell = controller.tableView.cellForRow(at: IndexPath(row: controller.lastRow, section: 0)) as? TaskTableViewCell {
                cell.textField.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Modify current tasks, and update tableview controller
    private func commitChangesInTextField(textField: UITextField) {
        // If a new task was created
        if let _ = resolveTaskForTextField(textField: textField) {
            // Reload bottom two rows: the most recently added task, and the new blank task
            controller.dataSource.update(method: .partial)
        } else {
            // Reload entire table
            controller.dataSource.update(method: .full)
        }
    }
    
    // Add or update Task
    // Return nil unless adding new task
    private func resolveTaskForTextField(textField : UITextField) -> Task? {
        guard let username = UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as? String else { return nil}
        // The tag should be set properly in the controller's cellForRow
        let tag = textField.tag
        let apiService = APIService(responseHandler: nil, catcher: controller.dataSource.failedRequestCatcher)
        
        guard let text = textField.text  else { return nil }
        
        // New task
        guard tag != self.controller.lastRow else {
            let task = Task(name: text, order: tag)
            controller.dataSource.tasks += [task]
            
            // Send task to database
            apiService.insert(task: task, forUser: username)
            
            return task
        }
        
        // Update task
        // Ignore update if there is not change to the task's name
        guard controller.dataSource.tasks[tag].name != textField.text else { return nil }
        controller.dataSource.tasks[tag].name = text
        
        // Update task to database
        apiService.set(task: controller.dataSource.tasks[tag], forUser: username)
        
        return nil
        
    }
    
    // Keyboard dismissal works like hitting Return:
    // whatever is in the text field at the time will be saved.
    func dismissKeyboard() {
        if let textField = self.activeTextField {
            commitChangesInTextField(textField: textField)
        }
    }
    
}
