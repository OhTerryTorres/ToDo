//
//  TaskCreator.swift
//  ToDo
//
//  Created by TerryTorres on 7/10/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

protocol TaskCreator {
    var controller: TaskTableViewController { get }
    var dataSource : TaskDataSource { get }
    
    func setTask(name: String?, index: Int) -> Task?
    
}

extension TaskCreator {
    
    
    // Returns new task; return nil of set task is old
    func setTask(name: String?, index: Int) -> Task? {
        guard let username = UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as? String else { return nil}
        let apiService = APIService(responseHandler: nil, catcher: dataSource.failedRequestCatcher)
        
        guard let name = name else { return nil }
        
        // New task
        guard index != self.controller.lastRow else {
            let task = Task(name: name, order: index)
            dataSource.tasks += [task]
            
            // Send task to database
            apiService.insert(task: task, forUser: username)
            
            return task
        }
        
        // Update task
        // Ignore update if there is not change to the task's name
        guard dataSource.tasks[index].name != name else { return nil }
        dataSource.tasks[index].name = name
        
        // Update task to database
        apiService.set(task: dataSource.tasks[index], forUser: username)
        
        return nil
    }
    
}
