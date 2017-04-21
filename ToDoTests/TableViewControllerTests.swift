//
//  TableViewControllerTests.swift
//  ToDo
//
//  Created by TerryTorres on 4/6/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import XCTest
@testable import ToDo

class TableViewControllerTests: XCTestCase {
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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
