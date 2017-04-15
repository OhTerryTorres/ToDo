//
//  TableViewController.swift
//  ToDo
//
//  Created by TerryTorres on 3/24/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, APIResponseHandler {
    
    var taskTextFieldDelegate : TaskTextFieldDelegate!
    var tasks: [Task] = []
    var lastRow : Int {
        return self.tasks.count
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        taskTextFieldDelegate = TaskTextFieldDelegate(forController: self)
        
        // Pull to refresh from remote store
        self.refreshControl?.addTarget(self, action: #selector(getDataFromRemoteServer), for: UIControlEvents.valueChanged )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    
    
    // MARK: - Tableview Data Source
    
    func update(addingNewTask : Bool = false) {
        self.getDataFromLocalStore()
        
        // Reload entire table
        guard addingNewTask else {
            self.tableView.reloadData()
            return
        }

        // Reload only the last two rows
        self.tableView.beginUpdates()
        let reloadPath = [IndexPath(row: lastRow-1, section: 0)]
        let insertPath = [IndexPath(row: lastRow, section: 0)]
        self.tableView.reloadRows(at: reloadPath, with: .automatic)
        self.tableView.insertRows(at: insertPath, with: .automatic)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: insertPath[0], at: .bottom, animated: false)
    }
    
    func getDataFromLocalStore() {
        // Load stored tasks from Core Data store
        let coreService = CoreService()
        tasks = coreService.getAllTasksSortedByDate()
    }
    
    func getDataFromRemoteServer() {
        // Look for new tasks in database
        let apiService = APIService(withController: self)
        apiService.getTasks()
        print("refresh completed")
        refreshControl?.endRefreshing()
    }
    
    // Called from a URL Session data task, so can be assume to
    // alway run on a background thread.
    func handleResponse(jsonArray: [[String : Any]]) {
        let coreService = CoreService()
        tasks = coreService.integrateTasks(tasks: tasks, withJSONArray: jsonArray)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Tableview Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        cell.textField.delegate = taskTextFieldDelegate
        cell.textField.tag = indexPath.row
        
        // Make blank task in last rows
        guard cell.textField.tag != lastRow else {
            // Clear dequeed cell's properties
            cell.textField.text = nil
            cell.task = nil
            return cell
        }
        
        let task = tasks[indexPath.row]
        cell.task = task
        if let name = task.name {
            cell.textField.text = name
        }
        
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
            let task = self.tasks[indexPath.row]

            // Need to delete the remote version before the local version
            // or else the reference to the local version will be gone
            // and thus cannot be used to delete the remote version
            // ******
            // There shoul be a way to keep the local list
            // consistent with the database in case something goes
            // wrong and the task CANNOT be deleted
            // *****
            // For example:
            // Delete action removes the task from the array at the
            // SAME TIME api.delete method executes.
            // This shouldn't be a problem, because the original
            // reference to the task is still in its context.
            // The .delete method could return an error.
            // A callback checks for an error. If there is one,
            // the core.delete task does NOT execute.
            // The next time the user launches the app, the task
            // will return, which may be confusing, but lets
            // the player know that the delete request did not
            // go through last time.
            
            // This setup could work for .set method, too.
            
            let apiService = APIService(withController: nil)
            apiService.delete(task: task)
            
            let coreService = CoreService()
            coreService.delete(task: task)
            
            self.update()
        }
    }

    
}
