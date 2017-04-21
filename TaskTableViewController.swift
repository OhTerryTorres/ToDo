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
    
    var dataSource : TaskTableViewDataSource!
    var taskTextFieldDelegate : TaskTextFieldDelegate!
    
    var lastRow : Int {
        return self.dataSource.tasks.count
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        taskTextFieldDelegate = TaskTextFieldDelegate(forController: self)
        dataSource = TaskTableViewDataSource(controller: self)
        dataSource.update()
    }
    
    
    // MARK: - Tableview Delegate
    
    func reload(method : ReloadMethod = .full) {
        switch method {
        case .full:
            tableView.reloadData()
        case .partial:
            tableView.reloadLastTwoRows(lastRow: lastRow)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tasks.count+1 // +1 for new task row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        
        // Last row has no task by default
        guard indexPath.row != lastRow else {
            cell.configure(task: nil, tag: indexPath.row, delegate: taskTextFieldDelegate)
            return cell
        }
        let task = dataSource.tasks[indexPath.row]
        cell.configure(task: task, tag: indexPath.row, delegate: taskTextFieldDelegate)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == lastRow {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete  && indexPath.row != lastRow {
            dataSource.delete(task: dataSource.tasks[indexPath.row])
        }
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
