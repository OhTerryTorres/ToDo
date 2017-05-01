//
//  Task.swift
//  ToDo
//
//  Created by TerryTorres on 4/4/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import CoreData


struct Task: Ordered {
    var uniqueID: String
    var name: String
    var userCreated: String
    var userCompleted: String?
    var dateCreated: Date
    var dateCompleted: Date?
    var order: Int = 0
    
    
    init(uniqueID: String, name: String, userCreated: String, userCompleted: String? = nil, dateCreated: Date, dateCompleted: Date? = nil, order: Int = 0) {
        self.uniqueID = uniqueID
        self.name = name
        self.userCreated = userCreated
        self.userCompleted = userCompleted
        self.dateCreated = dateCreated
        self.dateCompleted = dateCompleted
    }
    
    init(name: String) {
        var numberOfTasksCreated = UserDefaults.standard.integer(forKey: "numberOfTasksCreated")
        self.init(uniqueID: "\(USER_ID)\(numberOfTasksCreated)", name: name, userCreated: USER_ID, dateCreated: Date())
        
        numberOfTasksCreated += 1
        UserDefaults.standard.set(numberOfTasksCreated, forKey: "numberOfTasksCreated")
    }
    init(name: String, order: Int) {
        self.init(name: name)
        self.order = order
    }
    
    init(withTaskModel taskModel: TaskModel) {
        self.init(uniqueID: "", name: "", userCreated: "", dateCreated: Date(timeIntervalSince1970: 0) )
        setPropertiesFromTaskModel(taskModel: taskModel)
    }
    
    init(withJSON json: [String:Any]) {
        self.init(uniqueID: "", name: "", userCreated: "", dateCreated: Date(timeIntervalSince1970: 0) )
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
            if let date = MySQLDateFormatter.date(from: dateCreated) {
                self.dateCreated = date
            }
        }
        if let dateCompleted = json[TaskPropertyKeys.dateCompleted.rawValue] as? String {
            self.dateCompleted = MySQLDateFormatter.date(from: dateCompleted)
        }
    }
    
    mutating func setPropertiesFromTaskModel(taskModel: TaskModel) {
        self.uniqueID = taskModel.uniqueID ?? ""
        self.name = taskModel.name ?? ""
        self.userCreated = taskModel.userCreated ?? ""
        self.userCompleted = taskModel.userCompleted ?? ""
        self.dateCreated = taskModel.dateCreated! as Date
        self.dateCompleted = taskModel.dateCompleted! as Date
        self.order = Int(taskModel.order)
    }
}

extension TaskModel {
    
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
        self.uniqueID = "\(USER_ID)\(numberOfTasksCreated)"
        numberOfTasksCreated += 1
        UserDefaults.standard.set(numberOfTasksCreated, forKey: "numberOfTasksCreated")
    }
    
    convenience init(withJSON json: [String:Any], intoContext context: NSManagedObjectContext) {
        self.init(context: context)
        updateProperties(withJSON: json)
    }
    
    convenience init(withTask task: Task, intoContext context: NSManagedObjectContext) {
        self.init(context: context)
        setPropertiesFromTask(task: task)
    }
    
    func updateProperties(withJSON json: [String:Any]) {
        
        if let uniqueID = json[TaskPropertyKeys.uniqueID.rawValue] as? String {
            print("uniqueID was \(String(describing: self.uniqueID))")
            print("uniqueID will be \(uniqueID)")
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
        }
        if let dateCompleted = json[TaskPropertyKeys.dateCompleted.rawValue] as? String {
            self.dateCompleted = MySQLDateFormatter.date(from: dateCompleted) as NSDate?
        }
    }
    
    func setPropertiesFromTask(task: Task) {
        self.uniqueID = task.uniqueID
        self.name = task.name
        self.userCreated = task.userCreated
        self.userCompleted = task.userCompleted
        self.dateCreated = task.dateCreated as NSDate
        self.dateCompleted = task.dateCompleted! as NSDate
        self.order = Int16(task.order)
    }
    
}

protocol Ordered {
    var order: Int { get set }
}
