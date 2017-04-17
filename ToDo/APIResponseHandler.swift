//
//  APIResponseHandler.swift
//  Starbucker
//
//  Created by TerryTorres on 3/29/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

protocol APIResponseHandler {
    // Handle JSON dict from APIRequestService
    func handleAPIResponse(jsonArray : [[String:Any]])
}
