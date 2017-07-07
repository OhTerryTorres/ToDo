//
//  ToDoUITests.swift
//  ToDoUITests
//
//  Created by TerryTorres on 3/24/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import XCTest

class UIAuthenticationTest: XCTestCase {
    
    var app : XCUIApplication!
    var navBar : XCUIElement!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        continueAfterFailure = false
        app.launch()
        
        
        navBar = app.navigationBars["To Do"]
        
        // This string should be changed to match the testing account
        navBar.tap()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Open login alert
    // Open register alert
    // Cancel and close alert
    
    func testDisplayLoginAlertThenDisplayRegisterAlertThenCloseRegisterAlert() {
        XCTAssert(app.alerts["Log In"].exists)
        
        let logInAlert = app.alerts["Log In"]
        XCTAssert(logInAlert.buttons["Register"].exists)
        
        let callRegisterAlertButton = logInAlert.buttons["Register"]
        callRegisterAlertButton.tap()
        
        XCTAssert(app.alerts["Register"].exists)
        
        let registerAlert = app.alerts["Register"]
        let cancelButton = registerAlert.buttons["Cancel"]
        
        XCTAssert(cancelButton.exists)

        guard waitForElementToAppear(cancelButton) else { return XCTFail() }
        
        cancelButton.tap()
        
        XCTAssert(!app.alerts["Register"].exists)
        
    }
    
    // Test successful registration – generate a random username and password
    func testSuccessfulRegistration() {
        let logInAlert = app.alerts["Log In"]
        XCTAssert(logInAlert.buttons["Register"].exists)
        let callRegisterAlertButton = logInAlert.buttons["Register"]
        callRegisterAlertButton.tap()
        
        XCTAssert(app.alerts["Register"].exists)
        let registerAlert = app.alerts["Register"]
        let collectionViewsQuery = registerAlert.collectionViews
        
        let usernameField = collectionViewsQuery.textFields["Username"]
        let emailField = collectionViewsQuery.textFields["Email"]
        let passwordField = collectionViewsQuery.secureTextFields["Password"]
        let confirmPasswordField = collectionViewsQuery.secureTextFields["Confirm Password"]
        
        usernameField.typeText(randomString(length: 6))
        emailField.tap()
        emailField.typeText("kefkajr@gmail.com")
        
        passwordField.tap()
        app.keys["b"].tap()
        confirmPasswordField.tap()
        app.keys["b"].tap()
        
        registerAlert.buttons["Register"].tap()
        
        XCTAssert(!app.alerts["Register"].exists)
        
        // There should only be one row
        let tablesQuery = app.tables
        print(app.tables.cells.count)
        XCTAssert(tablesQuery.cells.element(boundBy: 0).exists)
        XCTAssert(!tablesQuery.cells.element(boundBy: 2).exists)
        
    }
    
    // Test Fields Are Missing login exception
    
    func testLoginRedisplaysIfFieldsLeftBlank() {
        XCTAssert(app.alerts["Log In"].exists)
        
        let logInAlert = app.alerts["Log In"]
        
        
        XCTAssert(logInAlert.collectionViews.textFields["Username"].exists)
        XCTAssert(logInAlert.collectionViews.secureTextFields["Password"].exists)
        let usernameTextField = logInAlert.collectionViews.textFields["Username"]
        let passwordSecureTextField = logInAlert.collectionViews.secureTextFields["Password"]
        
        XCTAssert(!usernameTextField.buttons["Clear text"].exists)
        usernameTextField.typeText("test")
        XCTAssert(usernameTextField.buttons["Clear text"].exists)
        XCTAssert(!passwordSecureTextField.buttons["Clear text"].exists)
        
        logInAlert.buttons["Log In"].tap()
        XCTAssert(logInAlert.staticTexts["Fields are missing!"].exists)
    }
    
    // Test Wrong Password login exception
    
    func testWrongPassword() {
        
        let logInAlert = app.alerts["Log In"]
        let usernameTextField = logInAlert.collectionViews.textFields["Username"]
        let passwordSecureTextField = logInAlert.collectionViews.secureTextFields["Password"]
        
        usernameTextField.typeText("test")
        passwordSecureTextField.tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        app.keys["s"].tap()
        app.keys["p"].tap()
        
        logInAlert.buttons["Log In"].tap()
        
        guard waitForElementToAppear(logInAlert) else { return XCTFail() }
        XCTAssert(logInAlert.staticTexts["Username or password is invalid!"].exists)        
    }
    
    // Test successful login – wait for for presence of cells
    func testSuccessfulLogin() {
        let logInAlert = app.alerts["Log In"]
        let usernameTextField = logInAlert.collectionViews.textFields["Username"]
        let passwordSecureTextField = logInAlert.collectionViews.secureTextFields["Password"]
        
        usernameTextField.typeText("test")
        passwordSecureTextField.tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        app.keys["s"].tap()
        app.keys["t"].tap()
        
        logInAlert.buttons["Log In"].tap()
        
        let tablesQuery = app.tables
        let prayTextField = tablesQuery.textFields["Pray"]
        guard waitForElementToAppear(prayTextField) else { return XCTFail() }
        XCTAssert(prayTextField.exists)

        
    }
    
    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let exp = expectation(for: predicate, evaluatedWith: element,
                                      handler: nil)
        let _ = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let _ = XCTKVOExpectation(keyPath: "exists", object: element, expectedValue: true)
        let _ = XCTNSNotificationExpectation(name: "notificationName")
        
        let result = XCTWaiter().wait(for: [exp], timeout: 5, enforceOrder: false)
        return result == .completed
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    
}

class TextFieldTest: XCTestCase {
    
    var app : XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        continueAfterFailure = false
        app.launch()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Open keyboard by tapping textfield in cell
    // Pull down to reload list
    // Check if keyboard is still visible
    
    func testKeyboardStaysOnScreenAfterRefresh() {
        let tablesQuery = app.tables
        let table = app.otherElements.containing(.navigationBar, identifier:"To Do").children(matching: .other).element.children(matching: .other).element.children(matching: .table).element
        
        // Tapping cell should activate text field
        tablesQuery.cells.element(boundBy: 0).tap()
        XCTAssert(app.keyboards.count > 0)
        
        tablesQuery.children(matching: .cell).element(boundBy: 0).children(matching: .textField).element.tap()
        table.swipeDown()
        
        XCTAssert(app.keyboards.count > 0)
    }
        
    
    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let exp = expectation(for: predicate, evaluatedWith: element,
                              handler: nil)
        let _ = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let _ = XCTKVOExpectation(keyPath: "exists", object: element, expectedValue: true)
        let _ = XCTNSNotificationExpectation(name: "notificationName")
        
        let result = XCTWaiter().wait(for: [exp], timeout: 5, enforceOrder: false)
        return result == .completed
    }
    
}

class UIHideCompletedTest: XCTestCase {
    
    var app : XCUIApplication!
    var navBar : XCUIElement!
    var completion : XCUIElement!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        continueAfterFailure = false
        app.launch()
        
        
        navBar = app.navigationBars["To Do"]
        completion = navBar.images["completionTrue"]
        
    }
    
    // Test for the image to change, get tapped, then change back
    func testImageChange() {
        completion.tap()
        guard waitForElementToAppear(navBar.images["completionFalse"]) else { return XCTFail() }
        navBar.images["completionFalse"].tap()
        guard waitForElementToAppear(navBar.images["completionTrue"]) else { return XCTFail() }
        XCTAssert(navBar.images["completionTrue"].exists)
    }
    
    
    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let exp = expectation(for: predicate, evaluatedWith: element,
                              handler: nil)
        
        let result = XCTWaiter().wait(for: [exp], timeout: 5, enforceOrder: false)
        return result == .completed
    }
    
    
    
}
