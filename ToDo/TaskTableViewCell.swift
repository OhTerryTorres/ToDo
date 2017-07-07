//
//  TaskTableViewCell.swift
//  ToDo
//
//  Created by TerryTorres on 4/4/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit

struct TaskTableViewCellStyle {
    
    var strokeColor : CGColor = UIColor.lightGray.cgColor
    var fillColor : CGColor = UIColor.clear.cgColor
    var textColor : UIColor = .black
    
    init(task: Task? = nil) {
        guard let task = task else { return }
        // If task exists, give the stroke an appropriate color
        strokeColor = task.userCreated == USER_ID ? USER_COLOR.cgColor : GUEST_COLOR.cgColor
        if let username = task.userCompleted {
            // If task is completed, gray out text and assign appropriate fill color
            textColor = .lightGray
            fillColor = username == USER_ID ? USER_COLOR.cgColor : GUEST_COLOR.cgColor
        }
    }
}

class TaskTableViewCell: UITableViewCell {

    @IBOutlet var completedButton: UIButton!
    @IBOutlet var textField: UITextField!
    var shapeLayer : CAShapeLayer? // Used to draw on top of the completedButton
    
    func configure(task: Task? = nil, tag: Int, delegate: UITextFieldDelegate) {
        let style = TaskTableViewCellStyle(task: task)
        updateAppearanceWithStyle(style)
        updateTextField(task: task, tag: tag, delegate: delegate)
        self.tag = tag
    }

    
    // Notification is used to alert the Data Source
    @IBAction func completedButtonAction(_ sender: Any) {
        let dict : [String : Any] = ["tag" : self.tag, "completion": updateAppearanceWithStyle]
        NotificationCenter.default.post(name: Notification.Name("toggleTaskCompletion"), object: nil, userInfo: dict)
    }
    
    func updateAppearanceWithStyle(_ style: TaskTableViewCellStyle) {
        textField.textColor = style.textColor
        
        // Replace old shape layer
        updateShapeLayer(style: style)
    }
    
    private func updateTextField(task: Task? = nil, tag: Int, delegate: UITextFieldDelegate) {
        textField.delegate = delegate
        textField.tag = tag
        textField.text = nil
        print(tag)
        guard let task = task else { return }
        textField.text = task.name
        print(task.name)
    }
    
    private func updateShapeLayer(style: TaskTableViewCellStyle) {
        if let sl = self.shapeLayer { sl.removeFromSuperlayer() }
        self.shapeLayer = CAShapeLayer(withTaskTableViewCellStyle: style, frame: completedButton.frame)
        completedButton.layer.addSublayer(self.shapeLayer!)
        self.sendSubview(toBack: completedButton)
    }
    
}

extension CAShapeLayer {
    
    convenience init(withTaskTableViewCellStyle style: TaskTableViewCellStyle, frame: CGRect) {
        self.init()
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.width/2,y: frame.height/2),
                                      radius: CGFloat(frame.width/4),
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        self.path = circlePath.cgPath
        self.fillColor = style.fillColor
        self.strokeColor = style.strokeColor
        self.lineWidth = 2.0
    }
}
