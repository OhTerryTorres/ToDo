//
//  PushNotificationService.swift
//  ToDo
//
//  Created by TerryTorres on 6/7/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

struct PushNotificationService {
    
    enum PostMethod : String {
        case upload = "upload"
        case push = "push"
        case acknowledge = "acknowledge"
    }
    
    init() {
        
    }
    
    func postRequest(method: PostMethod, username: String, passphrase: String? = nil, deviceToken: String? = nil) {
        var urlString = "http://www.terry-torres.com/todo/api/"
        var endpoint = ""
        var postString = ""
        switch method {
        case .push:
            guard let pass = passphrase else { print("no passphrase!"); return }
            if let token = deviceToken {
                postString = "username=\(username)&passphrase=\(pass)&sourceTokenString=\(token)"
            } else {
                postString = "username=\(username)&passphrase=\(pass)&sourceTokenString="
            }
            endpoint = "pushNotification.php"
        case .upload:
            guard let token = deviceToken else { print("no token!"); return }
            postString = "username=\(username)&deviceTokenString=\(token)"
            endpoint = "uploadDeviceToken.php"
        case .acknowledge:
            guard let token = deviceToken else { print("no token!"); return }
            postString = "username=\(username)&deviceTokenString=\(token)"
            endpoint = "acknowledgeNotification.php"
        }
        urlString += endpoint
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("push service error \(error.debugDescription)"); return }
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("data from push service (\(method.rawValue)) request is\n\(dataString)")
            }
        }
        dataTask.resume()
    }
    
    func pushNotification(username: String, passphrase: String, token: String? = nil)  {
        postRequest(method: .push, username: username, passphrase: passphrase, deviceToken: token)
    }
    func acknowledgeNotification(username: String, token: String)  {
        postRequest(method: .acknowledge, username: username, deviceToken: token)
    }
    func uploadDeviceToken(token: String, forUser username: String) {
        postRequest(method: .upload, username: username, deviceToken: token)
    }
    
}
