//
//  AuthenticationResponseHandler.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation


protocol AuthenticationResponseHandler {
    // Handle JSON dict from AuthenticationService
    func handleLoginResponse(status: String, message: String)
    func handleRegisterResponse(status: String, message: String)
}
