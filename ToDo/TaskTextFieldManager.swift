//
//  TaskTextFieldManager.swift
//  ToDo
//
//  Created by TerryTorres on 4/5/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskTextFieldManager : NSObject, UITextFieldDelegate, TaskCreator {

    let controller : TaskTableViewController
    let dataSource : TaskDataSource
    var keyboardManager : KeyboardManager!
    var activeTextField : UITextField?
    
    init(controller: TaskTableViewController, dataSource: TaskDataSource) {
        self.controller = controller
        self.dataSource = controller.dataSource
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
        if let _ = setTask(name: textField.text, index: textField.tag) {
            // Reload bottom two rows: the most recently added task, and the new blank task
            controller.reload(method: .partial)
        } else {
            // Reload entire table
            controller.reload(method: .full)
        }
    }
    
    // Keyboard dismissal works like hitting Return:
    // whatever is in the text field at the time will be saved.
    func dismissKeyboard() {
        if let textField = self.activeTextField {
            commitChangesInTextField(textField: textField)
        }
    }
    
}
