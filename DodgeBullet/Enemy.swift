//
//  Bullet.swift
//  DodgeBullet
//  敌人
//  Created by 赵涛 on 15/10/12.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class Enemy: SKNode{
    
    let sprite: AnimatingSprite
    var effect: SKEmitterNode?
    
    let moveSpeed: CGFloat
    var currentSpeed: CGFloat{
        get{
            return moveSpeed
        }
        set{
            physicsBody?.velocity = CGVector(point: angleToDirection(zRotation)) * newValue
        }
    }
    
    init(textureName: String, moveSpeed: CGFloat) {
        let atlas = SKTextureAtlas(named: "characters")
        let texture = atlas.textureNamed(textureName)
        sprite = AnimatingSprite(t: texture)
        sprite.xScale = 0.7
        sprite.yScale = 0.7
        sprite.runningAnim = SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlasNamed("characters", prefix: "enemy", numOfPics: 2, timePerFrame: 0.1))
        self.moveSpeed = moveSpeed
        super.init()
        addChild(sprite)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveToward(target: CGPoint){
        physicsBody?.velocity = CGVector(point: target)
        if let gameScene = scene as? GameScene{
            if gameScene.stopTimeEnabled{
                currentSpeed = 0
            }
        }
    }
    
    func faceCurrentDirection(){
        if let dir = physicsBody?.velocity{
            zRotation = dir.angle
        }
    }
    
    func turnCat(){
        sprite.color = SKColor.purpleColor()
        sprite.colorBlendFactor = 0.9
        physicsBody?.categoryBitMask = PhysicsCategory.Cat.rawValue
        if let gameScene = scene as? GameScene{
            if !gameScene.stopTimeEnabled{
                currentSpeed = CGFloat(GameSpeed.CatSpeed.rawValue)
            }
        }
        effect?.removeFromParent()
    }
    
    func resumeFromCat(){
        if let gameScene = scene as? GameScene{
            if !gameScene.stopTimeEnabled{
                currentSpeed = moveSpeed
            }
        }
        if let e = effect{
            addChild(e)
        }
    }
}
class EnemyNormal: Enemy {
    
    init(textureName: String) {
        super.init(textureName: textureName, moveSpeed: CGFloat(GameSpeed.EnemyNormalSpeed.rawValue))
        physicsBody = SKPhysicsBody(circleOfRadius: sprite.texture!.size().width/11, center: CGPointMake(sprite.texture!.size().width/5, 0))
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.0
        physicsBody?.restitution = 1.0
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyNormal.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue | PhysicsCategory.EnemyCageEdge.rawValue
        sprite.runAction(sprite.runningAnim)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resumeFromCat() {
        sprite.color = SKColor.whiteColor()
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyNormal.rawValue
        super.resumeFromCat()
    }
}

class EnemySlow: Enemy {
    
    init(textureName: String) {
        super.init(textureName: textureName, moveSpeed: CGFloat(GameSpeed.EnemySlowSpeed.rawValue))
        sprite.color = SKColor.blueColor()
        sprite.colorBlendFactor = 0.9
        physicsBody = SKPhysicsBody(circleOfRadius: sprite.texture!.size().width/11, center: CGPointMake(sprite.texture!.size().width/5, 0))
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.0
        physicsBody?.restitution = 0.0
        physicsBody?.categoryBitMask = PhysicsCategory.EnemySlow.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue
        sprite.runAction(sprite.runningAnim)
    }
    
    func setupGhostEffect(){
        if let emitter = SKEmitterNode(fileNamed: "ghostlight"){
            effect = emitter
            emitter.position = CGPointMake(-sprite.texture!.size().width/6, 0)
            addChild(emitter)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resumeFromCat() {
        sprite.color = SKColor.blueColor()
        physicsBody?.categoryBitMask = PhysicsCategory.EnemySlow.rawValue
        super.resumeFromCat()
    }
    
}

class EnemyFast: Enemy{
    
    init(textureName: String) {
        super.init(textureName: textureName, moveSpeed: CGFloat(GameSpeed.EnemyFastSpeed.rawValue))
        sprite.color = SKColor.redColor()
        sprite.colorBlendFactor = 0.9
        physicsBody = SKPhysicsBody(circleOfRadius: sprite.texture!.size().width/11, center: CGPointMake(sprite.texture!.size().width/5, 0))
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.0
        physicsBody?.restitution = 1.0
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyFast.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue | PhysicsCategory.EnemyCageEdge.rawValue
        sprite.runAction(sprite.runningAnim)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFireEffect(){
        if let emitter = SKEmitterNode(fileNamed: "firetail"){
            effect = emitter
            emitter.position = CGPointMake(-sprite.texture!.size().width/5, 0)
            emitter.targetNode = scene
            addChild(emitter)
        }
    }
    
    override func resumeFromCat() {
        sprite.color = SKColor.redColor()
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyFast.rawValue
        super.resumeFromCat()
    }
}