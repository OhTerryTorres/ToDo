//
//  EditingButtonHandler.swift
//  ToDo
//
//  Created by TerryTorres on 7/11/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

typealias EditingButtonHandler = EditingButtonConfigurable & EditSetter

protocol EditingButtonConfigurable {
    var controller : TaskTableViewController { get }
}

extension EditingButtonConfigurable where Self : EditingButtonHandler {
    var editBarButton : UIBarButtonItem {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "editFalse"), style: .plain, target: self, action: #selector(setEditing))
        return button
    }
}

@objc protocol EditSetter {
    func setEditing()
}
