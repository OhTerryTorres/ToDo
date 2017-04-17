//
//  APIRequestService.swift
//  Starbucker
//
//  Created by TerryTorres on 3/29/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

struct APIService {
    
    enum PostMethod : String {
        case insert = "insert"
        case set = "set"
    }
    
    var responseHandler : APIResponseHandler!
    
    init(withController controller: APIResponseHandler?) {
        self.responseHandler = controller
    }
    
    // MARK: - API request
    
    func postRequest(task: Task, method: PostMethod) {
        print("post request with method: \(method.rawValue)")
        let urlString = "http://www.terry-torres.com/todo/api/api.php?method=\(method.rawValue)"
        
        var json : [String : Any] = [:]
        
        if let uniqueID = task.uniqueID { json[TaskPropertyKeys.uniqueID.rawValue] = uniqueID }
        if let name = task.name { json[TaskPropertyKeys.name.rawValue] = name }
        if let userCreated = task.userCreated { json[TaskPropertyKeys.userCreated.rawValue] = userCreated }
        if let userCompleted = task.userCompleted { json[TaskPropertyKeys.userCompleted.rawValue] = userCompleted }
        if let dateCreated = task.dateCreated { json[TaskPropertyKeys.dateCreated.rawValue] = MySQLDateFormatter.string(from: dateCreated as Date) }
        if let dateCompleted = task.dateCompleted { json[TaskPropertyKeys.dateCompleted.rawValue] = MySQLDateFormatter.string(from: dateCompleted as Date) }
        
        print("serializing outgoing JSON")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("outgoing JSONSerialization error")
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        print("constructing post request data task")
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("error \(error.debugDescription)"); return }
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("dataString is\n\(dataString)")
            }
        }
        dataTask.resume()
    }
    
    func insert(task: Task) {
        postRequest(task: task, method: .insert)
        
    }
    func set(task: Task) {
        postRequest(task: task, method: .set)
    }
    func getTasks() {
        // Cannot be performed without a response handler
        guard responseHandler != nil else { print("error: no response handler"); return }
        let urlString = "http://www.terry-torres.com/todo/api/api.php?method=get"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("error \(error.debugDescription)"); return }
            guard let data = data else { print("no data"); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                    print("sending returned JSON to handler")
                    self.responseHandler.handleAPIResponse(jsonArray: json)
                }
            } catch {
                print("JSONSerialization error")
            }
        }
        dataTask.resume()
    }
    
    func delete(task: Task) {
        let urlString = "http://www.terry-torres.com/todo/api/api.php?method=delete"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        
        guard let id = task.uniqueID else { return }
        let idData = id.data(using: .utf8)
        request.httpMethod = "POST"
        request.httpBody = idData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("error \(error.debugDescription)"); return }
            print("no error")
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("dataString is\n\(dataString)")
            }
        }
        dataTask.resume()
    }

    
    
}
