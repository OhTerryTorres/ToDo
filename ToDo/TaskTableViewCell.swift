//
//  TaskTableViewCell.swift
//  ToDo
//
//  Created by TerryTorres on 4/4/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var completedButton: UIButton!
    @IBOutlet var textField: UITextField!
    var task : Task? {
        didSet {
            drawButtonForCompletionStatus()
        }
    }
    var shapeLayer : CAShapeLayer?
    
    func configure(task: Task?, tag: Int, delegate: TaskTextFieldDelegate) {
        textField.delegate = delegate
        textField.tag = tag
        if let t = task {
            self.task = t
            textField.text = t.name
        } else {
            self.task = nil
            textField.text = nil // zero out reused cells
        }
    }

    @IBAction func completedButtonAction(_ sender: Any) {
        guard let task = self.task else { return }

        task.userCompleted = task.userCompleted == nil ? USER_ID : nil  // Add your ID if you completed it
        task.dateCompleted = task.userCompleted == nil ? nil : Date() // Add current date if completed
        drawButtonForCompletionStatus()
        
        // Update task's completed status in database
        let apiService = APIService()
        apiService.set(task: task)
    }
    
    func drawButtonForCompletionStatus() {
        // Set default colors for a blank task
        var strokeColor : UIColor = .lightGray
        var fillColor : UIColor = .clear
        
        // Change colors based on task completion status
        if let task = self.task {
            strokeColor = task.userCreated == USER_ID ? USER_COLOR : GUEST_COLOR
            if let userCompleted = task.userCompleted {
                fillColor = userCompleted == USER_ID ? USER_COLOR : GUEST_COLOR
            }
        }
        
        // Shape with colors
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: completedButton.frame.width/2,y: completedButton.frame.height/2),
                                      radius: CGFloat(completedButton.frame.width/4),
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = 2.0
        
        // Replace old shape layer
        if let sl = self.shapeLayer { sl.removeFromSuperlayer() }
        self.shapeLayer = shapeLayer
        completedButton.layer.addSublayer(self.shapeLayer!)
    }
    
    
}
