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
    let maxNormalEnemyCount = 35
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
            SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 3, max: 5))),
            SKAction.runBlock({ () -> Void in
                self.spawnSlowEnemy()
            })])))
        //快速敌人生成策略：随机生成
        gameScene.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 2, max: 5))),
            SKAction.runBlock({ () -> Void in
                self.spawnFastEnemy()
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
        let targetPos = randomPointInRect(gameScene.player.fireRect)
        let enemy = EnemyNormal(textureName: "enemy-1")
        normalEnemies.append(enemy)
        gameScene.enemyLayer.addChild(enemy)
        enemy.position = position
        enemy.moveToward((targetPos-position).normalized()*CGFloat(GameSpeed.EnemyNormalSpeed.rawValue))
        enemy.faceCurrentDirection()
    }
    
    func spawnSlowEnemy(){
        if slowEnemies.count < maxSlowEnemyCount{
            let spawnPoint = randomPointInRect(gameScene.playableArea)
            let enemy = EnemySlow(textureName: "enemy-1")
            slowEnemies.append(enemy)
            gameScene.enemyLayer.addChild(enemy)
            enemy.position = spawnPoint
            enemy.runAction(SKAction.sequence([
                SKAction.waitForDuration(10),
                SKAction.runBlock({ () -> Void in
                    enemy.removeFromParent()
                    self.slowEnemies.removeAtIndex(self.slowEnemies.indexOf(enemy)!)
                })]))
        }
    }
    
    func spawnFastEnemy(){
        if CGFloat.random() < 0.05{
            var spawnPoint: CGPoint!
            switch random() % 4{
            case 0:
                spawnPoint = randomPointInRect(upRect)
            case 1:
                spawnPoint = randomPointInRect(rightRect)
            case 2:
                spawnPoint = randomPointInRect(downRect)
            default:
                spawnPoint = randomPointInRect(leftRect)
            }
            let enemy = EnemyFast(textureName: "enemy-1")
            gameScene.enemyLayer.addChild(enemy)
            enemy.position = spawnPoint
            enemy.moveToward((gameScene.player.position-spawnPoint).normalized()*CGFloat(GameSpeed.EnemyFastSpeed.rawValue))
            enemy.faceCurrentDirection()
        }
    }
}