//
//  Constants.swift
//  ToDo
//
//  Created by TerryTorres on 4/4/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation
import UIKit

var USER_ID = UIDevice.current.identifierForVendor!.uuidString
let USER_COLOR = UIColor(colorLiteralRed: 208.0/255.0, green: 135.0/255.0, blue: 154.0/255.0, alpha: 1.0)
let GUEST_COLOR = UIColor(colorLiteralRed: 98.0/255.0, green: 146.0/255.0, blue: 150.0/255.0, alpha: 1.0)
let PUSH_PASSPHRASE = "REDACTED"

enum ReloadMethod {
    case full // Reloads entire tableview
    case partial // Reloads last two rows, if a new task is added by the user.
}
enum AuthenticationMethod {
    case login
    case register
}

var MySQLDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

enum TaskPropertyKeys : String {
    case uniqueID = "uniqueID"
    case name = "name"
    case userCreated = "userCreated"
    case userCompleted = "userCompleted"
    case dateCreated = "dateCreated"
    case dateCompleted = "dateCompleted"
    case lastUpdate = "lastUpdate"
    case order = "order"
}

enum UserKeys : String {
    case username = "username"
    case numberOfTasks = "numberOfTasks"
    case deviceToken = "deviceToken"
}

extension String {
    
    var safeEmail: String {
        let noAt = self.replacingOccurrences(of: "@", with: "at")
        let noDot = noAt.replacingOccurrences(of: ".", with: "dot")
        return noDot
    }
    var withoutEmailSuffix: String {
        guard let atIndex = self.range(of: "@")?.upperBound else { return self }
        return self.substring(with: self.startIndex..<atIndex)
    }
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
}

extension Array where Element:Ordered {
    mutating func maintainOrder() {
        for index in 0..<self.count {
            self[index].order = index
        }
    }
}
