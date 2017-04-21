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
    var networkCoordinator : NetworkCoordinator!
    var tasks : [Task] = []
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        let coreService = CoreService()
        self.tasks = coreService.getAllTasksSortedByDate()
        self.networkCoordinator = NetworkCoordinator(dataSource: self)
        
        // Pull down tableview to refresh from remote store
        controller.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged )
        // Add observer, notified in App Delegate's applicationDidBecomeActive 
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
    }
    
    func update(method: ReloadMethod = .full) {
        let coreService = CoreService()
        tasks = coreService.getAllTasksSortedByDate()
        controller.reload(method: method)
    }
    
    func delete(task: Task) {
        let apiService = APIService()
        apiService.delete(task: task)
        
        let coreService = CoreService()
        coreService.delete(task: task)
        
        update()
    }
    
    @objc func refresh() {
        networkCoordinator.getDataFromRemoteServer() {
            self.controller.refreshControl?.endRefreshing()
        }
    }
}
