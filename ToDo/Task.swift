//
//  Task.swift
//  ToDo
//
//  Created by TerryTorres on 4/4/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import CoreData

extension Task {
    
    enum TaskError : Error {
        case noName
    }
    
    convenience init(name: String, context: NSManagedObjectContext) throws {
        // Vital to check for errors before the context makes an empty entry
        if name == "" { throw TaskError.noName }
        
        self.init(context: context)
        
        self.name = name
        self.completed = false
        self.dateCreated = Date() as NSDate?
        self.userCreated = USER_ID
        
        var numberOfTasksCreated = UserDefaults.standard.integer(forKey: "numberOfTasksCreated")
        self.order = Int16(numberOfTasksCreated)
        self.uniqueID = "\(USER_ID)\(numberOfTasksCreated)"
        numberOfTasksCreated += 1
        UserDefaults.standard.set(numberOfTasksCreated, forKey: "numberOfTasksCreated")
    }
    
}
