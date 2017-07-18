//
//  TaskDataSynchronizer.swift
//  ToDo
//
//  Created by TerryTorres on 7/9/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

protocol TaskDataSynchronizer: class {
    var tasks : [Task] { get set }
    var authenticationHandler : AuthenticationHandler! { get set }
    
    func refresh()
    func saveData()
}

extension TaskDataSynchronizer {
    
    // Called when app enters background or is terminated
    func saveData() {
        let coreService = CoreService()
        coreService.syncTasksToCoreData(tasks: tasks)
    }
    
}
