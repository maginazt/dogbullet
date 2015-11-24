//
//  GamePropsGenerator.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/25.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
import AudioToolbox
class GamePropsGenerator : GamePropsDelegate {
    
    static let dustInActionKey = "dustInAction"
    static let dustInAnim = SKAction.group([
        SKAction.fadeInWithDuration(3),
        SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlas(Resources.effectAtlas, prefix: "dust", numOfPics: 14, timePerFrame: 0.05))])
    
    static let dogFoodAnim: SKAction = {
        let moveUpFull = SKAction.moveByX(0, y: 200, duration: 0.2)
        let scaleUpFull = SKAction.scaleTo(2, duration: 0.2)
        let moveUpHalf = SKAction.moveByX(0, y: 100, duration: 0.1)
        let scaleUpHalf = SKAction.scaleTo(1.85, duration: 0.1)
        let moveUpQualter = SKAction.moveByX(0, y: 50, duration: 0.05)
        let scaleUpQualter = SKAction.scaleTo(1.7, duration: 0.05)
        return SKAction.group([
            SKAction.sequence([moveUpFull, moveUpFull.reversedAction(), moveUpHalf, moveUpHalf.reversedAction(), moveUpQualter, moveUpQualter.reversedAction()]),
            SKAction.sequence([scaleUpFull, SKAction.scaleTo(1.5, duration: 0.2), scaleUpHalf, SKAction.scaleTo(1.5, duration: 0.1), scaleUpQualter, SKAction.scaleTo(1.5, duration: 0.05)]),
            SKAction.rotateByAngle(CGFloat(7*M_PI), duration: 0.7)])
    }()
    static let rockAnim = SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(2*M_PI), duration: 1))
    static let shieldAnim = SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlas(Resources.effectAtlas, prefix: "unbreakable", numOfPics: 10, timePerFrame: 0.25))
    static let slowDownAnim = SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlas(Resources.effectAtlas, prefix: "slow", numOfPics: 9, timePerFrame: 0.12))
    static let fadeout0_5Anim = SKAction.sequence([
        SKAction.fadeOutWithDuration(0.5),
        SKAction.removeFromParent()])
    static let fadeout2Anim = SKAction.sequence([
        SKAction.fadeOutWithDuration(2),
        SKAction.removeFromParent()])
    
    weak var gameScene: GameScene!
    
    init(gameScene: GameScene){
        self.gameScene = gameScene
        //道具生成策略：随机生成
        createNextGameProps()
    }
    
    func createNextGameProps(){
        gameScene.runAction(SKAction.sequence([
            SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 2, max: 3))),
            SKAction.runBlock({ () -> Void in
                if !GameViewController.firstLaunch && !self.gameScene.stopTimeEnabled{
                    self.spawnGameProps()
                }
                self.createNextGameProps()
            })]))
    }
    
    func spawnGameProps(){
        var gameProps: GameProps!
        if gameScene.turnCatEnabled{
            gameProps = GameProps(gamePropsType: .Rock)
        }
        else{
            gameProps = GameProps(gamePropsType: GamePropsType(rawValue: random() % GamePropsType.Maximum.rawValue)!)
            if gameProps.type == .DogFood && (gameScene.dogFoodArea != nil || gameScene.gamePropsLayer.childNodeWithName("dogFoodProps") != nil){
                return
            }
            if gameProps.type == .DogFood{
                gameProps.name = "dogFoodProps"
            }
        }
        gameProps.position = randomPointInRect(CGRectInset(gameScene.playableArea, gameScene.gamePropsBanner.gridSize*2, gameScene.gamePropsBanner.gridSize*2))
        gameScene.gamePropsLayer.addChild(gameProps)
    }
    
    // 添加游戏道具效果
    func handleGamePropsEffect(gameProps: GameProps){
        if UserDocuments.soundStatus{
            switch gameProps.type{
            case .WhosYourDaddy:
                AudioServicesPlaySystemSound(Resources.shieldSound)
            case .SlowDown:
                AudioServicesPlaySystemSound(Resources.slowdownSound)
            case .Rock:
                AudioServicesPlaySystemSound(Resources.rockSound)
            default:
                AudioServicesPlaySystemSound(Resources.gamepropsSound)
            }
        }
        if gameScene.gamePropsMap.keys.contains(gameProps.type){
            switch gameProps.type{
            case .Rock:
                gameScene.showTinyMessage(gameProps.position, text: gameProps.des, color: SKColor.blackColor())
            case .WhosYourDaddy:
                gameScene.showTinyMessage(gameProps.position, text: String(format: NSLocalizedString("shieldRemaining", comment: "Shield Remaining Text"), maxShieldCount), color: SKColor.blackColor())
            default:
                gameScene.showTinyMessage(gameProps.position, text: NSLocalizedString("resetCountdown", comment: "Reset CountDown Text"), color: SKColor.blackColor())
            }
            let oldGameProps = gameScene.gamePropsMap[gameProps.type]!
            oldGameProps.resetEffectTimer()
            if gameProps.type == .WhosYourDaddy{
                addWhosYourDaddyEffect()
            }
            gameProps.removeFromParent()
        }
        else{
            gameScene.showTinyMessage(gameProps.position, text: gameProps.des, color: SKColor.blackColor())
            if gameProps.type == GamePropsType.Rock{
                gameProps.removeFromParent()
            }
            else{
                gameScene.gamePropsMap[gameProps.type] = gameProps
                gameProps.initializeEffect(self)
                gameScene.gamePropsBanner.add(gameProps)
            }
            switch gameProps.type{
            case .Phantom:
                addPhantomEffect()
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
    
    private func addPhantomEffect(){
        let phantom = Player()
        phantom.mainSprite.color = SKColor.redColor()
        phantom.mainSprite.colorBlendFactor = 0.9
        phantom.mainSprite.alpha = 0.7
        phantom.physicsBody = nil
        phantom.position = gameScene.player.position
        gameScene.playerPhantom = phantom
        gameScene.addChild(phantom)
        phantom.setupTail("phantomtail")
        
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
    
    private func addDogFoodEffect(position: CGPoint){
        gameScene.dogFoodArea = CGRectMake(position.x-50, position.y-25, 100, 50)
        //狗粮
        let food = SKSpriteNode(texture: Resources.characterAtlas.textureNamed("food"))
        food.position = position
        food.name = "dogFood"
        food.runAction(GamePropsGenerator.dogFoodAnim)
        gameScene.gamePropsLayer.addChild(food)
        //尘土
        let dust = SKSpriteNode(texture: Resources.effectAtlas.textureNamed("dust-1"))
        dust.alpha = 0
        dust.xScale = 2
        dust.yScale = 2
        dust.position = position
        dust.zPosition = CGFloat(SceneZPosition.EnemyZPosition.rawValue) + 1
        dust.name = "dust"
        gameScene.gamePropsLayer.addChild(dust)
    }
    
    private func addRockEffect(position: CGPoint){
        for _ in 0 ..< 20{
            spawnRock(position)
        }
    }
    
    private func spawnRock(position: CGPoint){
        let rock = SKSpriteNode(texture: Resources.characterAtlas.textureNamed("ammo"), color: SKColor.whiteColor(), size: CGSizeMake(20, 20))
        rock.runAction(GamePropsGenerator.rockAnim)
        rock.position = position
        gameScene.addChild(rock)
        rock.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        rock.physicsBody?.usesPreciseCollisionDetection = true
        rock.physicsBody?.linearDamping = 0
        rock.physicsBody?.velocity = CGVector(point: angleToDirection(CGFloat.random(min: 0, max: CGFloat(M_PI*2.0)))*CGFloat(GameSpeed.RockSpeed.rawValue))
        rock.physicsBody?.categoryBitMask = PhysicsCategory.Rock.rawValue
        rock.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.EnemyCageEdge.rawValue | PhysicsCategory.EnemyFast.rawValue | PhysicsCategory.EnemyNormal.rawValue | PhysicsCategory.EnemySlow.rawValue | PhysicsCategory.Cat.rawValue
    }
    
    let maxShieldCount = 3
    
    private func addWhosYourDaddyEffect(){
        gameScene.shieldCount = maxShieldCount
        gameScene.player.childNodeWithName("shield")?.removeFromParent()
        let shield = SKSpriteNode(texture: Resources.effectAtlas.textureNamed("unbreakable-1"))
        shield.name = "shield"
        shield.runAction(GamePropsGenerator.shieldAnim)
        gameScene.player.addChild(shield)
    }
    
    let slowDownRadius: CGFloat = 200
    
    private func addSlowDownEffect(){
        gameScene.slowDownEnabled = true
        let circle = SKSpriteNode(texture: Resources.effectAtlas.textureNamed("slow-1"))
        circle.xScale = 2
        circle.yScale = 2
        circle.name = "circle"
        circle.runAction(GamePropsGenerator.slowDownAnim)
        gameScene.player.addChild(circle)
    }
    
    // 消除游戏道具效果
    func disableEffect(type: GamePropsType) {
        if let gameProps = gameScene.gamePropsMap.removeValueForKey(type){
            gameScene.gamePropsBanner.remove(gameProps)
            switch gameProps.type{
            case .Phantom:
                removePhantomEffect()
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
    
    private func removePhantomEffect(){
        gameScene.playerPhantom?.runAction(GamePropsGenerator.fadeout0_5Anim)
        gameScene.playerPhantom = nil
    }
    
    private func removeDogFoodEffect(){
        gameScene.dogFoodArea = nil
        gameScene.gamePropsLayer.childNodeWithName("dogFood")?.runAction(GamePropsGenerator.fadeout0_5Anim)
        gameScene.gamePropsLayer.childNodeWithName("dust")?.removeAllActions()
        gameScene.gamePropsLayer.childNodeWithName("dust")?.runAction(GamePropsGenerator.fadeout2Anim)
    }
    
    private func removeWhosYourDaddyEffect(){
        gameScene.shieldCount = 0
        gameScene.player.childNodeWithName("shield")?.runAction(GamePropsGenerator.fadeout0_5Anim)
        gameScene.showTinyMessage(gameScene.player.position, text: NSLocalizedString("shieldBroken", comment: "Shield Broken Text"), color: SKColor.blackColor())
    }
    
    private func removeSlowDownEffect(){
        gameScene.slowDownEnabled = false
        gameScene.player.childNodeWithName("circle")?.runAction(GamePropsGenerator.fadeout0_5Anim)
        for enemyNode in gameScene.enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                enemy.resumeFromPurge()
            }
        }
    }
}