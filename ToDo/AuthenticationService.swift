//
//  AuthenticationService.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

// This is used to deal with logging in and registering users,
// and speaking to the remote API specifically for those reasons.
struct AuthenticationService {
    
    
    var responseHandler : AuthenticationResponseHandler!
    
    init(responseHandler: AuthenticationResponseHandler?) {
        self.responseHandler = responseHandler
    }
    
    
    func authenticate(username: String, email: String? = nil, password: String, method: AuthenticationMethod) {
        var urlString = "http://www.terry-torres.com/todo/api/"
        var postString = ""
        var methodType = ""
        switch method {
        case .login:
            urlString += "userLogin.php"
            postString = "username=\(username)&password=\(password)"
            methodType = "login"
        case .register:
            guard let mail = email else { return }
            urlString += "userRegister.php"
            postString = "username=\(username)&email=\(mail)&password=\(password)"
            methodType = "register"
        }
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                self.responseHandler.presentAlertOnMainQueue(message: "Unable to connect!")
                return
            }
            print(response ?? "no response")
            guard let data = data else { print("no data"); return }
            if let dataString = String.init(data: data, encoding: .utf8)  {
                print("data from login request is\n\(dataString)")
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    guard let status = json["status"] as? String, let message = json["message"] as? String else { return }
                    print(message)
                    self.responseHandler.handleAuthenticationResponse(username: username, status: status, message: message)
                }
                // ******
                // if something goes wrong in the PHP that is neither an explicit success or error, nothing will happen
            } catch {
                print("\(methodType) JSONSerialization error:  \(error.localizedDescription)")
            }
        }   
        dataTask.resume()
    }

    
}
