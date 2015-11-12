//
//  ResourceLoader.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/21.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class AnimatingSprite: SKSpriteNode {
    
    var stopTexture: SKTexture!
    
    init(t: SKTexture) {
        super.init(texture: t, color: SKColor.whiteColor(), size: t.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func createAnimWithAtlasNamed(atlasName: String, prefix: String, numOfPics: Int, timePerFrame: NSTimeInterval) -> SKAction{
        let atlas = SKTextureAtlas(named: atlasName)
        var textures = [SKTexture]()
        for i in 1 ... numOfPics{
            textures.append(atlas.textureNamed(NSString(format: "%@-%d", prefix, i) as String))
        }
        return SKAction.animateWithTextures(textures, timePerFrame: timePerFrame)
    }
}