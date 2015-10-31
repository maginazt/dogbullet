//
//  GamePropsGenerator.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/25.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class GamePropsGenerator : GamePropsDelegate {
    
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
        let gameProps = GameProps(gamePropsType: GamePropsType(rawValue: random() % GamePropsType.Maximum.rawValue)!)
        gameProps.position = randomPointInRect(CGRectInset(gameScene.playableArea, gameScene.gamePropsBanner.gridSize/2, gameScene.gamePropsBanner.gridSize*2))
        gameScene.gamePropsLayer.addChild(gameProps)
    }
    
    // 添加游戏道具效果
    func handleGamePropsEffect(gameProps: GameProps){
        if gameScene.gamePropsMap.keys.contains(gameProps.type){
            let oldGameProps = gameScene.gamePropsMap[gameProps.type]!
            oldGameProps.resetEffectTimer()
            gameProps.removeFromParent()
        }
        else{
            gameScene.gamePropsMap[gameProps.type] = gameProps
            gameProps.initializeEffect(self)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.gameScene.gamePropsBanner.add(gameProps)
            })
            switch gameProps.type{
            case .SpeedUp:
                addSpeedUpEffect()
            case .ScaleDown:
                addScaleDownEffect()
            case .Phantom:
                addPhantomEffect()
            default:
                break
            }
        }
    }
    
    private func addSpeedUpEffect(){
        gameScene.moveSpeed = GameSpeed.PlayerMaxSpeed.rawValue
    }
    
    private func addScaleDownEffect(){
        gameScene.player.xScale = 0.5
        gameScene.player.yScale = 0.5
    }
    
    private func addPhantomEffect(){
        let phantom = Player()
        phantom.mainSprite.color = SKColor.redColor()
        phantom.mainSprite.colorBlendFactor = 0.9
        phantom.mainSprite.alpha = 0.7
        phantom.physicsBody = nil
        phantom.position = gameScene.player.position
        gameScene.playerPhantom = phantom
        gameScene.addChild(phantom)
        
        //从游戏区域的四条边的中点逆时针运动
        let side = gameScene.gamePropsBanner.gridSize
        //上、左、下、右
        let movePoints = [
            randomPointInRect(CGRectMake(CGRectGetMinX(gameScene.playableArea)+CGRectGetWidth(gameScene.playableArea)/2-side/2, CGRectGetMaxY(gameScene.playableArea)-side*2, side, side)),
            randomPointInRect(CGRectMake(CGRectGetMinX(gameScene.playableArea)+side, CGRectGetMinY(gameScene.playableArea)+CGRectGetHeight(gameScene.playableArea)/2-side/2, side, side)),
            randomPointInRect(CGRectMake(CGRectGetMinX(gameScene.playableArea)+CGRectGetWidth(gameScene.playableArea)/2-side/2, CGRectGetMinY(gameScene.playableArea)+side, side, side)),
            randomPointInRect(CGRectMake(CGRectGetMaxX(gameScene.playableArea)-side*2, CGRectGetMinY(gameScene.playableArea)+CGRectGetHeight(gameScene.playableArea)/2-side/2, side, side))
        ]
        //选择离当前位置最远的点
        var remoteIndex = 0
        var maxDistance: CGFloat = 0
        for point in movePoints{
            let dis = (point-phantom.position).length()
            if dis > maxDistance{
                remoteIndex = movePoints.indexOf(point)!
                maxDistance = dis
            }
        }
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, movePoints[remoteIndex].x, movePoints[remoteIndex].y)
        for var nextIndex = (remoteIndex+1) % movePoints.count; nextIndex != remoteIndex; nextIndex = (nextIndex+1) % movePoints.count{
            CGPathAddLineToPoint(path, nil, movePoints[nextIndex].x, movePoints[nextIndex].y)
        }
        phantom.runAction(SKAction.sequence([
            SKAction.runBlock({ () -> Void in
                phantom.moveToward(movePoints[remoteIndex])
            }),
            SKAction.moveTo(movePoints[remoteIndex], duration: NSTimeInterval(maxDistance/self.gameScene.moveSpeed)),
            SKAction.repeatActionForever(SKAction.followPath(path, asOffset: false, orientToPath: true, speed: gameScene.moveSpeed))]))
    }
    
    // 消除游戏道具效果
    func disableEffect(type: GamePropsType) {
        if let gameProps = gameScene.gamePropsMap.removeValueForKey(type){
            gameScene.gamePropsBanner.remove(gameProps)
            switch gameProps.type{
            case .SpeedUp:
                removeSpeedUpEffect()
            case .ScaleDown:
                removeScaleDownEffect()
            case .Phantom:
                removePhantomEffect()
            default:
                break
            }
        }
    }
    
    private func removeSpeedUpEffect(){
        gameScene.moveSpeed = GameSpeed.PlayerDefaultSpeed.rawValue
    }
    
    private func removeScaleDownEffect(){
        gameScene.player.xScale = 1
        gameScene.player.yScale = 1
    }
    
    private func removePhantomEffect(){
        gameScene.playerPhantom?.removeFromParent()
        gameScene.playerPhantom = nil
    }
    
}