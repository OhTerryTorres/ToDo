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
    func handleAPIResponse(jsonArray : [[String:Any]])
}

extension APIResponseHandler {
    // Called from a URL Session data task, so can be assumed to
    // alway run on a background thread.
    func handleAPIResponse(jsonArray: [[String : Any]]) {
        /* -----
         let coreService = CoreService()
         coreService.integrateTasks(tasks: dataSource.tasks, withJSONArray: jsonArray)
         */
        var newTasks : [Task] = []
        for json in jsonArray {
            guard let uniqueID = json["uniqueID"] as? String else { return }
            if let index = dataSource.tasks.index(where: {$0.uniqueID == uniqueID} ) {
                dataSource.tasks[index] = Task(withJSON: json)
            } else {
                // Add new task
                newTasks += [Task(withJSON: json)]
            }
        }
        
        if newTasks.count > 0 {
            var newSortedTasks = newTasks.sorted(by: {$1.dateCreated > $0.dateCreated})
            var currentIndex = newSortedTasks.count - 1
            print("currentIndex was \(currentIndex)")
            for index in 0..<newSortedTasks.count {
                newSortedTasks[index].order = currentIndex
                currentIndex += 1
            }
            print("currentIndex is \(currentIndex)")
            
            dataSource.tasks += newSortedTasks
            dataSource.tasks.maintainOrder()
            for task in dataSource.tasks {
                print(task.name)
                print(task.order)
            }
        }
        
        DispatchQueue.main.async {
            self.dataSource.update()
        }
    }
    
}
