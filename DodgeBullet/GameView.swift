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
    //拖动手势
    var onScreenMoveGesture: UIPanGestureRecognizer?
    
    func setupController(scene: GameScene){
        releaseController()
        removeGestureRecognizers()
        switch UserDocuments.controllerStatus{
            case .OnScreen:
                createOnScreenControl(scene)
            case .Accelerometer:
                createAccelerometerController(scene)
        }
    }
    
    func createAccelerometerController(scene: GameScene){
        controller = AccelerometerController()
        controller!.delegate = scene
        (controller as! AccelerometerController).start()
    }
    
    func createOnScreenControl(scene: GameScene){
        let pan = UIPanGestureRecognizer(target: scene, action: "handlePanGesture:")
        onScreenMoveGesture = pan
        addGestureRecognizer(pan)
    }
    
    func removeGestureRecognizers(){
        if let gr = onScreenMoveGesture{
            removeGestureRecognizer(gr)
        }
    }
    
    func releaseController(){
        if let accelerometerController = controller as? AccelerometerController{
            accelerometerController.stop()
        }
        controller?.delegate = nil
        controller = nil
    }
    
    func changeControllerTarget(scene: GameScene){
        controller?.delegate = scene
        if let gr = onScreenMoveGesture{
            gr.removeTarget(nil, action: nil)
            gr.addTarget(scene, action: "handlePanGesture:")
        }
    }
    
    deinit{
        removeGestureRecognizers()
        releaseController()
    }
}