//
//  TableViewController.swift
//  ToDo
//
//  Created by TerryTorres on 3/24/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit


// Displays tasks from the dataSource
// Updates rows based data
class TaskTableViewController: UITableViewController {
    
    var dataSource : TaskDataSource!
    var buttonManager : ButtonManager!
    var taskTextFieldManager : TaskTextFieldManager!
    
    var lastRow : Int {
        return self.dataSource.tasks.count
    }
    
    // MARK: - View Lifecycle and Control
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        
        let dataManager = TaskDataManager(controller: self)
        dataSource = dataManager
        
        taskTextFieldManager = TaskTextFieldManager(controller: self, dataSource: dataSource)
        
        buttonManager = ButtonManager(controller: self, dataManager: dataManager)
        reload()
        navigationController?.navigationBar.tintColor = GUEST_COLOR
    }
    
    func reload(method : ReloadMethod = .full) {
        switch method {
        case .full:
            tableView.reloadData()
        case .partial:
            tableView.reloadLastTwoRows(lastRow: lastRow)
        }
    }
    
    func acknowledgeConnection(forUser username: String) {
        buttonManager.setUpLoginButton(forUser: username)
    }
    
    // Tableview Delegate
    // MARK: - Displaying data
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tasks.count+1 // +1 for new task row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        
        // Last row has no task by default
        guard indexPath.row != lastRow else {
            cell.configure(task: nil, tag: indexPath.row, dataSource: dataSource, delegate: taskTextFieldManager)
            return cell
        }
        let task = dataSource.tasks[indexPath.row]
        cell.configure(task: task, tag: indexPath.row, dataSource: dataSource, delegate: taskTextFieldManager)
        
        return cell
    }
    
    
    // MARK: - Editing
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == lastRow {
            return false
        }
        return true
    }
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .none
        } else {
            return .delete
        }
    }
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.row != lastRow {
            dataSource.delete(taskAtIndex: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // This process ensures that tasks can't be moved below the blank task cell
        let movedTask = dataSource.tasks[sourceIndexPath.row]
        dataSource.tasks.remove(at: sourceIndexPath.row)
        var newRow = destinationIndexPath.row
        if newRow > lastRow {
            newRow = lastRow
        }
        dataSource.tasks.insert(movedTask, at: newRow)
        dataSource.tasks.maintainOrder()
        reload()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // If the hidden option is chosen, completed tasks are given a height of 0
        guard buttonManager.completedTasksHidden && indexPath.row != lastRow else { return UITableViewAutomaticDimension }
        let task = dataSource.tasks[indexPath.row]
        guard let _ = task.userCompleted else { return UITableViewAutomaticDimension }
        return 0
    }
    
}


extension UITableView {
    
    func reloadLastTwoRows(lastRow: Int) {
        guard lastRow > 0 else { reloadData(); return }
        // Reload only lastRow and the row before it.
        beginUpdates()
        let reloadPath = [IndexPath(row: lastRow-1, section: 0)]
        let insertPath = [IndexPath(row: lastRow, section: 0)]
        reloadRows(at: reloadPath, with: .automatic)
        insertRows(at: insertPath, with: .automatic)
        endUpdates()
        
        scrollToRow(at: insertPath[0], at: .bottom, animated: false)
    }
    
}
