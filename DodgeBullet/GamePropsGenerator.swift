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
                if !gameScene.stopTimeEnabled{
                    self.spawnGameProps()
                }
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
            if gameProps.type == GamePropsType.Rock{
                gameProps.removeFromParent()
            }
            else{
                gameScene.gamePropsMap[gameProps.type] = gameProps
                gameProps.initializeEffect(self)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.gameScene.gamePropsBanner.add(gameProps)
                })
            }
            switch gameProps.type{
            case .SpeedUp:
                addSpeedUpEffect()
            case .ScaleDown:
                addScaleDownEffect()
            case .Phantom:
                addPhantomEffect()
            case .StopTime:
                addStopTimeEffect()
            case .TurnCats:
                addTurnCatsEffect()
            case .DogFood:
                addDogFoodEffect(gameProps.position)
            case .Rock:
                addRockEffect(gameProps.position)
            case .WhosYourDaddy:
                addWhosYourDaddyEffect()
            case .SlowDown:
                addSlowDownEffect()
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
        
        //从游戏区域的四条边的随机点进行运动
        let area = CGRectInset(gameScene.playableArea, gameScene.gamePropsBanner.gridSize, gameScene.gamePropsBanner.gridSize)
        let lastMove = randomPointOnSideOfRect(area, exclude: -1)
        phantom.moveToward(lastMove.1)
        phantom.runAction(SKAction.moveTo(lastMove.1, duration: NSTimeInterval((lastMove.1-self.gameScene.playerPhantom!.position).length()/self.gameScene.moveSpeed))){
            self.createNextMoveAction(area, lastMove: lastMove)
        }
    }
    
    private func createNextMoveAction(area: CGRect, var lastMove: (Int, CGPoint)){
        lastMove = randomPointOnSideOfRect(area, exclude: lastMove.0)
        gameScene.playerPhantom?.moveToward(lastMove.1)
        gameScene.playerPhantom?.runAction(SKAction.moveTo(lastMove.1, duration: NSTimeInterval((lastMove.1-gameScene.playerPhantom!.position).length()/gameScene.moveSpeed))){
            self.createNextMoveAction(area, lastMove: lastMove)
        }
    }
    
    private func addStopTimeEffect(){
        gameScene.stopTimeEnabled = true
        for enemy in gameScene.enemyGenerator.slowEnemies{
            enemy.paused = true
            enemy.physicsBody?.velocity = CGVectorMake(0, 0)
        }
        for enemy in gameScene.enemyGenerator.normalEnemies{
            enemy.paused = true
            enemy.physicsBody?.velocity = CGVectorMake(0, 0)
        }
        if let fastEnemy = gameScene.enemyLayer.childNodeWithName("fastEnemy"){
            fastEnemy.paused = true
            fastEnemy.physicsBody?.velocity = CGVectorMake(0, 0)
        }
    }
    
    private func addTurnCatsEffect(){
        for enemyNode in gameScene.enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                enemy.sprite.color = SKColor.yellowColor()
                enemy.sprite.colorBlendFactor = 0.9
                enemy.physicsBody?.categoryBitMask = PhysicsCategory.Cat.rawValue
                enemy.physicsBody?.velocity = enemy.physicsBody!.velocity.normalized()*CGFloat(GameSpeed.CatSpeed.rawValue)
            }
        }
    }
    
    private func addDogFoodEffect(position: CGPoint){
        gameScene.dogFoodArea = CGRectMake(position.x-50, position.y-25, 100, 50)
    }
    
    private func addRockEffect(position: CGPoint){
        for _ in 0 ..< 20{
            spawnRock(position)
        }
    }
    
    private func addWhosYourDaddyEffect(){
        gameScene.whosYourDaddyEnabled = true
    }
    
    let slowDownRadius: CGFloat = 200
    
    private func addSlowDownEffect(){
        gameScene.slowDownEnabled = true
        let circle = SKShapeNode(circleOfRadius: slowDownRadius)
        circle.name = "circle"
        circle.strokeColor = SKColor.purpleColor()
        circle.lineWidth = 1.5
        gameScene.player.addChild(circle)
    }
    
    private func spawnRock(position: CGPoint){
        let rock = SKLabelNode(fontNamed: "Arial")
        rock.verticalAlignmentMode = .Center
        rock.fontColor = SKColor.greenColor()
        rock.fontSize = 60
        rock.text = "•"
        rock.position = position
        gameScene.addChild(rock)
        rock.physicsBody = SKPhysicsBody(circleOfRadius: 6)
        rock.physicsBody?.usesPreciseCollisionDetection = true
        rock.physicsBody?.linearDamping = 0
        rock.physicsBody?.velocity = CGVector(point: angleToDirection(CGFloat.random(min: 0, max: CGFloat(M_PI*2.0)))*CGFloat(GameSpeed.RockSpeed.rawValue))
        rock.physicsBody?.categoryBitMask = PhysicsCategory.Rock.rawValue
        rock.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.EnemyCageEdge.rawValue | PhysicsCategory.EnemyFast.rawValue | PhysicsCategory.EnemyNormal.rawValue | PhysicsCategory.EnemySlow.rawValue
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
            case .StopTime:
                removeStopTimeEffect()
            case .TurnCats:
                removeTurnCatsEffect()
            case .DogFood:
                removeDogFoodEffect()
            case .WhosYourDaddy:
                removeWhosYourDaddyEffect()
            case .SlowDown:
                removeSlowDownEffect()
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
        gameScene.playerPhantom?.removeAllActions()
        gameScene.playerPhantom?.removeFromParent()
        gameScene.playerPhantom = nil
    }
    
    private func removeStopTimeEffect(){
        gameScene.stopTimeEnabled = false
        for enemy in gameScene.enemyGenerator.slowEnemies{
            enemy.paused = false
        }
        for enemy in gameScene.enemyGenerator.normalEnemies{
            enemy.paused = false
            enemy.physicsBody?.velocity = CGVector(point: angleToDirection(enemy.zRotation)*CGFloat(GameSpeed.EnemyNormalSpeed.rawValue))
        }
        if let fastEnemy = gameScene.enemyLayer.childNodeWithName("fastEnemy"){
            fastEnemy.paused = false
            fastEnemy.physicsBody?.velocity = CGVector(point: angleToDirection(fastEnemy.zRotation)*CGFloat(GameSpeed.EnemyFastSpeed.rawValue))
        }
    }
    
    private func removeTurnCatsEffect(){
        for slow in gameScene.enemyGenerator.slowEnemies{
            slow.sprite.color = SKColor.blueColor()
            slow.physicsBody?.categoryBitMask = PhysicsCategory.EnemySlow.rawValue
            slow.physicsBody?.velocity *= CGFloat(GameSpeed.EnemySlowSpeed.rawValue/GameSpeed.CatSpeed.rawValue)
        }
        for normal in gameScene.enemyGenerator.normalEnemies{
            normal.sprite.color = SKColor.whiteColor()
            normal.physicsBody?.categoryBitMask = PhysicsCategory.EnemyNormal.rawValue
            normal.physicsBody?.velocity *= CGFloat(GameSpeed.EnemyNormalSpeed.rawValue/GameSpeed.CatSpeed.rawValue)
        }
        if let fast = gameScene.enemyLayer.childNodeWithName("faseEnemy") as? EnemyFast{
            fast.sprite.color = SKColor.redColor()
            fast.physicsBody?.categoryBitMask = PhysicsCategory.EnemyFast.rawValue
            fast.physicsBody?.velocity *= CGFloat(GameSpeed.EnemyFastSpeed.rawValue/GameSpeed.CatSpeed.rawValue)
        }
    }
    
    private func removeDogFoodEffect(){
        gameScene.dogFoodArea = nil
    }
    
    private func removeWhosYourDaddyEffect(){
        gameScene.whosYourDaddyEnabled = false
    }
    
    private func removeSlowDownEffect(){
        gameScene.slowDownEnabled = false
        gameScene.player.childNodeWithName("circle")?.removeFromParent()
        for enemy in gameScene.enemyLayer.children{
            var originalSpeed: CGFloat!
            if enemy is EnemySlow{
                originalSpeed = CGFloat(GameSpeed.EnemySlowSpeed.rawValue)
            }
            else if enemy is EnemyNormal{
                originalSpeed = CGFloat(GameSpeed.EnemyNormalSpeed.rawValue)
            }
            else{
                originalSpeed = CGFloat(GameSpeed.EnemyFastSpeed.rawValue)
            }
            enemy.physicsBody?.velocity = enemy.physicsBody!.velocity.normalized()*originalSpeed
        }
    }
}