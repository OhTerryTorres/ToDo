//
//  LoginButtonHandler.swift
//  ToDo
//
//  Created by TerryTorres on 7/11/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

typealias LoginButtonHandler = LoginButtonConfigurable & LoginAlertPresenter

protocol LoginButtonConfigurable {
    var controller : TaskTableViewController { get }
    var dataManager : TaskDataManager { get }
    
    func setUpLoginButton(forUser username: String?)
    
}

extension LoginButtonConfigurable where Self: LoginButtonHandler {
    func setUpLoginButton(forUser username: String? = "To Do") {
        let loginButton = UIButton(type: .custom)
        loginButton.setTitleColor(GUEST_COLOR, for: .normal)
        loginButton.setTitleColor(.clear, for: .highlighted)
        loginButton.showsTouchWhenHighlighted = true
        loginButton.frame = controller.navigationItem.titleView?.frame ?? CGRect(x: 0, y: 0, width: 100, height: 40)
        loginButton.addTarget(self, action: #selector(showLoginAlert), for: .touchUpInside)
        loginButton.setTitle(username, for: .normal)
        controller.navigationItem.titleView = loginButton
    }
    
}

@objc protocol LoginAlertPresenter {
    func showLoginAlert()
}
