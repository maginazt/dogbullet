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
            if gameProps.type == .DogFood{
                addDogFoodEffect(gameProps.position)
            }
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
        phantom.runAction(SKAction.moveTo(lastMove.1, duration: NSTimeInterval((lastMove.1-self.gameScene.playerPhantom!.position).length()/GameSpeed.PlayerMaxSpeed.rawValue))){
            self.createNextMoveAction(area, lastMove: lastMove)
        }
    }
    
    private func createNextMoveAction(area: CGRect, var lastMove: (Int, CGPoint)){
        lastMove = randomPointOnSideOfRect(area, exclude: lastMove.0)
        gameScene.playerPhantom?.moveToward(lastMove.1)
        gameScene.playerPhantom?.runAction(SKAction.moveTo(lastMove.1, duration: NSTimeInterval((lastMove.1-gameScene.playerPhantom!.position).length()/GameSpeed.PlayerMaxSpeed.rawValue))){
            self.createNextMoveAction(area, lastMove: lastMove)
        }
    }
    
    private func addStopTimeEffect(){
        gameScene.stopTimeEnabled = true
        for enemyNode in gameScene.enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                enemy.paused = true
                enemy.currentSpeed = 0
            }
        }
    }
    
    private func addTurnCatsEffect(){
        gameScene.turnCatEnabled = true
        for enemyNode in gameScene.enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                enemy.turnCat()
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
    
    let maxShieldCount = 3
    
    private func addWhosYourDaddyEffect(){
        gameScene.shieldCount = maxShieldCount
        let shield = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(100, 100))
        shield.name = "shield"
        shield.runAction(SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlasNamed("effects", prefix: "unbreakable", numOfPics: 10, timePerFrame: 0.25)))
        gameScene.player.addChild(shield)
    }
    
    let slowDownRadius: CGFloat = 200
    
    private func addSlowDownEffect(){
        gameScene.slowDownEnabled = true
        let circle = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(slowDownRadius, slowDownRadius))
        circle.xScale = 2
        circle.yScale = 2
        circle.name = "circle"
        circle.zPosition = CGFloat(SceneZPosition.EnemyZPosition.rawValue) - 1
        circle.runAction(SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlasNamed("effects", prefix: "slow", numOfPics: 9, timePerFrame: 0.12)))
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
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.EnemyCageEdge.rawValue | PhysicsCategory.EnemyFast.rawValue | PhysicsCategory.EnemyNormal.rawValue | PhysicsCategory.EnemySlow.rawValue | PhysicsCategory.Cat.rawValue
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
        for enemyNode in gameScene.enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                enemy.paused = false
                if enemy.physicsBody?.categoryBitMask == PhysicsCategory.Cat.rawValue{
                    enemy.currentSpeed = CGFloat(GameSpeed.CatSpeed.rawValue)
                }
                else{
                    enemy.currentSpeed = enemy.moveSpeed
                }
            }
        }
    }
    
    private func removeTurnCatsEffect(){
        gameScene.turnCatEnabled = false
        for enemyNode in gameScene.enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                enemy.resumeFromCat()
            }
        }
    }
    
    private func removeDogFoodEffect(){
        gameScene.dogFoodArea = nil
    }
    
    private func removeWhosYourDaddyEffect(){
        gameScene.shieldCount = 0
        gameScene.player.childNodeWithName("shield")?.removeFromParent()
    }
    
    private func removeSlowDownEffect(){
        gameScene.slowDownEnabled = false
        gameScene.player.childNodeWithName("circle")?.removeFromParent()
        for enemyNode in gameScene.enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                if !gameScene.stopTimeEnabled{
                    enemy.currentSpeed = enemy.moveSpeed
                }
            }
        }
    }
}