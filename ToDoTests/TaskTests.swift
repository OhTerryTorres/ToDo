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
    
    var mockTaskJSON : [String : Any] {
        var json : [String : Any] = [:]
        json[TaskPropertyKeys.uniqueID.rawValue] = "BB7B4816-6AF0-48DC-96DF-7B1629C50C640000"
        json[TaskPropertyKeys.name.rawValue] = "DO DISHES"
        json[TaskPropertyKeys.userCreated.rawValue] = "BB7B4816-6AF0-48DC-96DF-7B1629C50C64"
        json[TaskPropertyKeys.userCompleted.rawValue] = nil
        json[TaskPropertyKeys.dateCreated.rawValue] = "2017-04-17 20:45:21"
        json[TaskPropertyKeys.dateCompleted.rawValue] = ""
        return json
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTaskJSONIntegration() {
        //create JSON
        let task = Task(withJSON: mockTaskJSON, intoContext: context)
        XCTAssertEqual(task.name, "DO DISHES")
        XCTAssertNil(task.userCompleted)
        XCTAssertNil(task.dateCompleted)
    }
    
}
