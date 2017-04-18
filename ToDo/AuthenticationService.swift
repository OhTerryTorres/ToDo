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
    
    init(withController controller: AuthenticationResponseHandler?) {
        self.responseHandler = controller
    }
    
    func login(email: String, password: String) {
        let urlString = "http://www.terry-torres.com/todo/api/userLogin.php"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let postString = "email=\(email.safeEmail())&password=\(password)"
        request.httpBody = postString.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("error \(error.debugDescription)"); return }
            guard let data = data else { print("no data"); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    guard let status = json["status"] as? String, let message = json["message"] as? String else { return }
                    print(message)
                    self.responseHandler.handleLoginResponse(status: status, message: message)
                }
                // ******
                // if something goes wrong in the PHP that is neithr an explicit success or error, nothin will happen
            } catch {
                print("login JSONSerialization error")
            }
        }
        dataTask.resume()
    }
    
    func register(email: String, password: String) {
        let urlString = "http://www.terry-torres.com/todo/api/userRegister.php"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let postString = "email=\(email.safeEmail())&password=\(password)"
        request.httpBody = postString.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("error \(error.debugDescription)"); return }
            guard let data = data else { print("no data"); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    guard let status = json["status"] as? String, let message = json["message"] as? String else { return }
                    print(message)
                    self.responseHandler.handleRegisterResponse(status: status, message: message)
                }
                // ******
                // if something goes wrong in the PHP that is neithr an explicit success or error, nothin will happen
            } catch {
                print("register JSONSerialization error")
            }
        }
        dataTask.resume()
    }
    
}
