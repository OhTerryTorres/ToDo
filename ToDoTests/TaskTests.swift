//
//  TaskTests.swift
//  ToDo
//
//  Created by TerryTorres on 4/11/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import XCTest
@testable import ToDo

class TaskTests: XCTestCase {
    
    let requestService = APIRequestService(withController: nil)
    let controller = TableViewController()
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        requestService.responseHandler = controller
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test for a successful request from MySQL
    func testTaskRetrieval() {
        requestService.getTasks()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            XCTAssertNotNil(self.controller.tasks.first(where: { $0.name == "Awesome!" }))
        })
    }
    
}
