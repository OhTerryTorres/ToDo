//
//  AuthenticationAlertHandler.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class AuthenticationAlertHandler {
    
    var authenticationHandler : AuthenticationHandler!
    var currentAlertController : UIAlertController!

    enum AlertType {
        case login, register
    }
    
    lazy var loginAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Log In", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Username"
            textField.clearButtonMode = .always
            textField.keyboardType = .emailAddress
            
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
        }
        
        let loginAction = UIAlertAction(title: "Log In", style: .default, handler: {
            alert -> Void in
            
            if let username = alertController.textFields?[0].text, let password = alertController.textFields?[1].text {
                if username == "" || password == "" {
                    self.present(alertType: .login, message: "Fields are missing!")
                } else {
                    let authenticator = AuthenticationService(responseHandler: self.authenticationHandler)
                    authenticator.authenticate(username: username, password: password, method: .login)
                }
            }
            
        })
        
        let registerAlertAction = UIAlertAction(title: "Register", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.present(alertType: .register)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(loginAction)
        alertController.addAction(registerAlertAction)
        alertController.addAction(cancelAction)
        alertController.preferredAction = loginAction
        return alertController
    }()
    
    lazy var registerAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Register", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Username"
            textField.clearButtonMode = .always
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
            textField.clearButtonMode = .always
            textField.keyboardType = .emailAddress
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Confirm Password"
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
        }
        
        let registerAction = UIAlertAction(title: "Register", style: .default, handler: {
            alert -> Void in
            
            guard let username = alertController.textFields?[0].text else { return }
            guard let email = alertController.textFields?[1].text else { return }
            guard let password = alertController.textFields?[2].text else { return }
            guard let confirmPassword = alertController.textFields?[3].text else { return }
            
            if password == confirmPassword && username.isAlphanumeric {
                let authenticator = AuthenticationService(responseHandler: self.authenticationHandler)
                authenticator.authenticate(username: username, email: email, password: password, method: .register)
            } else if password != confirmPassword {
                self.present(alertType: .register, message: "Passwords don't match!")
            } else if !username.isAlphanumeric {
                self.present(alertType: .register, message: "Please keep usernames alphanumeric!")
            }

        })
        
        let loginAlertAction = UIAlertAction(title: "Log In", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.present(alertType: .login)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(registerAction)
        alertController.addAction(loginAlertAction)
        alertController.addAction(cancelAction)
        alertController.preferredAction = registerAction
        return alertController
    }()
    
    
    init(authenticationHandler: AuthenticationHandler) {
        self.authenticationHandler = authenticationHandler
        self.currentAlertController = loginAlertController
    }
    
    func present(alertType: AlertType? = nil, message: String? = nil) {
        var alertController : UIAlertController = self.currentAlertController
        if let type = alertType {
            switch type {
            case .login:
                alertController = loginAlertController
            case .register:
                alertController = registerAlertController
            }
            self.currentAlertController = alertController
        }
        authenticationHandler.dataSource.controller.present(alertController, animated: true)
        alertController.message = message
    }

    
}
