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
    
    convenience init(name: String)  {
        self.init()
    }
    
    convenience init(name: String, context: NSManagedObjectContext) throws {
        // Vital to check for errors before the context makes an empty entry
        if name == "" { throw TaskError.noName }
        
        self.init(context: context)
        
        self.name = name
        self.dateCreated = Date() as NSDate?
        self.userCreated = USER_ID
        
        var numberOfTasksCreated = UserDefaults.standard.integer(forKey: "numberOfTasksCreated")
        self.order = Int16(numberOfTasksCreated)
        self.uniqueID = "\(USER_ID)\(numberOfTasksCreated)"
        numberOfTasksCreated += 1
        UserDefaults.standard.set(numberOfTasksCreated, forKey: "numberOfTasksCreated")
    }
    
    convenience init(withJSONitem item: [String:Any], intoContext context: NSManagedObjectContext) {
        self.init(context: context)
        updateProperties(withJSONitem: item)
    }
    
    func updateProperties(withJSONitem item: [String:Any]) {
        
        if let uniqueID = item[TaskPropertyKeys.uniqueID.rawValue] as? String {
            self.uniqueID = uniqueID
        }
        if let name = item[TaskPropertyKeys.name.rawValue] as? String {
            self.name = name
        }
        if let userCreated = item[TaskPropertyKeys.userCreated.rawValue] as? String {
            self.userCreated = userCreated
        }
        if let userCompleted = item[TaskPropertyKeys.userCompleted.rawValue] as? String {
            // Do not assign an empty string to the property.
            self.userCompleted = userCompleted == "" ? nil : userCompleted
        }
        if let dateCreated = item[TaskPropertyKeys.dateCreated.rawValue] as? String {
            self.dateCreated = MySQLDateFormatter.date(from: dateCreated) as NSDate?
            print(dateCreated)
        }
        if let dateCompleted = item[TaskPropertyKeys.dateCompleted.rawValue] as? String {
            self.dateCompleted = MySQLDateFormatter.date(from: dateCompleted) as NSDate?
        }
    }
    
}
