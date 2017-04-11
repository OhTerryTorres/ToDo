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
let USER_COLOR = UIColor.blue
let GUEST_COLOR = UIColor.green


var MySQLDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()
