//
//  Resources.swift
//  DodgeBullet
//
//  Created by user on 15/11/13.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion
class Resources{
    
    static let characterAtlas = SKTextureAtlas(named: "characters")
    static let effectAtlas = SKTextureAtlas(named: "effects")
    
    static func loadResources(completionHandler: (() -> Void)?){
        SKTextureAtlas.preloadTextureAtlases([characterAtlas, effectAtlas]){
            completionHandler?()
        }
    }
    
    static var accelerometerAvailable = false
    
    static func checkAvailablity(){
        accelerometerAvailable = CMMotionManager().accelerometerAvailable
    }
}