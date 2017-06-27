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
    
    enum AuthenticationMethod : String {
        case login = "login"
        case register = "register"
        var endpoint: String {
            switch self {
            case .login: return "userLogin.php"
            case .register: return "userRegister.php"
            }
        }
    }
    
    var responseHandler : AuthenticationResponseHandler!
    
    init(responseHandler: AuthenticationResponseHandler?) {
        self.responseHandler = responseHandler
    }
    
    
    func authenticate(username: String, email: String? = nil, password: String, method: AuthenticationMethod) {
        var urlString = "http://www.terry-torres.com/todo/api/"
        var postString = ""
        switch method {
        case .login:
            postString = "username=\(username)&password=\(password)"
        case .register:
            guard let mail = email else { return }
            postString = "username=\(username)&email=\(mail)&password=\(password)"
        }
        urlString += method.endpoint
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
                print("\(method.rawValue) JSONSerialization error:  \(error.localizedDescription)")
            }
        }   
        dataTask.resume()
    }

    
}
