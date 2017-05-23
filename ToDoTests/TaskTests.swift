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
    func testTaskShouldBeAccessibleFromAPI() {
        print("FUCK!\r\n")
        for task in dataSource.tasks {
            print(task.name)
        }
        print("\r\nFUCK!")
        
        // May need to build in a NAME paramete for the API functions.
        let apiService = APIService(responseHandler: networkCoordinator)
        apiService.insert(task: MockTask, forUser: "test")
        apiService.getTasks(forUser: "test")
        
        print("SHIT!\r\n")
        for task in dataSource.tasks {
            print(task.name)
        }
        print("\r\nSHIT!")
        
        
        
        // IS multithreading causing a problem here?
        // The test is being resolved before the API finishes working maybe?
        // Let's delay the test.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            XCTAssert(self.dataSource.tasks[0].name == "DO DISHES")
        })
        
    }
 
    
    func testDeletedTaskByIndexShouldRemoveItFromArray() {
        // GIVEN (arrange)
        let task = dataSource.tasks[0]
        // WHEN (act)
        dataSource.delete(taskAtIndex: 0)
        // THEN (asser)
        XCTAssert(!dataSource.tasks.contains(where: { $0.name == task.name }))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
