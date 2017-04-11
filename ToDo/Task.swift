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
        self.completed = false
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
        
        if let uniqueID = item["uniqeID"] as? String {
            self.uniqueID = uniqueID
        }
        if let name = item["name"] as? String {
            self.name = name
        }
        
        self.completed = (item["completed"] != nil)
        
        if let userCreated = item["userCreated"] as? String {
            self.userCreated = userCreated
        }
        if let userCompleted = item["userCompleted"] as? String {
            // Do not assign an empty string to the property.
            self.userCompleted = userCompleted == "" ? nil : userCompleted
        }
        if let dateCreated = item["dateCreated"] as? String {
            self.dateCreated = MySQLDateFormatter.date(from: dateCreated) as NSDate?
            print(dateCreated)
        }
        if let dateCompleted = item["dateCompleted"] as? String {
            self.dateCompleted = MySQLDateFormatter.date(from: dateCompleted) as NSDate?
        }
        
        print("\(name) completed? \(completed)")
        
    }
    
}
