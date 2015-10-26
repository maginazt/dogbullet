//
//  GamePropsGenerator.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/25.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class GamePropsGenerator {
    
    unowned let gameScene: GameScene
    
    init(gameScene: GameScene){
        self.gameScene = gameScene
        //道具生成策略：随机生成
        gameScene.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 5, max: 10))),
            SKAction.runBlock({ () -> Void in
                self.spawnGameProps()
            })])))
    }
    
    func spawnGameProps(){
        let gameProps = GameProps(gamePropsType: GamePropsType.SpeedUp)
        gameProps.position = randomPointInRect(gameScene.playableArea)
        gameScene.gamePropsLayer.addChild(gameProps)
        
    }
}