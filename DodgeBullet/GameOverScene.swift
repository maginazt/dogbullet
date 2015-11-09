//
//  GameOverScene.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/14.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class GameOverScene: SKScene {
    
    var won = false
    
    override func didMoveToView(view: SKView) {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.fontColor = SKColor.blueColor()
        label.fontSize = 90
        label.position = CGPointMake(size.width/2, size.height/2)
        if won{
            label.text = "You Win!"
        }
        else{
            label.text = "Game Over!"
        }
        addChild(label)
        
        let restart = SKLabelNode(fontNamed: "Chalkduster")
        restart.name = "restart"
        restart.fontColor = SKColor.blueColor()
        restart.fontSize = 70
        restart.position = CGPointMake(size.width/2, label.position.y-150)
        restart.text = "Restart"
        addChild(restart)
        
        let mainMenu = SKLabelNode(fontNamed: "Chalkduster")
        mainMenu.name = "mainmenu"
        mainMenu.fontColor = SKColor.orangeColor()
        mainMenu.fontSize = 70
        mainMenu.position = CGPointMake(size.width/2, restart.position.y-150)
        mainMenu.text = "Main Menu"
        addChild(mainMenu)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first{
            let loc = touch.locationInNode(self)
            let restart = childNodeWithName("restart")
            if restart!.containsPoint(loc){
                let scene = GameScene(size: size)
                scene.scaleMode = scaleMode
                let gameView = view as! GameView
                gameView.createGestureRecognizer(scene)
                gameView.setupController(scene)
                gameView.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.3))
            }
            let mainMenu = childNodeWithName("mainmenu")
            if mainMenu!.containsPoint(loc){
                (view?.window?.rootViewController as! UINavigationController).popToRootViewControllerAnimated(true)
            }
        }
    }
}