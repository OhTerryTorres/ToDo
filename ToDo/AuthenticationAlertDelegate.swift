//
//  LoginAlertDelegate.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class AuthenticationAlertDelegate {
    
    var controller : TableViewController!
    
    lazy var loginAlertController : UIAlertController = {
        let alertController = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
        }
        
        let loginAction = UIAlertAction(title: "Log In", style: .default, handler: {
            alert -> Void in
            
            let emailField = alertController.textFields![0] as UITextField
            let passwordField = alertController.textFields![1] as UITextField
            
            print("email \(emailField.text), password \(passwordField.text)")
        })
        
        let registerAlertAction = UIAlertAction(title: "Register", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.controller.present(self.registerAlertController, animated: true, completion: nil)
        })
        
        alertController.addAction(loginAction)
        alertController.addAction(registerAlertAction)
        return alertController
    }()
    
    lazy var registerAlertController : UIAlertController = {
        let alertController = UIAlertController(title: "Register", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Confirm Password"
        }
        
        let registerAction = UIAlertAction(title: "Register", style: .default, handler: {
            alert -> Void in
            
            let emailField = alertController.textFields![0] as UITextField
            let passwordField = alertController.textFields![1] as UITextField
            let confirmPasswordField = alertController.textFields![2] as UITextField
            
            print("email \(emailField.text), password \(passwordField.text), confirmed password \(confirmPasswordField.text)")
        })
        
        let loginAlertAction = UIAlertAction(title: "Log In", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.controller.present(self.loginAlertController, animated: true, completion: nil)
        })
        
        alertController.addAction(registerAction)
        alertController.addAction(loginAlertAction)
        return alertController
    }()
    
    
    init(forController controller: TableViewController) {
        self.controller = controller
    }
    
}
