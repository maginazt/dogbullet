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
    
    static let showTime: NSTimeInterval = 10
    static let blinkNumber = 10
    // 有效时间
    static let maxEffectTime = 10
    static let TimerActionKey = "timerActionKey"
    
    static let SpinActionKey = "spinActionKey"
    static let spinAnimate: SKAction = {
        let blink = SKAction.sequence([
            SKAction.fadeOutWithDuration(0.25),
            SKAction.fadeInWithDuration(0.25)])
        
        return SKAction.sequence([
            SKAction.waitForDuration(GameProps.showTime),
            SKAction.repeatAction(blink, count: GameProps.blinkNumber),
            SKAction.removeFromParent()])
    }()
    
    let type: GamePropsType
    
    var effectTime = GameProps.maxEffectTime
    var countDownLabel: SKLabelNode!
    var delegate: GamePropsDelegate?
    let des: String
    
    init(gamePropsType: GamePropsType){
        type = gamePropsType
//        type = .DogFood
        var texture: SKTexture!
        switch type{
        case .DogFood:
            texture = Resources.characterAtlas.textureNamed("dogFood")
            des = NSLocalizedString("dogFoodDes", comment: "Dog Food Description")
        case .Phantom:
            texture = Resources.characterAtlas.textureNamed("phantom")
            des = NSLocalizedString("phantomDes", comment: "Phantom Description")
        case .SlowDown:
            texture = Resources.characterAtlas.textureNamed("slowDown")
            des = NSLocalizedString("slowDownDes", comment: "Slow Down Description")
        case .Rock:
            texture = Resources.characterAtlas.textureNamed("rock")
            des = NSLocalizedString("rockDes", comment: "Rock Description")
        default:
            texture = Resources.characterAtlas.textureNamed("whosYourDaddy")
            des = NSLocalizedString("shieldDes", comment: "Shield Description")
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