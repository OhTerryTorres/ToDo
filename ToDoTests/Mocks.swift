//
//  Mocks.swift
//  ToDo
//
//  Created by TerryTorres on 5/1/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation
@testable import ToDo

class MockTaskDataSource: TaskDataSource {
    var tasks: [Task] = []
    var controller: TaskTableViewController
    var failedRequestCatcher: FailedRequestCatcher!
    
    init(controller: TaskTableViewController) {
        self.controller = controller
        tasks = MockTaskArray
    }
}

class MockTaskDataSynchronizer: TaskDataSynchronizer {
    var tasks: [Task] = []
    var authenticationHandler : AuthenticationHandler!
    
    func refresh() {
        // Synchronize local tasks with remote tasks
        guard let username = self.authenticationHandler.currentUser else { return }
        self.authenticationHandler.getDataFromAPI(forUser: username) {
            
            // Acknowledge push notifications for this device and prepare to receive new ones
            self.authenticationHandler.acknowledgeNotification(forUser: username)
        }
    }
}

class MockTaskCreator: TaskCreator {
    var controller: TaskTableViewController
    var dataSource : TaskDataSource
    
    init(controller: TaskTableViewController, dataSource: TaskDataSource) {
        self.controller = controller
        self.dataSource = dataSource
    }
}

class MockAuthenticationHandler: AuthenticationHandler {
    var dataSource : TaskDataSource
    var currentUser : String? = "test"
    var authenticationAlertHandler : AuthenticationAlertHandler!
    
    init(dataSource: TaskDataSource) {
        self.dataSource = dataSource
    }
    
    func getDataFromAPI(forUser username: String, completion:(()->())?) {
        let mockAPI = MockAPIResponseHandler(dataSource: self.dataSource)
        let apiService = APIService(responseHandler: mockAPI)
        apiService.getTasks(forUser: username)
        
        DispatchQueue.main.async {
            completion?()
        }
    }
}

class MockAPIResponseHandler: APIResponseHandler {
    var dataSource : TaskDataSource
    
    init(dataSource: TaskDataSource) {
        self.dataSource = dataSource
    }
}

class MockFailedRequestCatcher: FailedRequestCatcher {
    
    var failedRequestPackages : [(urlRequest: URLRequest, username: String, method: APIService.PostMethod)] = []
    
}


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

var MockTaskArray : [Task] {
    let tasks : [Task] = [Task(name: "Mow the hedges", order: 0), Task(name: "Shave the chickens", order: 1), Task(name: "Take out the trash", order: 2)]
    return tasks
}

