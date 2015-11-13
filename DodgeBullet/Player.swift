//
//  Player.swift
//  DodgeBullet
//  
//  游戏角色
//  Created by 赵涛 on 15/10/12.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class Player: SKNode {
    
    static let runningActionKey = "runningActionKey"
    static let runningAnim = SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlas(Resources.characterAtlas,prefix: "player", numOfPics: 4, timePerFrame: 0.1))
    
    let mainSprite: AnimatingSprite
    var tail: SKEmitterNode!
    let mainBody: SKPhysicsBody
    
    let fireLength: CGFloat = 512
    //开火区
    var fireRect: CGRect{
        let gameScene = scene as! GameScene
        return CGRectIntersection(gameScene.playableArea, CGRect(origin: CGPointMake(position.x-fireLength/2, position.y-fireLength/2), size: CGSizeMake(fireLength, fireLength)))
    }
    
    var fireRectNarrow: CGRect{
        let gameScene = scene as! GameScene
        return CGRectIntersection(gameScene.playableArea, CGRect(origin: CGPointMake(position.x-fireLength/4, position.y-fireLength/4), size: CGSizeMake(fireLength/2, fireLength/2)))
    }
    
    override init() {
//        let texture = SKTexture(imageNamed: "Spaceship")
        let texture = Resources.characterAtlas.textureNamed("player-0")
        mainSprite = AnimatingSprite(t: texture)
        mainSprite.stopTexture = texture
        mainBody = SKPhysicsBody(circleOfRadius: texture.size().width/5)
        mainBody.allowsRotation = false
        mainBody.restitution = 0
        mainBody.categoryBitMask = PhysicsCategory.Player.rawValue
        mainBody.collisionBitMask = PhysicsCategory.Edge.rawValue
        super.init()
        physicsBody = mainBody
        addChild(mainSprite)
        zPosition = CGFloat(SceneZPosition.PlayerZPosition.rawValue)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveToward(target: CGPoint){
        physicsBody?.velocity = CGVector(point: target)
        if target == CGPointZero{
            mainSprite.removeAllActions()
            mainSprite.texture = mainSprite.stopTexture
        }
        else{
            faceCurrentDirection(target)
        }
    }
    
    func faceCurrentDirection(target: CGPoint){
        if let dir = physicsBody?.velocity{
            zRotation = dir.angle
        }
        else{
            zRotation = (target-position).angle
        }
        if tail != nil{
            tail.emissionAngle = zRotation + CGFloat(M_PI)
        }
        if mainSprite.actionForKey(Player.runningActionKey) == nil{
            mainSprite.runAction(Player.runningAnim, withKey: Player.runningActionKey)
        }
    }
    
    func setupTail(emitterFileName: String){
        if let emitter = SKEmitterNode(fileNamed: emitterFileName){
            emitter.targetNode = scene
            tail = emitter
            tail.particleSpeed = 0.0
            addChild(tail)
        }
    }
}