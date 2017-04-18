//
//  TableViewController.swift
//  ToDo
//
//  Created by TerryTorres on 3/24/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {
    
    var dataSource : TaskTableViewDataSource!
    var taskTextFieldDelegate : TaskTextFieldDelegate!
    
    var lastRow : Int {
        return self.dataSource.tasks.count
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        // Pull to refresh from remote store
        
        taskTextFieldDelegate = TaskTextFieldDelegate(forController: self)
        dataSource = TaskTableViewDataSource(controller: self, coreService: CoreService(), authenticationDelegate: AuthenticationDelegate(forController: self))
        
        update()
    }
    
    
    // MARK: - Tableview Data Source
    
    func update(addingNewTask : Bool = false) {
        self.dataSource.getTasksFromCoreData()
        
        // Reload entire table
        guard addingNewTask else {
            self.tableView.reloadData()
            return
        }

        reloadLastTwoRows()
    }
    
    func reloadLastTwoRows() {
        // Reload only the last two rows
        self.tableView.beginUpdates()
        let reloadPath = [IndexPath(row: lastRow-1, section: 0)]
        let insertPath = [IndexPath(row: lastRow, section: 0)]
        self.tableView.reloadRows(at: reloadPath, with: .automatic)
        self.tableView.insertRows(at: insertPath, with: .automatic)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: insertPath[0], at: .bottom, animated: false)
    }
    
    
    
    // MARK: - Tableview Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tasks.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        
        // Last row has no task
        guard indexPath.row != lastRow else {
            cell.configure(task: nil, tag: 0, delegate: taskTextFieldDelegate)
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
            dataSource.deleteTask(task: dataSource.tasks[indexPath.row])
        }
    }

    
}
