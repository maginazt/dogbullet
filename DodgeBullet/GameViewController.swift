//
//  GameViewController.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright (c) 2015年 赵涛. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    static var firstLaunch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view.
        let skView = self.view as! GameView
        skView.showsFPS = true
        skView.showsNodeCount = true
//        skView.showsPhysics = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        let scene = GameScene(size: CGSizeMake(2048, 1536))
        scene.scaleMode = .AspectFill
        
        skView.setupController(scene)
        
        skView.presentScene(scene)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerChanged", name: UserDocuments.ControllerStatusChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    /*    接收通知    */
    func controllerChanged(){
        let gameView = view as! GameView
        if let scene = gameView.scene as? GameScene{
            gameView.setupController(scene)
        }
    }
    
    func willResignActive(){
        let skView = self.view as! SKView
        if let scene = skView.scene as? GameScene{
            scene.pauseGame()
        }
    }
    
    func orientationChanged(){
        if let accelerometerController = (view as? GameView)?.controller as? AccelerometerController{
            accelerometerController.setupCoordinate()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
