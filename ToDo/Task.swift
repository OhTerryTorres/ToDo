//
//  Task.swift
//  ToDo
//
//  Created by TerryTorres on 4/4/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import CoreData


class
Task: Ordered {
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
    
    // Called when tasks are created manually by user
    convenience init(name: String) {
        var numberOfTasksCreated = UserDefaults.standard.integer(forKey: UserKeys.numberOfTasks.rawValue)
        self.init(uniqueID: "\(USER_ID)\(numberOfTasksCreated)", name: name, userCreated: USER_ID, dateCreated: Date())
        
        numberOfTasksCreated += 1
        UserDefaults.standard.set(numberOfTasksCreated, forKey: UserKeys.numberOfTasks.rawValue)
    }
    convenience init(name: String, order: Int) {
        self.init(name: name)
        self.order = order
    }
    
    // Called when app launches and initializes tasks from local store
    convenience init(withTaskModel taskModel: TaskModel) {
        self.init(uniqueID: "", name: "", userCreated: "", dateCreated: Date(timeIntervalSince1970: 0) )
        setPropertiesFromTaskModel(taskModel: taskModel)
    }
    
    
    // Called pulling new tasks from the API
    convenience init(withJSON json: [String:Any]) {
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
    
    // Called when sending updated tasks through the API
    func json() -> [String : Any] {
        var json : [String : Any] = [:]
        
        json[TaskPropertyKeys.uniqueID.rawValue] = uniqueID
        json[TaskPropertyKeys.name.rawValue] = name
        json[TaskPropertyKeys.userCreated.rawValue] = userCreated
        json[TaskPropertyKeys.dateCreated.rawValue] = MySQLDateFormatter.string(from: dateCreated)
        if let userCompleted = userCompleted { json[TaskPropertyKeys.userCompleted.rawValue] = userCompleted }
        if let dateCompleted = dateCompleted { json[TaskPropertyKeys.dateCompleted.rawValue] = MySQLDateFormatter.string(from: dateCompleted as Date) }
        
        return json
    }
    
    // Called when app launches and initializes tasks from local store
    func setPropertiesFromTaskModel(taskModel: TaskModel) {
        self.uniqueID = taskModel.uniqueID ?? ""
        self.name = taskModel.name ?? ""
        self.userCreated = taskModel.userCreated ?? ""
        self.userCompleted = taskModel.userCompleted
        self.dateCreated = taskModel.dateCreated! as Date
        self.dateCompleted = taskModel.dateCompleted as Date?
        self.order = Int(taskModel.order)
    }
}

extension TaskModel {
    
    // Called when new tasks are integrated into core data
    convenience init(withTask task: Task, intoContext context: NSManagedObjectContext) {
        self.init(context: context)
        updateProperties(withTask: task)
    }
    
    func updateProperties(withTask task: Task) {
        self.uniqueID = task.uniqueID
        self.name = task.name
        self.userCreated = task.userCreated
        self.userCompleted = task.userCompleted
        self.dateCreated = task.dateCreated as NSDate
        self.dateCompleted = task.dateCompleted as NSDate?
        self.order = Int16(task.order)
    }
    
}

protocol Ordered {
    var order: Int { get set }
}
