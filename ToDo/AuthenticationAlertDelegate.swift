//
//  LoginAlertDelegate.swift
//  ToDo
//
//  Created by TerryTorres on 4/15/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class AuthenticationAlertDelegate {
    
    var controller : AuthenticationDelegate!
    
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
            
            guard let email = alertController.textFields?[0].text else { return }
            guard let password = alertController.textFields?[1].text else { return }
            
            let authenticator = AuthenticationService(withController: self.controller)
            authenticator.login(email: email, password: password)
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
            self.controller.presentLoginAlert()
        })
        
        alertController.addAction(registerAction)
        alertController.addAction(loginAlertAction)
        return alertController
    }()
    
    
    init(forController controller: AuthenticationDelegate) {
        self.controller = controller
        // Check for previous login information
        guard let _ = UserDefaults.standard.object(forKey: UserKeys.login.rawValue) else {
            controller.presentLoginAlert()
            return
        }
    }
    

    
}
