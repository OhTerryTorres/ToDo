//
//  TaskDataSource.swift
//  ToDo
//
//  Created by TerryTorres on 7/9/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

protocol TaskDataSource: class {
    var tasks : [Task] { get set }
    var controller : TaskTableViewController { get }
    var failedRequestCatcher : FailedRequestCatcher! { get set }
    
    func update(method: ReloadMethod)
    func delete(taskAtIndex index: Int)
    func toggleTaskCompletion(index: Int, completion: (TaskTableViewCellStyle)->()?)
}

extension TaskDataSource {
    
    func update(method: ReloadMethod = .full) {
        switch method {
        case .full:
            controller.tableView.reloadData()
        case .partial:
            controller.tableView.reloadLastTwoRows(lastRow: tasks.count)
        }
    }
    
    func delete(taskAtIndex index: Int) {
        let task = tasks.remove(at: index)
        let apiService = APIService(responseHandler: nil, catcher: failedRequestCatcher)
        apiService.delete(task: task, forUser: UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as! String)
    }
    
    func toggleTaskCompletion(index: Int, completion: (TaskTableViewCellStyle)->()?) {
        let task = self.tasks[index]
        task.userCompleted = task.userCompleted == nil ? USER_ID : nil  // Add your ID if you completed it
        task.dateCompleted = task.userCompleted == nil ? nil : Date() // Add current date if completed
        
        // Update cell appearance
        let style = TaskTableViewCellStyle(task: task)
        completion(style)
        
        // Update task's completed status in database
        let apiService = APIService(responseHandler: nil, catcher: failedRequestCatcher)
        apiService.set(task: task, forUser: UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as! String)
    }
}
