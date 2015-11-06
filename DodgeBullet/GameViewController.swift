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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view.
        let skView = self.view as! GameView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        let scene = GameScene(size: CGSizeMake(2048, 1536))
        scene.scaleMode = .AspectFill
//        setupEnvironments(scene)
        skView.createGestureRecognizer(scene)
        skView.setupController(scene)
        
        skView.presentScene(scene)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerChanged", name: UserDocuments.ControllerStatusChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
//    func setupEnvironments(scene: GameScene){
//        scene.forceTouchAvailable = traitCollection.forceTouchCapability == UIForceTouchCapability.Available
//    }
//    
//    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        let skView = self.view as! SKView
//        (skView.scene as? GameScene)?.forceTouchAvailable = traitCollection.forceTouchCapability == UIForceTouchCapability.Available
//    }
    
    @IBAction func pauseButtonPressed(sender: UIButton) {
        if UserDocuments.soundStatus{
            SKTAudio.sharedInstance().playSoundEffect("button_press.wav")
        }
        let skView = self.view as! SKView
        if let scene = skView.scene as? GameScene{
            pauseScene(scene)
        }
    }
    
    func pauseScene(scene: GameScene){
        scene.paused = true
        scene.inGameMenu.hidden = false
        scene.lastTimeStamp = 0.0
        scene.player.physicsBody?.velocity = CGVectorMake(0, 0)
        if let accelerometerController = (view as? GameView)?.controller as? AccelerometerController{
            accelerometerController.motionManager.stopAccelerometerUpdates()
        }
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
            pauseScene(scene)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
