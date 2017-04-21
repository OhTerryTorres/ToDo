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
let USER_COLOR = UIColor(colorLiteralRed: 255.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1.0)
let GUEST_COLOR = UIColor(colorLiteralRed: 0.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)

enum ReloadMethod {
    case full // Reloads entire tableview
    case partial // Reloads last two rows, if a new task is added by the user.
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
}

enum UserKeys : String {
    case user = "user"
}

extension String {
    
    func safeEmail() -> String {
        let noAt = self.replacingOccurrences(of: "@", with: "at")
        let noDot = noAt.replacingOccurrences(of: ".", with: "dot")
        return noDot
    }
    
}
