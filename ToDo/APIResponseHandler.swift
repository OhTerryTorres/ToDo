//
//  APIResponseHandler.swift
//  Starbucker
//
//  Created by TerryTorres on 3/29/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//
import Foundation

protocol APIResponseHandler {
    var dataSource : TaskTableViewDataSource { get set }
    
    // Handle JSON dict from APIRequestService
    func handleAPIResponse(jsonArray : [[String:Any]], completion:(()->())?)
}

extension APIResponseHandler {
    // Called from a URL Session data task, so can be assumed to
    // alway run on a background thread.
    func handleAPIResponse(jsonArray: [[String : Any]], completion:(()->())? = nil) {
        var remoteTasks : [Task] = []
        var newTasks : [Task] = []
        
        for json in jsonArray {
            guard let uniqueID = json["uniqueID"] as? String else { return }
            let task = Task(withJSON: json)
            remoteTasks += [task]
            if let index = dataSource.tasks.index(where: {$0.uniqueID == uniqueID} ) {
                // Update task
                dataSource.tasks[index] = task
            } else {
                // Add new task
                newTasks += [task]
            }
        }
        
        // Remove tasks that are no longer found in the API
        if remoteTasks.count > 0 {
            for index in 0..<dataSource.tasks.count {
                if !remoteTasks.contains(where: { $0.uniqueID == dataSource.tasks[index].uniqueID }) {
                    dataSource.tasks.remove(at: index)
                }
            }
        }
        
        // Sort tasks and assign the correct order to them.
        if newTasks.count > 0 {
            let newSortedTasks = newTasks.sorted(by: {$1.dateCreated > $0.dateCreated})
            
            dataSource.tasks += newSortedTasks
            dataSource.tasks.maintainOrder()
        }
        
        DispatchQueue.main.async {
            completion?()
            self.dataSource.update()
        }
    }
    
}
