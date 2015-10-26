//
//  AccelerometerController.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import CoreMotion
import CoreGraphics
class AccelerometerController: PlayerController {
    
    let ay = Vector3(x: 0.63, y: 0.0, z: -0.92)
    let az = Vector3(x: 0.0, y: 1.0, z: 0.0)
    let ax = Vector3.crossProduct(Vector3(x: 0.0, y: 1.0, z: 0.0), right: Vector3(x: 0.63, y: 0.0, z: -0.92)).normalized()
    
    let steerDeadZone: CGFloat = 0.1
    let motionManager: CMMotionManager;
    var delegate: PlayerControllerDelegate?
    
//    let blend: CGFloat = 0.2
//    var lastVector = CGPointMake(0, 0)
    
    init() {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.05
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: handler)
    }
    
    func handler(accelerometerData: CMAccelerometerData?,error: NSError?){
        if let data = accelerometerData{
            var accel2D = CGPointZero
            let raw = Vector3(x: CGFloat(data.acceleration.x), y: CGFloat(data.acceleration.y), z: CGFloat(data.acceleration.z))
            accel2D.x = Vector3.dotProduct(raw, right: az)
            accel2D.y = Vector3.dotProduct(raw, right: ax)
            if abs(accel2D.x) < steerDeadZone {
                accel2D.x = 0
            }
            if abs(accel2D.y) < steerDeadZone {
                accel2D.y = 0
            }
            accel2D.normalize()
            delegate?.moveByDirection(accel2D)
        }
    }
    
//    func lowPassWithVector(var vector: CGPoint) -> CGPoint{
//        vector.x = vector.x * blend + lastVector.x * (1.0 - blend)
//        vector.y = vector.y * blend + lastVector.y * (1.0 - blend)
//        lastVector = vector
//        return vector
//    }
    
    deinit{
        motionManager.stopAccelerometerUpdates()
    }
}