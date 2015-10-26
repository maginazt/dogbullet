//
//  AnalogController.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import UIKit
class AnalogController: UIView, PlayerController{
    let baseCenter: CGPoint
    var relPosition: CGPoint!
    var delegate: PlayerControllerDelegate?
    let knobImageView: UIImageView
    
    override init(frame: CGRect) {
        baseCenter = CGPointMake(frame.size.width/2, frame.size.height/2)
        knobImageView = UIImageView(image: UIImage(named: "knob"))
        knobImageView.frame.size.width /= 2
        knobImageView.frame.size.height /= 2
        knobImageView.center = baseCenter
        super.init(frame: frame)
        
        userInteractionEnabled = true
        let baseImageView = UIImageView(frame: bounds)
        baseImageView.image = UIImage(named: "base")
        addSubview(knobImageView)
        addSubview(baseImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateKnobWithPosition(position: CGPoint) {
        var positionToCenter = position - baseCenter
        var direction: CGPoint
        if positionToCenter == CGPointZero {
            direction = CGPointZero
        } else {
            direction = positionToCenter.normalized()
        }
        
        let radius = frame.size.width/2
        var length = positionToCenter.length()
        if length > radius {
            length = radius
            positionToCenter = direction * radius
        }
        
//        relPosition = CGPoint(x: direction.x * (length/radius), y: direction.y * (length/radius))
        knobImageView.center = baseCenter + positionToCenter
        delegate?.moveByDirection(CGPointMake(direction.x, -direction.y))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateKnobWithPosition(touches.first!.locationInView(self))
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateKnobWithPosition(baseCenter)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        updateKnobWithPosition(baseCenter)
    }
}