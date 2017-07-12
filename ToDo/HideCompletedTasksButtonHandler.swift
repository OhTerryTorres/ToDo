//
//  HideCompletedTasksButtonHandler.swift
//  ToDo
//
//  Created by TerryTorres on 7/11/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

typealias HideCompletedTasksButtonHandler = HideCompletedTasksButtonConfigurable & CompletedTaskHider

protocol HideCompletedTasksButtonConfigurable {
    var controller : TaskTableViewController { get }
    var dataManager : TaskDataManager { get }
    var completedTasksHidden : Bool { get set }
    
    func hideCompletedCustomView(image: UIImage) -> UIImageView
    
}

extension HideCompletedTasksButtonConfigurable where Self: HideCompletedTasksButtonHandler {
    
    var hideCompletedBarButton : UIBarButtonItem {
        let button = UIBarButtonItem(customView: hideCompletedCustomView(image: #imageLiteral(resourceName: "completionTrue")))
        return button
    }
    func hideCompletedCustomView(image: UIImage) -> UIImageView {
        let view = UIImageView(image: image)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideCompletedTasks))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        return view
    }
}

@objc protocol CompletedTaskHider {
    func hideCompletedTasks()
}
