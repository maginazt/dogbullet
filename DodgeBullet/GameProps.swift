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
    
    static let spinNumber = 10
    static let blinkNumber = 10
    // 有效时间
    static let maxEffectTime = 10
    static let TimerActionKey = "timerActionKey"
    
    static let SpinActionKey = "spinActionKey"
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
//            SKAction.repeatAction(spin, count: GameProps.spinNumber),
            SKAction.waitForDuration(NSTimeInterval(GameProps.spinNumber)),
            SKAction.repeatAction(blink, count: GameProps.blinkNumber),
            SKAction.removeFromParent()])
    }()
    
    let type: GamePropsType
    
    var effectTime = GameProps.maxEffectTime
    var countDownLabel: SKLabelNode!
    var delegate: GamePropsDelegate?
    
    init(gamePropsType: GamePropsType){
//        type = gamePropsType
        type = .SlowDown
        let atlas = SKTextureAtlas(named: "characters")
        var texture: SKTexture!
        switch type{
        case .DogFood:
            texture = atlas.textureNamed("dogFood")
        case .Phantom:
            texture = atlas.textureNamed("phantom")
        case .SlowDown:
            texture = atlas.textureNamed("slowDown")
        case .Rock:
            texture = atlas.textureNamed("rock")
        default:
            texture = atlas.textureNamed("whosYourDaddy")
        }
        super.init(texture: texture, color: SKColor.whiteColor(), size: CGSizeMake(75, 75))
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.dynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.GameProps.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue
        
        countDownLabel = SKLabelNode(fontNamed: "Arial")
        countDownLabel.fontSize = size.width/2
        countDownLabel.fontColor = SKColor.blackColor()
        countDownLabel.position = CGPointMake(0, -size.height)
        countDownLabel.text = "\(effectTime)"
        countDownLabel.hidden = true
        addChild(countDownLabel)
        
        runAction(GameProps.spinAnimate, withKey: GameProps.SpinActionKey)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeEffect(delegate: GamePropsDelegate){
        removeActionForKey(GameProps.SpinActionKey)
        physicsBody = nil
        alpha = 1.0
        self.delegate = delegate
        countDownLabel.hidden = false
        //计时action
        runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock({ () -> Void in
                self.countDownLabel.text = "\(--self.effectTime)"
                switch self.effectTime{
                case 4 ... 10:
                    self.countDownLabel.fontColor = SKColor.blackColor()
                case 0 ... 3:
                    self.countDownLabel.fontColor = SKColor.redColor()
                default:
                    break
                }
                if self.effectTime <= 0{
                    self.delegate?.disableEffect(self.type)
                }
            })])), withKey: GameProps.TimerActionKey)
    }
    
    func resetEffectTimer(){
        effectTime = GameProps.maxEffectTime
    }
    
}
protocol GamePropsDelegate{
    //道具到时，消除道具效果
    func disableEffect(type: GamePropsType)
}