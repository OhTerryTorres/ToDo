//
//  ToDoTests.swift
//  ToDoTests
//
//  Created by TerryTorres on 3/24/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import XCTest
@testable import ToDo

class ToDoTests: XCTestCase {
    var textFieldDelegate : TaskTextFieldDelegate!
    var taskTableViewController : TaskTableViewController!
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        taskTableViewController = TaskTableViewController()
        taskTableViewController.dataSource.tasks = [Task(name: "Suck dicks"), Task(name: "Eat butts"), Task(name: "Kick nuts")]
        textFieldDelegate = TaskTextFieldDelegate(forController: taskTableViewController)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
