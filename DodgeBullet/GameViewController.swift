//
//  GameViewController.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright (c) 2015年 赵涛. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate {
    
    static var firstLaunch = true
    
    var adBanner: ADBannerView!
    static var ADHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view.
        let skView = self.view as! GameView
//        skView.showsFPS = true
//        skView.showsNodeCount = true
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        
        // 增加广告
        adBanner = ADBannerView(adType: .Banner)
        adBanner.delegate = self
        adBanner.alpha = 0.0
        adBanner.frame.origin = CGPointMake(0.0, view.frame.size.height-adBanner.frame.size.height)
        GameViewController.ADHeight = adBanner.frame.size.height
        view.addSubview(adBanner)
    }
    
    /*    接收通知    */
    func controllerChanged(){
        let gameView = view as! GameView
        if let scene = gameView.scene as? GameScene{
            gameView.setupController(scene)
        }
    }
    
    func willResignActive(){
        if !GameViewController.firstLaunch{
            let skView = self.view as! SKView
            if let scene = skView.scene as? GameScene{
                scene.pauseGame()
            }
        }
    }
    
    func orientationChanged(){
        if let accelerometerController = (view as? GameView)?.controller as? AccelerometerController{
            accelerometerController.setupCoordinate()
        }
    }
    
    /*   广告事件  */
    func layoutAdBanner(){
        let skView = self.view as! SKView
        if let scene = skView.scene as? GameScene{
            if scene.isGameOver && adBanner.bannerLoaded{
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.adBanner.alpha = 1.0
                    }, completion: { (finished) -> Void in
                        if !scene.isGameOver{
                            self.adBanner.alpha = 0.0
                        }
                })
            }
        }
    }
    
    func hideAdBanner(){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.adBanner.alpha = 0.0
        })
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        layoutAdBanner()
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        hideAdBanner()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
