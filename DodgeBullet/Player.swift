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
    
    let mainSprite: AnimatingSprite
    var tail: SKEmitterNode!
    let mainBody: SKPhysicsBody
    
    let fireLength: CGFloat = 512
    //开火区
    var fireRect: CGRect{
        let gameScene = scene as! GameScene
        var lowerX = position.x - fireLength/2
        var lowerY = position.y - fireLength/2
        var width: CGFloat = fireLength
        var height: CGFloat = fireLength
        if lowerX < CGRectGetMinX(gameScene.playableArea){
            width = fireLength + lowerX - CGRectGetMinX(gameScene.playableArea)
            lowerX = CGRectGetMinX(gameScene.playableArea)
        }
        if lowerY < CGRectGetMinY(gameScene.playableArea){
            height = fireLength + lowerY - CGRectGetMinY(gameScene.playableArea)
            lowerY = CGRectGetMinY(gameScene.playableArea)
        }
        if lowerX + width > CGRectGetMaxX(gameScene.playableArea){
            width = CGRectGetMaxX(gameScene.playableArea) - lowerX
        }
        if lowerY + height > CGRectGetMaxY(gameScene.playableArea){
            height = CGRectGetMaxY(gameScene.playableArea) - lowerY
        }
        return CGRectMake(lowerX, lowerY, width, height)
    }
    
    override init() {
//        let texture = SKTexture(imageNamed: "Spaceship")
        let atlas = SKTextureAtlas(named: "characters")
        let texture = atlas.textureNamed("player-0")
        mainSprite = AnimatingSprite(t: texture)
        mainSprite.runningAnim = SKAction.repeatActionForever(AnimatingSprite.createAnimWithAtlasNamed("characters",prefix: "player", numOfPics: 4, timePerFrame: 0.1))
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
        if !mainSprite.hasActions(){
            mainSprite.runAction(mainSprite.runningAnim)
        }
    }
    
    func setupTail(){
        if let emitter = SKEmitterNode(fileNamed: "playertail"){
//            emitter.position = CGPointMake(-mainSprite.size.width/5, -mainSprite.size.height/5)
            emitter.targetNode = scene
            tail = emitter
            tail.particleSpeed = 0.0
            addChild(tail)
        }
    }
}