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
    
    init(textureName: String) {
        let atlas = SKTextureAtlas(named: "characters")
        let texture = atlas.textureNamed(textureName)
        sprite = AnimatingSprite(t: texture)
        sprite.xScale = 0.6
        sprite.yScale = 0.6
        sprite.runningAnim = AnimatingSprite.createAnimWithPrefix("enemy", numOfPics: 2, timePerFrame: 0.1)
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
}
class EnemyNormal: Enemy {
    
    override init(textureName: String) {
        super.init(textureName: textureName)
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
}

class EnemySlow: Enemy {
    
    override init(textureName: String) {
        super.init(textureName: textureName)
        sprite.color = SKColor.blueColor()
        sprite.colorBlendFactor = 0.9
        physicsBody = SKPhysicsBody(circleOfRadius: sprite.texture!.size().width/11, center: CGPointMake(sprite.texture!.size().width/5, 0))
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.0
        physicsBody?.restitution = 0.0
        physicsBody?.categoryBitMask = PhysicsCategory.EnemySlow.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EnemyFast: Enemy{
    
    override init(textureName: String) {
        super.init(textureName: textureName)
        sprite.color = SKColor.redColor()
        sprite.colorBlendFactor = 0.9
        physicsBody = SKPhysicsBody(circleOfRadius: sprite.texture!.size().width/11, center: CGPointMake(sprite.texture!.size().width/5, 0))
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.0
        physicsBody?.restitution = 1.0
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyFast.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue | PhysicsCategory.EnemyCageEdge.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}