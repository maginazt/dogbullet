//
//  GameView.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/18.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class GameView: SKView {
    //游戏控制
    var controller: PlayerController?
    
    func setupController(scene: GameScene){
        releaseController()
        scene.onScreenControlEnabled = false
        switch UserDocuments.controllerStatus{
            case .OnScreen:
                scene.onScreenControlEnabled = true
            case .Joystick:
                createAnalogController(scene, isLeft: false)
            case .Accelerometer:
                createAccelerometerController(scene)
        }
    }
    
    func createAccelerometerController(scene: GameScene){
        controller = AccelerometerController()
        controller!.delegate = scene
    }
    
    func createAnalogController(scene: GameScene, isLeft left: Bool){
        var padSide: CGFloat!
        var padPadding: CGFloat!
        // width: height = 16 : 9 iphone5
        if frame.size.height / frame.size.width < 0.65{
            padSide = frame.size.height / 3
            padPadding = frame.size.height / 35
        }
        // width: height = 4 : 3 ipad
        else{
            padSide = frame.size.width / 9
            padPadding = frame.size.width / 65
        }
        
        var analogController: AnalogController!
        if left{
            analogController = AnalogController(frame: CGRectMake(padPadding, frame.size.height - padPadding - padSide, padSide, padSide))
        }
        else{
            analogController = AnalogController(frame: CGRectMake(frame.size.width - padPadding - padSide, frame.size.height - padPadding - padSide, padSide, padSide))
        }
        analogController.padSide = padSide
        analogController.padPadding = padPadding
        addSubview(analogController)
        controller = analogController
        controller!.delegate = scene
    }
    
    func createGestureRecognizer(scene: GameScene){
        removeGestureRecognizers()
        //更换控制中心手势
        let dbtap = UITapGestureRecognizer(target: scene, action: "handleDoubleTapGesture:")
        dbtap.numberOfTapsRequired = 2
        addGestureRecognizer(dbtap)
    }
    
    func removeGestureRecognizers(){
        if let grs = gestureRecognizers{
            for gr in grs{
                removeGestureRecognizer(gr)
            }
        }
    }
    
    func releaseController(){
        if let analogController = controller as? AnalogController{
            analogController .removeFromSuperview()
        }
        if let accelerometerController = controller as? AccelerometerController{
            accelerometerController.motionManager.stopAccelerometerUpdates()
        }
        controller?.delegate = nil
        controller = nil
    }
    
    deinit{
        removeGestureRecognizers()
        releaseController()
    }
}