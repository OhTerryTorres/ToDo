//
//  AuthenticationAlertDelegate.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class AuthenticationAlertDelegate {
    
    var controller : AuthenticationDelegate!
    
    lazy var loginAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Log In", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
        }
        
        let loginAction = UIAlertAction(title: "Log In", style: .cancel, handler: {
            alert -> Void in
            
            if let email = alertController.textFields?[0].text, let password = alertController.textFields?[1].text {
                if email == "" || password == "" {
                    self.loginAlertController.message = "Fields are missing!"
                    self.controller.presentLoginAlert()
                } else {
                    self.controller.login(email: email, password: password)
                }
            }
            
        })
        
        let registerAlertAction = UIAlertAction(title: "Register", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.controller.presentRegisterAlert()
        })
        
        alertController.addAction(loginAction)
        alertController.addAction(registerAlertAction)
        return alertController
    }()
    
    lazy var registerAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Register", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
            textField.text = "kefkajr@gmail.com"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.text = "ultima"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Confirm Password"
            textField.text = "ultima"
        }
        
        let registerAction = UIAlertAction(title: "Register", style: .cancel, handler: {
            alert -> Void in
            
            guard let email = alertController.textFields?[0].text else { return }
            guard let password = alertController.textFields?[1].text else { return }
            guard let confirmPassword = alertController.textFields?[2].text else { return }
            
            if password == confirmPassword {
                self.controller.register(email: email, password: password)
            } else {
                self.registerAlertController.message = "Passwords don't match!"
                self.controller.presentRegisterAlert()
            }

        })
        
        let loginAlertAction = UIAlertAction(title: "Log In", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.controller.presentLoginAlert()
        })
        
        alertController.addAction(registerAction)
        alertController.addAction(loginAlertAction)
        return alertController
    }()
    
    
    init(forController controller: AuthenticationDelegate) {
        self.controller = controller
    }
    

    
}
