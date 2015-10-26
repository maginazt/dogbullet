//
//  GameProps.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/25.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class GameProps: SKSpriteNode {
    
    static let spinAnimate: SKAction = {
        let spin = SKAction.sequence([
            SKAction.scaleXTo(0, duration: 0.3),
            SKAction.scaleXTo(-1, duration: 0.2),
            SKAction.scaleXTo(0, duration: 0.2),
            SKAction.scaleXTo(1, duration: 0.3)])
        spin.timingMode = .EaseInEaseOut
        
        let blink = SKAction.sequence([
            SKAction.fadeOutWithDuration(0.25),
            SKAction.fadeInWithDuration(0.25)])
        
        return SKAction.sequence([
            SKAction.repeatAction(spin, count: 15),
            SKAction.repeatAction(blink, count: 10),
            SKAction.removeFromParent()])
    }()
    
    let type: GamePropsType
    
    init(gamePropsType: GamePropsType){
        type = gamePropsType
        let atlas = SKTextureAtlas(named: "characters")
        var texture: SKTexture!
        switch type{
        case .SpeedUp:
            texture = atlas.textureNamed("speedUp")
        case .ScaleDown:
            texture = atlas.textureNamed("scaleDown")
        default:
            texture = atlas.textureNamed("default")
        }
        super.init(texture: texture, color: SKColor.whiteColor(), size: CGSizeMake(50, 50))
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.dynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.GameProps.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue
        runAction(GameProps.spinAnimate)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}