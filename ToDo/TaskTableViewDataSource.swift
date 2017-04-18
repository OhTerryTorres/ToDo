//
//  TaskTableViewDataSource.swift
//  ToDo
//
//  Created by TerryTorres on 4/18/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskTableViewDataSource {
    
    let controller : TaskTableViewController
    let coreService : CoreService
    var authenticationDelegate : AuthenticationDelegate
    var tasks : [Task] = [] {
        didSet {
            controller.tableView.reloadData()
        }
    }
    
    init(controller: TaskTableViewController, coreService: CoreService, authenticationDelegate: AuthenticationDelegate) {
        self.controller = controller
        self.coreService = coreService
        self.tasks = coreService.getAllTasksSortedByDate()
        
        self.authenticationDelegate = authenticationDelegate
        controller.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged )
    }
    
    func getTasksFromCoreData() {
        tasks = coreService.getAllTasksSortedByDate()
    }
    
    func deleteTask(task: Task) {
        let apiService = APIService(withController: nil)
        apiService.delete(task: task)
        
        let coreService = CoreService()
        coreService.delete(task: task)
        
        controller.update()
    }
    
    @objc func refresh() {
        authenticationDelegate.getDataFromRemoteServer()
    }
}
