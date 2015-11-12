//
//  BulletGenerator.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/12.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class EnemyGenerator {
    
    static let enemyDistance: CGFloat = 200
    let maxNormalEnemyCount = 40
    let maxSlowEnemyCount = 5
    
    unowned let gameScene: GameScene
    let upRect: CGRect
    let rightRect: CGRect
    let downRect: CGRect
    let leftRect: CGRect
    
    var normalEnemies = [EnemyNormal]()
    var slowEnemies = [EnemySlow]()
    
    init(gameScene: GameScene){
        self.gameScene = gameScene
        upRect = CGRectMake(CGRectGetMinX(gameScene.playableArea), CGRectGetMaxY(gameScene.playableArea), gameScene.playableArea.width, EnemyGenerator.enemyDistance)
        rightRect = CGRectMake(CGRectGetMaxX(gameScene.playableArea), CGRectGetMinY(gameScene.playableArea), EnemyGenerator.enemyDistance, gameScene.playableArea.height)
        downRect = CGRectMake(CGRectGetMinX(gameScene.playableArea), CGRectGetMinY(gameScene.playableArea)-EnemyGenerator.enemyDistance, gameScene.playableArea.width, EnemyGenerator.enemyDistance)
        leftRect = CGRectMake(CGRectGetMinX(gameScene.playableArea)-EnemyGenerator.enemyDistance, CGRectGetMinY(gameScene.playableArea), EnemyGenerator.enemyDistance, gameScene.playableArea.height)
        //正常敌人生成策略：线性增量生成，每隔n秒随机在各个区域生成一个敌人
        gameScene .runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.runBlock({ () -> Void in
                for _ in 0 ..< 4{
                    self.spawnNormalEnemy()
                }
            }),
            SKAction.waitForDuration(5)])))
        //慢速敌人生成策略：随机增量生成
        gameScene.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 5, max: 10))),
            SKAction.runBlock({ () -> Void in
                self.spawnSlowEnemy()
            })])))
        //快速敌人生成策略：随机生成
        gameScene.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 2, max: 5))),
            SKAction.runBlock({ () -> Void in
                if !self.gameScene.stopTimeEnabled{
                    self.spawnFastEnemy()
                }
            })])))
    }
    
    func spawnNormalEnemy(){
        if normalEnemies.count < maxNormalEnemyCount{
            switch random() % 4{
                case 0:
                    createNormalEnemyAtPositon(randomPointInRect(upRect))
                case 1:
                    createNormalEnemyAtPositon(randomPointInRect(rightRect))
                case 2:
                    createNormalEnemyAtPositon(randomPointInRect(downRect))
                default:
                    createNormalEnemyAtPositon(randomPointInRect(leftRect))
            }
        }
    }
    
    private func createNormalEnemyAtPositon(position: CGPoint){
        var targetPos: CGPoint!
        if let phantom = gameScene.playerPhantom{
            targetPos = randomPointInRect(phantom.fireRect)
        }
        else{
            targetPos = randomPointInRect(gameScene.player.fireRect)
        }
        let enemy = EnemyNormal(textureName: "enemy-1")
        normalEnemies.append(enemy)
        gameScene.enemyLayer.addChild(enemy)
        enemy.position = position
        enemy.moveToward((targetPos-position).normalized()*enemy.moveSpeed)
        enemy.faceCurrentDirection()
        
        if gameScene.turnCatEnabled{
            enemy.turnCat()
        }
    }
    
    func spawnSlowEnemy(){
        if slowEnemies.count < maxSlowEnemyCount{
            let spawnPoint = randomPointInRect(CGRectInset(gameScene.playableArea, gameScene.gamePropsBanner.gridSize, gameScene.gamePropsBanner.gridSize))
            let spawnAnimation = AnimatingSprite.createAnimWithAtlasNamed("effects", prefix: "enemyShow", numOfPics: 8, timePerFrame: 0.1)
            let spawnNode = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(50, 50))
            spawnNode.position = spawnPoint
            gameScene.enemyLayer.addChild(spawnNode)
            spawnNode.runAction(SKAction.group([
                SKAction.sequence([
                    spawnAnimation,
                    SKAction.removeFromParent()
                    ]),
                SKAction.sequence([
                    SKAction.waitForDuration(0.4),
                    SKAction.runBlock({ () -> Void in
                        let enemy = EnemySlow(textureName: "enemy-1")
                        if self.gameScene.stopTimeEnabled{
                            enemy.paused = true
                        }
                        self.slowEnemies.append(enemy)
                        self.gameScene.enemyLayer.addChild(enemy)
                        enemy.setupGhostEffect()
                        enemy.position = spawnPoint
                        if self.gameScene.turnCatEnabled{
                            enemy.turnCat()
                        }
                        enemy.runAction(SKAction.sequence([
                            SKAction.waitForDuration(10),
                            SKAction.runBlock({ () -> Void in
                                enemy.removeFromParent()
                                self.slowEnemies.removeAtIndex(self.slowEnemies.indexOf(enemy)!)
                            })]))
                    })])
                ]))
        }
    }
    
    func spawnFastEnemy(){
        let probiblity = 1 / (1 + exp(-gameScene.timePassed/60)) - 0.5
        if CGFloat.random() < CGFloat(probiblity){
            switch CGFloat.random(){
            case 0 ..< 0.5:
                spawnFastEnemyInOneSide()
            case 0.5 ..< 0.8:
                spawnFastEnemyInTwoSide()
            case 0.8 ..< 0.9:
                spawnFastEnemyInThreeSide()
            default:
                spawnFastEnemyInAllSide()
            }
        }
    }
    
    func spawnFastEnemyInAllSide(){
        spawnFastEnemyAt(randomPointInRect(upRect))
        spawnFastEnemyAt(randomPointInRect(downRect))
        spawnFastEnemyAt(randomPointInRect(leftRect))
        spawnFastEnemyAt(randomPointInRect(rightRect))
    }
    
    func spawnFastEnemyInThreeSide(){
        switch random() % 4{
        case 0:
            spawnFastEnemyAt(randomPointInRect(downRect))
            spawnFastEnemyAt(randomPointInRect(leftRect))
            spawnFastEnemyAt(randomPointInRect(rightRect))
        case 1:
            spawnFastEnemyAt(randomPointInRect(upRect))
            spawnFastEnemyAt(randomPointInRect(downRect))
            spawnFastEnemyAt(randomPointInRect(rightRect))
        case 2:
            spawnFastEnemyAt(randomPointInRect(upRect))
            spawnFastEnemyAt(randomPointInRect(leftRect))
            spawnFastEnemyAt(randomPointInRect(rightRect))
        default:
            spawnFastEnemyAt(randomPointInRect(upRect))
            spawnFastEnemyAt(randomPointInRect(downRect))
            spawnFastEnemyAt(randomPointInRect(leftRect))
        }
    }
    
    func spawnFastEnemyInTwoSide(){
        switch random() % 2{
        case 0:
            spawnFastEnemyAt(randomPointInRect(upRect))
            spawnFastEnemyAt(randomPointInRect(downRect))
        default:
            spawnFastEnemyAt(randomPointInRect(leftRect))
            spawnFastEnemyAt(randomPointInRect(rightRect))
        }
    }
    
    func spawnFastEnemyInOneSide(){
        switch random() % 4{
        case 0:
            spawnFastEnemyAt(randomPointInRect(upRect))
        case 1:
            spawnFastEnemyAt(randomPointInRect(leftRect))
        case 2:
            spawnFastEnemyAt(randomPointInRect(downRect))
        default:
            spawnFastEnemyAt(randomPointInRect(rightRect))
        }
    }
    
    func spawnFastEnemyAt(position: CGPoint){
        let enemy = EnemyFast(textureName: "enemy-1")
        gameScene.enemyLayer.addChild(enemy)
        enemy.setupFireEffect()
        enemy.position = position
        if let phantom = gameScene.playerPhantom{
            enemy.moveToward((phantom.position-position).normalized()*enemy.moveSpeed)
        }
        else{
            enemy.moveToward((randomPointInRect(gameScene.player.fireRectNarrow)-position).normalized()*enemy.moveSpeed)
        }
        enemy.faceCurrentDirection()
        
        if gameScene.turnCatEnabled{
            enemy.turnCat()
        }
    }
}