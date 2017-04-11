//
//  TableViewController.swift
//  ToDo
//
//  Created by TerryTorres on 3/24/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, APIResponseHandler {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var taskTextFieldDelegate : TaskTextFieldDelegate!
    var lastRow : Int?
    var tasks: [Task] = [] {
        didSet {
            lastRow = tasks.count
            print("lastRow is now \(lastRow)")
        }
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        taskTextFieldDelegate = TaskTextFieldDelegate(forController: self)
        
        // Look for new tasks in database
        let requestService = APIRequestService(withController: self)
        requestService.getTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    
    
    // MARK: - Tableview Data Source
    
    func update(addingNewTask : Bool = false) {
        self.getData()
        
        guard addingNewTask else {
            self.tableView.reloadData()
            return
        }
        //tableView.reloadData()
        guard let row = self.lastRow else { return }
        
        self.tableView.beginUpdates()
        let reloadPath = [IndexPath(row: row-1, section: 0)]
        let insertPath = [IndexPath(row: row, section: 0)]
        self.tableView.reloadRows(at: reloadPath, with: .automatic)
        self.tableView.insertRows(at: insertPath, with: .automatic)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: insertPath[0], at: .bottom, animated: false)
    }
    
    func getData() {
        let dataService = TaskCoreDataService()
        tasks = dataService.getAllTasksSortedByDate()
    }
    
    func handleResponse(json: [[String : Any]]) {
        print("begin nearby search json parsing")
        let fetch = NSFetchRequest<Task>(entityName: "Task")
        for item in json {
            guard let uniqueID = item["uniqueID"] as? String else { return }
            // Check for alreay stored Starbucks location
            fetch.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
            do {
                let fetchedTasks = try context.fetch(fetch)
                if fetchedTasks.count > 0 {
                    // Update task
                    print("updating existing record")
                    fetchedTasks[0].updateProperties(withJSONitem: item)
                } else {
                    // Add new task
                    print("adding new record")
                    let task = Task(withJSONitem: item, intoContext: context)
                    self.tasks += [task]
                }
            } catch {
                print ("Filtered fetch failed")
            }
        }
        print("end nearby search json parsing")

        // Sort tasks by date created
        // A task should never be initialized without this property
        tasks.sort(by: {$0.dateCreated!.timeIntervalSince1970 < $1.dateCreated!.timeIntervalSince1970 } )
        
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
