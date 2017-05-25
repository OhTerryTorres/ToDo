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
        let task = Task(withJSON: MockTaskJSON)
        XCTAssertEqual(task.name, "DO DISHES")
        XCTAssertNil(task.userCompleted)
        XCTAssertNil(task.dateCompleted)
    }
    
}

class DataSourceTests: XCTestCase {
    var controller : TaskTableViewController!
    var dataSource : TaskTableViewDataSource!
    var textFieldDelegate : TaskTextFieldDelegate!
    var keyboardManager : KeyboardManager!
    var networkCoordinator : NetworkCoordinator!
    var authenticationAlertHandler : AuthenticationAlertHandler!
    
    override func setUp() {
        super.setUp()
        controller = TaskTableViewController()
        
        controller.dataSource = TaskTableViewDataSource(controller: controller)
        dataSource = controller.dataSource
        dataSource.networkCoordinator = NetworkCoordinator(dataSource: dataSource)
        networkCoordinator = dataSource.networkCoordinator
        networkCoordinator.currentUser = "test"
        authenticationAlertHandler = networkCoordinator.authenticationAlertHandler
        
        controller.taskTextFieldDelegate = TaskTextFieldDelegate(controller: controller)
        textFieldDelegate = controller.taskTextFieldDelegate
        textFieldDelegate.keyboardManager = KeyboardManager(controller: controller, textFieldDelegate: textFieldDelegate)
        keyboardManager = textFieldDelegate.keyboardManager
        
        dataSource.tasks = [Task(name: "Suck dicks"), Task(name: "Eat butts"), Task(name: "Kick nuts")]

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        controller = nil
        super.tearDown()
    }
    
    // MANAGING TASKS
    func testLastRowShouldBeEqualToNumberOfTasks() {
        dataSource.tasks += [Task(name: "Eat eggs")]
        XCTAssert(dataSource.controller.lastRow == 4)
    }
    
    func testTaskOrderShouldEqualItsIndexInArray() {
        dataSource.networkCoordinator.handleAPIResponse(jsonArray: [MockTaskJSON])
        XCTAssert(dataSource.tasks[3].order == 3)
    }

    func testDeletedTaskByIndexShouldRemoveItFromArrayAndAPI() {
        // GIVEN (arrange)
        let task = dataSource.tasks[0]
        let apiService = APIService(responseHandler: networkCoordinator)
        apiService.insert(task: task, forUser: networkCoordinator.currentUser!)
        // WHEN (act)
        apiService.getTasks(forUser: networkCoordinator.currentUser!)
        dataSource.delete(taskAtIndex: 0)
        // THEN (assert)
        XCTAssert(!dataSource.tasks.contains(where: { $0.uniqueID == task.uniqueID }))
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            XCTAssert(self.dataSource.tasks.contains(where: {$0.uniqueID == task.uniqueID}))
        })
    }
    
    
    // CORE DATA
    
    func testShouldDeleteAllCompletedTasks() {
        let task = dataSource.tasks[0]
        task.userCompleted = "billy"
        let otherTask = dataSource.tasks[1]
        
        let predicate = NSPredicate(format: "userCompleted != nil")
        let coreService = CoreService()
        coreService.syncTasksToCoreData(tasks: dataSource.tasks)
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
        let exp = expectation(description: "testOldTaskShouldBeChangedInAPI")
        
        let task = dataSource.tasks[0]
        
        let apiService = APIService(responseHandler: networkCoordinator)
        apiService.insert(task: task, forUser: networkCoordinator.currentUser!)
        apiService.getTasks(forUser: networkCoordinator.currentUser!)

        // The test needs to be delayed so that the data task in getTasks()
        // has time to ping the API and get a response
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            XCTAssert(self.dataSource.tasks.contains(where: {$0.uniqueID == task.uniqueID}))
            exp.fulfill()
        })
        wait(for: [exp], timeout: 15.0)
    }
    func testOldTaskShouldBeChangedInAPI() {
        let exp = expectation(description: "testOldTaskShouldBeChangedInAPI")
        
        let task = dataSource.tasks[0]
        task.userCompleted = "billy"
        
        let apiService = APIService(responseHandler: networkCoordinator)
        apiService.insert(task: task, forUser: networkCoordinator.currentUser!)
        task.userCompleted = "Sven"
        apiService.set(task: task, forUser: networkCoordinator.currentUser!)
        apiService.getTasks(forUser: networkCoordinator.currentUser!)
        
        // The test needs to be delayed so that the data task in getTasks()
        // has time to ping the API and get a response
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            XCTAssert(self.dataSource.tasks.contains(where: {$0.userCompleted != nil}))
            exp.fulfill()
        })
        wait(for: [exp], timeout: 15.0)
    }
    
    
    // test if the delete function works on multiple devices.
    
    // Create a second composition root matching the one in setUp()
    // Have root 1 make a completed task and set it in the API.
    // Have root 2 get all tasks from the API.
    // Have root 1 delete all completed tasks in the API.
    // Have root 2's dataSource saveData()
    // Test to make sure that root 2's tasks do NOT contain the completed task.
    
    /*
     This will probably fail.
     Core Data is synced with the displayed task, but NOT with the API.
     The APIService should have a method that receives an array of tasks, and removes the ones that are NOT in the API.
     This should be called when the app launches, AFTER loading tasks from Core Data.
    */
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
