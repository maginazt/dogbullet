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
    
    static let runningActionKey = "runningActionKey"
    static let runningAnim = SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlas(Resources.characterAtlas, prefix: "enemy", numOfPics: 2, timePerFrame: 0.1))
    
    static let purgeActionKey = "purgeActionKey"
    static let purgeAnim = SKAction.repeatActionForever(SKAction.sequence([
        SKAction.colorizeWithColor(SKColor.blackColor(), colorBlendFactor: 0.9, duration: 0.5),
        SKAction.colorizeWithColor(SKColor.whiteColor(), colorBlendFactor: 0.9, duration: 0.5)]))
    
    let sprite: SKSpriteNode
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
        let texture = Resources.characterAtlas.textureNamed(textureName)
        sprite = SKSpriteNode(texture: texture)
        sprite.xScale = 0.7
        sprite.yScale = 0.7
        self.moveSpeed = moveSpeed
        super.init()
        addChild(sprite)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveToward(target: CGPoint){
        physicsBody?.velocity = CGVector(point: target)
    }
    
    func faceCurrentDirection(){
        if let dir = physicsBody?.velocity{
            zRotation = dir.angle
        }
    }
    
    func turnCat(){
        sprite.color = SKColor.goldColor()
        sprite.colorBlendFactor = 0.9
        physicsBody?.categoryBitMask = PhysicsCategory.Cat.rawValue
        effect?.hidden = true
        effect?.targetNode = nil
    }
    
    func resumeFromCat(){
        currentSpeed = moveSpeed
        effect?.hidden = false
        effect?.targetNode = scene
    }
    
    func purge(){
        currentSpeed = CGFloat(GameSpeed.SlowDownSpeed.rawValue)
        if sprite.actionForKey(Enemy.purgeActionKey) == nil{
            sprite.runAction(Enemy.purgeAnim, withKey: Enemy.purgeActionKey)
            effect?.hidden = true
            effect?.targetNode = nil
        }
    }
    
    func resumeFromPurge(){
        currentSpeed = moveSpeed
        sprite.removeActionForKey(Enemy.purgeActionKey)
        effect?.hidden = false
        effect?.targetNode = scene
    }
}
class EnemyNormal: Enemy {
    
    init(textureName: String) {
        super.init(textureName: textureName, moveSpeed: CGFloat(GameSpeed.EnemyNormalSpeed.rawValue))
        physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sprite.texture!.size().width*0.4, sprite.texture!.size().height*0.15))
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.0
        physicsBody?.restitution = 1.0
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyNormal.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue | PhysicsCategory.EnemyCageEdge.rawValue
        sprite.runAction(Enemy.runningAnim, withKey: Enemy.runningActionKey)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFootPrintEffect(){
        if let emitter = SKEmitterNode(fileNamed: "footprint"){
            effect = emitter
            emitter.position = CGPointMake(-sprite.texture!.size().width/3, 0)
            emitter.targetNode = scene
            addChild(emitter)
        }
    }
    
    override func faceCurrentDirection() {
        super.faceCurrentDirection()
        effect?.particleRotation = zRotation
    }
    
    override func resumeFromCat() {
        sprite.runAction(SKAction.colorizeWithColor(SKColor.whiteColor(), colorBlendFactor: 0.9, duration: 1))
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyNormal.rawValue
        super.resumeFromCat()
    }
    
    override func resumeFromPurge() {
        super.resumeFromPurge()
        sprite.color = SKColor.whiteColor()
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
        sprite.runAction(Enemy.runningAnim, withKey: Enemy.runningActionKey)
    }
    
    func setupGhostEffect(){
        if let emitter = SKEmitterNode(fileNamed: "ghostlight"){
            effect = emitter
            emitter.targetNode = scene
//            emitter.position = CGPointMake(-sprite.texture!.size().width/11, 0)
            addChild(emitter)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resumeFromCat() {
        sprite.runAction(SKAction.colorizeWithColor(SKColor.blueColor(), colorBlendFactor: 0.9, duration: 1))
        physicsBody?.categoryBitMask = PhysicsCategory.EnemySlow.rawValue
        super.resumeFromCat()
    }
    
    override func resumeFromPurge() {
        super.resumeFromPurge()
        sprite.color = SKColor.blueColor()
    }
    
}

class EnemyFast: Enemy{
    
    init(textureName: String) {
        super.init(textureName: textureName, moveSpeed: CGFloat(GameSpeed.EnemyFastSpeed.rawValue))
        sprite.color = SKColor.redColor()
        sprite.colorBlendFactor = 0.9
        physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sprite.texture!.size().width*0.4, sprite.texture!.size().height*0.15))
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.0
        physicsBody?.restitution = 1.0
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyFast.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue | PhysicsCategory.EnemyCageEdge.rawValue
        sprite.runAction(Enemy.runningAnim, withKey: Enemy.runningActionKey)
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
        sprite.runAction(SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 0.9, duration: 1))
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyFast.rawValue
        super.resumeFromCat()
    }
    
    override func resumeFromPurge() {
        super.resumeFromPurge()
        sprite.color = SKColor.redColor()
    }
}