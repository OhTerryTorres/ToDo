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
    
    init(responseHandler: APIResponseHandler? = nil) {
        self.responseHandler = responseHandler
    }
    
    
    // MARK: - API request
    
    func postRequest(task: Task, method: PostMethod) {
        guard let user = UserDefaults.standard.object(forKey: UserKeys.user.rawValue) as? String else { return }
        let urlString = "http://www.terry-torres.com/todo/api/api.php?user=\(user.safeEmail())&method=\(method.rawValue)"
        
        var json : [String : Any] = [:]
        
        json[TaskPropertyKeys.uniqueID.rawValue] = task.uniqueID
        json[TaskPropertyKeys.name.rawValue] = task.name
        json[TaskPropertyKeys.userCreated.rawValue] = task.userCreated
        json[TaskPropertyKeys.dateCreated.rawValue] = MySQLDateFormatter.string(from: task.dateCreated)
        if let userCompleted = task.userCompleted { json[TaskPropertyKeys.userCompleted.rawValue] = userCompleted }
        if let dateCompleted = task.dateCompleted { json[TaskPropertyKeys.dateCompleted.rawValue] = MySQLDateFormatter.string(from: dateCompleted as Date) }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("outgoing JSONSerialization error")
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("error \(error.debugDescription)"); return }
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("data from post request is\n\(dataString)")
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
        guard let user = UserDefaults.standard.object(forKey: UserKeys.user.rawValue) as? String else { return }
        let urlString = "http://www.terry-torres.com/todo/api/api.php?user=\(user.safeEmail())&method=get"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("error \(error.debugDescription)"); return }
            guard let data = data else { print("no data"); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                    self.responseHandler.handleAPIResponse(jsonArray: json)
                }
            } catch {
                print("get tasks JSONSerialization error")
            }
        }
        dataTask.resume()
    }
    
    func delete(task: Task) {
        guard let user = UserDefaults.standard.object(forKey: UserKeys.user.rawValue) as? String else { return }
        let urlString = "http://www.terry-torres.com/todo/api/api.php?user=\(user.safeEmail())&method=delete"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        
        let idData = task.uniqueID.data(using: .utf8)
        request.httpMethod = "POST"
        request.httpBody = idData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("error \(error.debugDescription)"); return }
            print("no error")
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("data from delete request is\n\(dataString)")
            }
        }
        dataTask.resume()
    }

    
    
}
