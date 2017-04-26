//
//  AuthenticationAlertHandler.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class AuthenticationAlertHandler {
    
    var coordinator : NetworkCoordinator!
    var currentAlertController : UIAlertController!

    
    lazy var loginAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Log In", message: "", preferredStyle: .alert)
        
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
        
        let loginAction = UIAlertAction(title: "Log In", style: .default, handler: {
            alert -> Void in
            
            if let user = alertController.textFields?[0].text, let password = alertController.textFields?[1].text {
                if user == "" || password == "" {
                    self.loginAlertController.message = "Fields are missing!"
                    self.present(alertController: alertController)
                } else {
                    self.coordinator.authenticate(user: user, password: password, method: .login)
                }
            }
            
        })
        
        let registerAlertAction = UIAlertAction(title: "Register", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.present(alertController: self.registerAlertController)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(loginAction)
        alertController.addAction(registerAlertAction)
        alertController.addAction(cancelAction)
        return alertController
    }()
    
    lazy var registerAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Register", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = alertController.textFields?[0].text// Default with any text that was already typed in
            textField.placeholder = "Email"
            textField.clearButtonMode = .always
            textField.keyboardType = .emailAddress
            //textField.text = "kefkajr@gmail.com"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = alertController.textFields?[1].text // Default with any text that was already typed in
            textField.placeholder = "Password"
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
            //textField.text = "ultima"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Confirm Password"
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
            //textField.text = "ultima"
        }
        
        let registerAction = UIAlertAction(title: "Register", style: .default, handler: {
            alert -> Void in
            
            guard let user = alertController.textFields?[0].text else { return }
            guard let password = alertController.textFields?[1].text else { return }
            guard let confirmPassword = alertController.textFields?[2].text else { return }
            
            if password == confirmPassword {
                self.coordinator.authenticate(user: user, password: password, method: .register)
            } else {
                self.registerAlertController.message = "Passwords don't match!"
                self.present(alertController: alertController)
            }

        })
        
        let loginAlertAction = UIAlertAction(title: "Log In", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.present(alertController: self.loginAlertController)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(registerAction)
        alertController.addAction(loginAlertAction)
        alertController.addAction(cancelAction)
        return alertController
    }()
    
    
    init(coordinator: NetworkCoordinator) {
        self.coordinator = coordinator
        self.currentAlertController = loginAlertController
    }
    
    
    func present(alertController: UIAlertController? = nil, message: String? = nil) {
        let alert = alertController ?? self.currentAlertController
        alert?.message = message
        if let presentedViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.presentedViewController {
            if presentedViewController != alert {
                self.currentAlertController = alert
            }
        } else {
            self.currentAlertController = alert
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(self.currentAlertController, animated: true, completion: nil)
        }
    }

    
}
