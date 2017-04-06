//
//  TableViewController.swift
//  ToDo
//
//  Created by TerryTorres on 3/24/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var taskTextFieldDelegate : TaskTextFieldDelegate!
    var lastRow : Int?
    var tasks: [Task] = [] {
        didSet {
            lastRow = tasks.count
            print("lastRow is now \(lastRow)")
        }
    }
    
    @IBAction func unwindToList(seuge: UIStoryboardSegue) {}

    override func viewDidLoad() {
        taskTextFieldDelegate = TaskTextFieldDelegate(forController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    
    func update(indexPaths: [IndexPath]? = nil) {
        getData()
        guard let pathsss = indexPaths else {
            tableView.reloadData()
            return
        }
        //tableView.reloadData()
        tableView.beginUpdates()
        let reloadPath = [IndexPath(row: lastRow!-1, section: 0)]
        let insertPath = [IndexPath(row: lastRow!, section: 0)]
        tableView.reloadRows(at: reloadPath, with: .automatic)
        tableView.insertRows(at: insertPath, with: .automatic)
        tableView.endUpdates()
        
        if let cell = tableView.cellForRow(at: insertPath[0]) as? TaskTableViewCell {
            cell.textField.becomeFirstResponder()
        }
    }
    
    
    // MARK: - Tableview delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of rows is now \(tasks.count+1)")
        return tasks.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == lastRow {
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        cell.textField.delegate = taskTextFieldDelegate
        cell.textField.tag = indexPath.row
        
        // Make blank task in last rows
        guard cell.textField.tag != lastRow else {
            // Clear dequeed cell
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
    
    func getData() {
        let dataService = TaskCoreDataService()
        tasks = dataService.getAllTasksSortedByDate()
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
            let dataService = TaskCoreDataService()
            dataService.delete(task: task)
            self.update()
        }
    }
    
    
    
}
