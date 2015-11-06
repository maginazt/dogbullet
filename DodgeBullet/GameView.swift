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
        switch UserDocuments.controllerStatus{
            case .JoystickLeft:
                createAnalogController(scene, isLeft: true)
            case .JoystickRight:
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
        let padSide: CGFloat = frame.size.height / 3
        let padPadding: CGFloat = frame.size.height / 35
        var analogController: AnalogController!
        if left{
            analogController = AnalogController(frame: CGRectMake(padPadding, frame.size.height - padPadding - padSide, padSide, padSide))
        }
        else{
            analogController = AnalogController(frame: CGRectMake(frame.size.width - padPadding - padSide, frame.size.height - padPadding - padSide, padSide, padSide))
        }
        addSubview(analogController)
        controller = analogController
        controller!.delegate = scene
    }
    
    func createGestureRecognizer(scene: GameScene){
        removeGestureRecognizers()
        //躲避手势
        let swipe = UISwipeGestureRecognizer(target: scene, action: "handleSwipeGesture")
        swipe.direction = [.Left, .Right]
        swipe.numberOfTouchesRequired = 2
        addGestureRecognizer(swipe)
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