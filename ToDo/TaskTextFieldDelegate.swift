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
            nc.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        }
        registerForKeyboardNotifications()
    }
    
    // MARK: - Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let oldTaskCount = controller.tasks.count
        commitChangesInTextField(textField: textField)
        // If a new task is properly added,
        // this text field should now be in the second to last row.
        // We want to make the the new text field active on hitting return.
        print("textField.tag is \(textField.tag)")
        print("controller.lastRow! is \(controller.lastRow!)")
        if textField.tag == controller.lastRow!-1 {
            if let cell = controller.tableView.cellForRow(at: IndexPath(row: controller.lastRow!, section: 0)) as? TaskTableViewCell {
                cell.textField.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Modify current tasks, and update tableview controller
    func commitChangesInTextField(textField: UITextField) {

        var paths : [IndexPath]? = nil
        if let _ = resolveTaskForTextField(textField: textField) {
            if let row = controller.lastRow {
                if textField.tag == row {
                    paths = [IndexPath(row: row, section: 0), IndexPath(row: row+1, section: 0)]
                }
            }
        }
        
        controller.update(indexPaths: paths)
        
    }
    
    // Add or update Task
    // A task is only returned if it's new
    func resolveTaskForTextField(textField : UITextField) -> Task? {
        // The tag should be set properly in cellForRow
        let tag = textField.tag
        let dataService = TaskCoreDataService()
        
        // New task
        guard tag != self.controller.lastRow else {
            print("3A textField is in the last row")
            guard let text = textField.text  else { return nil }
            guard let task = dataService.addNewTask(withName: text) else { return nil }
            return task
        }
        
        // Update task
        let task = controller.tasks[tag]
        print("3B textField is in row \(tag)")
        guard task.name != textField.text else { return nil }
        dataService.updateTask(task: task, withName: textField.text!)
        return nil
        
    }
    
    
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
        
        // Change tableview insets
        if oldInsets == nil {
            // Save default insets on first change
            oldInsets = (controller.tableView.contentInset, controller.tableView.scrollIndicatorInsets)
        }
        var contentInsets = controller.tableView.contentInset
        contentInsets.bottom = keyboardSize.height
        controller.tableView.contentInset = contentInsets
        controller.tableView.scrollIndicatorInsets = contentInsets
        
        // Move active text field to a visible area
        guard let activeField = self.activeTextField else { return }
        print (activeField.frame)
        
        guard let activePoint = activeField.superview?.superview?.convert(activeField.frame.origin, to: controller.view) else { return }
        print(activePoint)
        
        let keyRect = CGRect(x: controller.view.frame.origin.x, y: (controller.view.frame.size.height - keyboardSize.height), width: controller.view.frame.size.width, height: keyboardSize.height)
        print(keyRect)
        if (keyRect.contains(activePoint)){
            controller.tableView.scrollRectToVisible(activeField.frame, animated: true)
        }
        
        
        /*
        Create a hypothetical rect representing where the keyboard WOULD be onscreen.
        Create a BOOL, screenShunted.
        If the text field is covered by the keyboard, screenShunted is TRUE
        screenShunted will have a getter:
        true: tableview frame shrinks to make room for keyboard, scrools text field to visible
        fals: tableview returns to default dimenions (that is, the size of the screen)
         
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        controller.tableView.contentInset = contentInsets
        controller.tableView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = controller.tableView.frame
        aRect.size.height -= keyboardSize.height
        if let activeField = self.activeTextField {
            if (!aRect.contains(activeField.frame.origin)){
                controller.tableView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        */
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        guard let insets = oldInsets else { return }
        (controller.tableView.contentInset, controller.tableView.scrollIndicatorInsets) = insets
    }
    
    
}
