    //
//  TaskTests.swift
//  ToDo
//
//  Created by TerryTorres on 4/11/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import XCTest

@testable import ToDo
import CoreData
class TaskTests: XCTestCase {
    
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTaskModelJSONIntegration() {
        //create JSON
        let task = Task(withJSON: MockTask.json)
        XCTAssertEqual(task.name, "DO DISHES")
        XCTAssertNil(task.userCompleted)
        XCTAssertNil(task.dateCompleted)
    }
    
}

class DataSourceTests: XCTestCase {
    var controller : TaskTableViewController!
    var dataManager : TaskDataManager!
    var textFieldManager : TaskTextFieldManager!
    var keyboardManager : KeyboardManager!
    var networkCoordinator : NetworkCoordinator!
    var authenticationAlertHandler : AuthenticationAlertHandler!
    
    override func setUp() {
        super.setUp()
        controller = TaskTableViewController()
        
        dataManager = TaskDataManager(controller: controller)
        controller.dataSource = dataManager
        textFieldManager = TaskTextFieldManager(controller: controller, dataSource: dataManager)
        controller.taskTextFieldManager = textFieldManager
        controller.buttonManager = ButtonManager(controller: controller, dataManager: dataManager)
        
        networkCoordinator = NetworkCoordinator(dataSource: dataManager)
        dataManager.authenticationHandler = networkCoordinator
        dataManager.failedRequestCatcher = networkCoordinator
        
        networkCoordinator.currentUser = "test"
        authenticationAlertHandler = networkCoordinator.authenticationAlertHandler
        
        textFieldManager = controller.taskTextFieldManager
        textFieldManager.keyboardManager = KeyboardManager(controller: controller, textFieldManager: textFieldManager)
        keyboardManager = textFieldManager.keyboardManager
        
        dataManager.tasks = [Task(name: "Suck dicks"), Task(name: "Eat butts"), Task(name: "Kick nuts")]

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        controller = nil
        super.tearDown()
    }
    
    // MANAGING TASKS
    func testLastRowShouldBeEqualToNumberOfTasks() {
        dataManager.tasks += [Task(name: "Eat eggs")]
        XCTAssert(dataManager.controller.lastRow == 4)
    }
    
    func testTaskOrderShouldEqualItsIndexInArray() {
        let array = [MockTask.json, dataManager.tasks[0].json, dataManager.tasks[1].json, dataManager.tasks[2].json]
        networkCoordinator.handleAPIResponse(jsonArray: array)
        XCTAssert(dataManager.tasks[3].order == 3)
    }

    func testDeletedTaskByIndexShouldRemoveItFromArrayAndAPI() {
        let exp0 = expectation(description: "1testDeletedTaskByIndexShouldRemoveItFromArrayAndAPI")
        let exp1 = expectation(description: "2testDeletedTaskByIndexShouldRemoveItFromArrayAndAPI")
        
        // GIVEN (arrange)
        let task = Task(name: "Pray")
        dataManager.tasks += [task]
        let apiService = APIService(responseHandler: networkCoordinator)
        apiService.insert(task: task, forUser: networkCoordinator.currentUser!)

        // WHEN (act)
        apiService.getTasks(forUser: networkCoordinator.currentUser!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.dataManager.delete(taskAtIndex: self.dataManager.tasks.count-1)
            exp0.fulfill()
        })

        // THEN (assert)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            XCTAssert(!self.dataManager.tasks.contains(where: {$0.uniqueID == task.uniqueID}))
            exp1.fulfill()
        })
        wait(for: [exp0, exp1], timeout: 15.0)
    }
    
    
    // CORE DATA
    
    func testShouldDeleteAllCompletedTasks() {
        let task = dataManager.tasks[0]
        task.userCompleted = "billy"
        let otherTask = dataManager.tasks[1]
        
        let predicate = NSPredicate(format: "userCompleted != nil")
        let coreService = CoreService()
        coreService.syncTasksToCoreData(tasks: dataManager.tasks)
        coreService.deleteAllTasks(withPredicate: predicate)
        
        let fetch = NSFetchRequest<TaskModel>(entityName: "TaskModel")
        fetch.predicate = NSPredicate(format: "uniqueID == %@", task.uniqueID)
        let fetchedTaskModels = try! coreService.persistentContainer.viewContext.fetch(fetch)
        
        fetch.predicate = NSPredicate(format: "uniqueID == %@", otherTask.uniqueID)
        let otherFetchedTaskModels = try! coreService.persistentContainer.viewContext.fetch(fetch)
        
        XCTAssert(fetchedTaskModels.count == 0 && otherFetchedTaskModels.count == 1)
        
    }
    
    // NETWORKING
    func testNewTaskShouldBeAccessibleFromAPI() {
        let exp = expectation(description: "testNewTaskShouldBeAccessibleFromAPI")
        
        let task = Task(name: "Shave butt")
        
        let apiService = APIService(responseHandler: networkCoordinator)
        apiService.insert(task: task, forUser: networkCoordinator.currentUser!)
        apiService.getTasks(forUser: networkCoordinator.currentUser!)

        // The test needs to be delayed so that the data task in getTasks()
        // has time to ping the API and get a response
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            XCTAssert(self.dataManager.tasks.contains(where: {$0.name == task.name}))
            exp.fulfill()
        })
        wait(for: [exp], timeout: 15.0)
    }
    func testOldTaskShouldBeChangedInAPI() {
        let exp = expectation(description: "testOldTaskShouldBeChangedInAPI")
        
        let task = dataManager.tasks[0]
        task.userCompleted = "billy"
        
        let apiService = APIService(responseHandler: networkCoordinator)
        apiService.insert(task: task, forUser: networkCoordinator.currentUser!)
        task.userCompleted = "Sven"
        apiService.set(task: task, forUser: networkCoordinator.currentUser!)
        apiService.getTasks(forUser: networkCoordinator.currentUser!)
        
        // The test needs to be delayed so that the data task in getTasks()
        // has time to ping the API and get a response
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            XCTAssert(self.dataManager.tasks.contains(where: {$0.userCompleted != nil}))
            exp.fulfill()
        })
        wait(for: [exp], timeout: 15.0)
    }
    
    
    // test if the delete function works across multiple devices.

    func testTaskDeletedFromAPIRemovedFromDataSourceAfterRefresh() {
        let exp0 = expectation(description: "1testTaskDeletedFromAPIRemovedFromDataSourceAfterRefresh")
        let exp1 = expectation(description: "2testTaskDeletedFromAPIRemovedFromDataSourceAfterRefresh")
        let exp2 = expectation(description: "2testTaskDeletedFromAPIRemovedFromDataSourceAfterRefresh")

        // Task is created on home device and sent to API
        let task = Task(name: "Smoke a bowl")
        dataManager.tasks += [task]
        print("Smoke a bowl ID is \(task.uniqueID)")
        
        let apiService = APIService(responseHandler: networkCoordinator)
        // One device inserts task
        apiService.insert(task: task, forUser: self.networkCoordinator.currentUser!)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0, execute: {
            // Other device deletes task from API
            apiService.delete(task: task, forUser: self.networkCoordinator.currentUser!)
            exp0.fulfill()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
            // Home device gets tasks from API
            self.dataManager.refresh()
            exp1.fulfill()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
            // Just wait for previous requests to process
            exp2.fulfill()
        })
        
        wait(for: [exp0, exp1, exp2], timeout: 15.0)
        XCTAssert(!self.dataManager.tasks.contains(where: {$0.uniqueID == task.uniqueID}))
    }

    
    
    func testPerformanceExample() {
        
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
