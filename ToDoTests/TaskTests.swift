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
        let task = TaskModel(withJSON: MockTaskJSON, intoContext: context)
        XCTAssertEqual(task.name, "DO DISHES")
        XCTAssertNil(task.userCompleted)
        XCTAssertNil(task.dateCompleted)
    }
    
}

class DatSourceTests: XCTestCase {
    var dataSource : TaskTableViewDataSource!
    
    override func setUp() {
        super.setUp()
        dataSource = TaskTableViewDataSource(controller: TaskTableViewController())
        dataSource.tasks = [Task(name: "Suck dicks"), Task(name: "Eat butts"), Task(name: "Kick nuts")]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLastRowShouldBeEqualToNumberOfTasks() {
        dataSource.tasks += [Task(name: "Eat eggs")]
        XCTAssert(dataSource.controller.lastRow == 4)
    }
    
    func testLastTaskOrderShouldEqualItsIndexInArray() {
        dataSource.networkCoordinator = NetworkCoordinator(dataSource: dataSource)
        dataSource.networkCoordinator.handleAPIResponse(jsonArray: [MockTaskJSON])
        print("order is \(dataSource.tasks[3].order)")
        XCTAssert(dataSource.tasks[3].order < 3)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
