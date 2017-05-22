//
//  Mocks.swift
//  ToDo
//
//  Created by TerryTorres on 5/1/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation
@testable import ToDo


var MockTask : Task {
    let task = Task(name: "DO DISHES")
    task.uniqueID = "BB7B4816-6AF0-48DC-96DF-7B1629C50C640001"
    task.userCreated = "BB7B4816-6AF0-48DC-96DF-7B1629C50C64"
    task.userCompleted = nil
    task.dateCreated = Date()
    task.dateCompleted = nil
    task.order = 0
    return task
}


var MockTaskJSON : [String : Any] {
    var json : [String : Any] = [:]
    json[TaskPropertyKeys.uniqueID.rawValue] = "BB7B4816-6AF0-48DC-96DF-7B1629C50C640000"
    json[TaskPropertyKeys.name.rawValue] = "DO DISHES"
    json[TaskPropertyKeys.userCreated.rawValue] = "BB7B4816-6AF0-48DC-96DF-7B1629C50C64"
    json[TaskPropertyKeys.userCompleted.rawValue] = nil
    json[TaskPropertyKeys.dateCreated.rawValue] = "2017-04-17 20:45:21"
    json[TaskPropertyKeys.dateCompleted.rawValue] = ""
    return json
}
