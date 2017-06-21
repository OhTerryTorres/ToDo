//
//  APIRequestService.swift
//  Starbucker
//
//  Created by TerryTorres on 3/29/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

struct APIService {
    
    // Functionally the same as far as the API is concerned,
    // but only posting a new task (insert) results in a push notification.
    enum PostMethod : String {
        case insert = "insert"
        case set = "set"
        case delete = "delete"
    }
    
    var responseHandler : APIResponseHandler!
    var catcher : FailedRequestCatcher!
    
    init(responseHandler: APIResponseHandler? = nil, catcher: FailedRequestCatcher? = nil) {
        self.responseHandler = responseHandler
        self.catcher = catcher
    }
    
    
    // MARK: - API request
    
    func insert(task: Task, forUser username: String) {
        postRequest(task: task, method: .insert, username: username)
    }
    func set(task: Task, forUser username: String) {
        task.lastUpdate = Date()
        postRequest(task: task, method: .set, username: username)
    }
    func postRequest(task: Task, method: PostMethod, username: String) {
        let urlString = "http://www.terry-torres.com/todo/api/api.php?username=\(username)&method=set"
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: task.json) else {
            print("outgoing JSONSerialization error")
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("error \(error.debugDescription)");
                self.catcher.failedRequestPackages.insert((urlRequest: request, username: username, method: method), at: 0)
                return
            }
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("data from post request is\n\(dataString)")
                if dataString.range(of: "success") != nil && method == .insert {
                    // *****
                    let pns = PushNotificationService()
                    if let deviceToken = UserDefaults.standard.object(forKey: UserKeys.deviceToken.rawValue) as? String {
                        pns.pushNotification(username: username, passphrase: PUSH_PASSPHRASE, token: deviceToken)
                    } else {
                        pns.pushNotification(username: username, passphrase: PUSH_PASSPHRASE)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
   
    
    func getTasks(forUser username: String) {
        print("getTasks started")
        // Cannot be performed without a response handler
        guard responseHandler != nil else { print("error: no response handler"); return }
        let urlString = "http://www.terry-torres.com/todo/api/api.php?username=\(username)&method=get"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("dataTask started")
            guard error == nil else {
                print("connection error \(error.debugDescription)")
                return
            }
            guard let data = data else { print("no data"); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                    self.responseHandler.handleAPIResponse(jsonArray: json)
                }
            } catch {
                print("get tasks JSONSerialization error")
            }
            print("dataTask done")
        }
        dataTask.resume()
        print("getTasks done")
    }
    
    func delete(task: Task) {
        guard let username = UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as? String else { return }
        let urlString = "http://www.terry-torres.com/todo/api/api.php?username=\(username)&method=delete"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        
        let idData = task.uniqueID.data(using: .utf8)
        request.httpMethod = "POST"
        request.httpBody = idData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("error \(error.debugDescription)")
                self.catcher.failedRequestPackages.insert((urlRequest: request, username: username, method: .delete), at: 0)
                return
            }
            print("no error")
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("data from delete request is\n\(dataString)")
            }
        }
        dataTask.resume()
    }
    
    func deleteCompleted() {
        guard let username = UserDefaults.standard.object(forKey: UserKeys.username.rawValue) as? String else { return }
        let urlString = "http://www.terry-torres.com/todo/api/api.php?username=\(username)&method=deleteCompleted"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("error \(error.debugDescription)")
                self.catcher.failedRequestPackages.insert((urlRequest: request, username: username, method: .delete), at: 0)
                return
            }
            print("no error")
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("data from delete request is\n\(dataString)")
            }
        }
        dataTask.resume()
    }
    
    
}
