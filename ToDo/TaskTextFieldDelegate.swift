//
//  TaskTextFieldDelegate.swift
//  ToDo
//
//  Created by TerryTorres on 4/5/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskTextFieldDelegate: NSObject, UITextFieldDelegate {

    
    let controller : TaskTableViewController
    var keyboardManager : KeyboardManager!
    var activeTextField : UITextField?
    
    init(forController controller: TaskTableViewController) {
        self.controller = controller
        super.init()
        self.keyboardManager = KeyboardManager(controller: controller, textFieldDelegate: self)
        
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
    func commitChangesInTextField(textField: UITextField) {
        if let _ = resolveTaskForTextField(textField: textField) {
            controller.dataSource.update(method: .partial)
        } else {
            controller.dataSource.update(method: .full)
        }
    }
    
    // Add or update Task
    // Return nil unless adding new task
    func resolveTaskForTextField(textField : UITextField) -> Task? {
        // The tag should be set properly in the controller's cellForRow %%
        let tag = textField.tag
        let coreService = CoreService()
        let apiService = APIService()
        
        // New task
        guard tag != self.controller.lastRow else {
            guard let text = textField.text  else { return nil }
            guard let task = coreService.insert(taskWithName: text, atIndex: tag) else { return nil }
            
            // Send task to database
            apiService.insert(task: task)
            
            return task
        }
        
        // Update task
        let task = controller.dataSource.tasks[tag]
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

    
    
}
