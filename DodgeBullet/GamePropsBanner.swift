//
//  GamePropsBanner.swift
//  DodgeBullet
//
//  Created by user on 15/10/27.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class GamePropsBanner {
    
    static let scaleAnim = SKAction.sequence([SKAction.scaleTo(0.1, duration: 0.1), SKAction.scaleTo(1.2, duration: 0.1)])
    static let fadeout0_2Anim = SKAction.sequence([
        SKAction.fadeOutWithDuration(0.2),
        SKAction.removeFromParent()])
    
    weak var gameScene: GameScene!
    let area: CGRect
    let gridSize: CGFloat = 100
    
    var queue = [GameProps]()
    
    init(gameScene: GameScene){
        self.gameScene = gameScene
        area = CGRectMake(CGRectGetMaxX(gameScene.playableArea)-gridSize*11/2, CGRectGetMaxY(gameScene.playableArea)-120, gridSize*5, 100)
    }
    
    func add(gameProps: GameProps){
        var pos: CGPoint!
        if let lastItem = queue.last{
            pos = CGPointMake(lastItem.position.x-gridSize, lastItem.position.y)
        }
        else{
            pos = CGPointMake(CGRectGetMaxX(area)-gridSize/2, CGRectGetMaxY(area)-gameProps.size.height/1.5)
        }
        queue.append(gameProps)
        gameProps.runAction(SKAction.group([
            GamePropsBanner.scaleAnim,
            SKAction.moveTo(pos, duration: 0.2)])){
                if let index = self.queue.indexOf(gameProps){
                    gameProps.position = CGPointMake(CGRectGetMaxX(self.area)-self.gridSize*(2*CGFloat(index)+1)/2, gameProps.position.y)
                }
        }
    }
    
    func remove(gameProps: GameProps){
        if let removeIndex = queue.indexOf(gameProps){
            let y = gameProps.position.y
            queue.removeAtIndex(removeIndex)
            gameProps.removeActionForKey(GameProps.TimerActionKey)
            gameProps.runAction(GamePropsBanner.fadeout0_2Anim){
                for index in 0 ..< self.queue.count{
                    let props = self.queue[index]
                    props.position = CGPointMake(CGRectGetMaxX(self.area)-self.gridSize*(2*CGFloat(index)+1)/2, y)
                }
            }
        }
    }
}