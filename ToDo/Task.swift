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
    
    convenience init(withJSON json: [String:Any], intoContext context: NSManagedObjectContext) {
        self.init(context: context)
        updateProperties(withJSON: json)
    }
    
    func updateProperties(withJSON json: [String:Any]) {
        
        if let uniqueID = json[TaskPropertyKeys.uniqueID.rawValue] as? String {
            self.uniqueID = uniqueID
        }
        if let name = json[TaskPropertyKeys.name.rawValue] as? String {
            self.name = name
        }
        if let userCreated = json[TaskPropertyKeys.userCreated.rawValue] as? String {
            self.userCreated = userCreated
        }
        if let userCompleted = json[TaskPropertyKeys.userCompleted.rawValue] as? String {
            // Do not assign an empty string to the property.
            self.userCompleted = userCompleted == "" ? nil : userCompleted
        }
        if let dateCreated = json[TaskPropertyKeys.dateCreated.rawValue] as? String {
            self.dateCreated = MySQLDateFormatter.date(from: dateCreated) as NSDate?
            print(dateCreated)
        }
        if let dateCompleted = json[TaskPropertyKeys.dateCompleted.rawValue] as? String {
            self.dateCompleted = MySQLDateFormatter.date(from: dateCompleted) as NSDate?
        }
    }
    
}
