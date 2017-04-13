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
    weak var task : Task? {
        didSet {
            drawButtonForCompletionStatus()
        }
    }
    var shapeLayer : CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drawButtonForCompletionStatus()
    }

    @IBAction func completedButtonAction(_ sender: Any) {
        guard let t = task else { return }
        t.userCompleted = t.userCompleted == nil ? USER_ID : nil  // Add your ID if you completed it
        print("userCompleted is \(t.userCompleted)")
        t.dateCompleted = t.userCompleted == nil ? Date() as NSDate? : nil // Add current date if completed
        print("dateCompleted on button press is \(t.dateCompleted)")
        drawButtonForCompletionStatus()
        
        // Update task's completed status in database
        let apiService = APIService(withController: nil)
        apiService.set(task: t)
    }
    
    func drawButtonForCompletionStatus() {
        // Color
        var strokeColor : UIColor = .lightGray
        var fillColor : UIColor = .clear
        if let t = task {
            if let userCreated = t.userCreated {
                strokeColor = userCreated == USER_ID ? USER_COLOR : GUEST_COLOR
            }
            if let userCompleted = t.userCompleted {
                fillColor = userCompleted == USER_ID ? USER_COLOR : GUEST_COLOR
            }
        }
        
        // Shape
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: completedButton.frame.width/2,y: completedButton.frame.height/2),
                                      radius: CGFloat(completedButton.frame.width/4),
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(M_PI * 2),
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
