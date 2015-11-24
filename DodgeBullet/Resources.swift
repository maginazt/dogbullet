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
import AudioToolbox
import AVFoundation
class Resources{
    
    static let appStoreUrl = NSURL(string: "https://www.store.apple.com")
    
    static let characterAtlas = SKTextureAtlas(named: "characters")
    static let effectAtlas = SKTextureAtlas(named: "effects")
    
    static func loadResources(completionHandler: (() -> Void)?){
        SKTextureAtlas.preloadTextureAtlases([characterAtlas, effectAtlas]){
            completionHandler?()
        }
        let blur = CIFilter(name: "CIGaussianBlur")!
        blur.setValue(20, forKey: kCIInputRadiusKey)
        GameScene.blurFilter = blur
    }
    
    static var accelerometerAvailable = false
    
    static func checkAvailablity(){
        accelerometerAvailable = CMMotionManager().accelerometerAvailable
    }
    
    static func createSound(file: String) -> SystemSoundID{
        var sound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(NSBundle.mainBundle().URLForResource(file, withExtension: nil)!, &sound)
        return sound
    }
    
    static let coinSound = Resources.createSound("coin.wav")
    static let purgeSound = Resources.createSound("purge.wav")
    static let shieldSound = Resources.createSound("shield.wav")
    static let slowdownSound = Resources.createSound("slowdown.wav")
    static let gamepropsSound = Resources.createSound("gameprops.wav")
    static let rockSound = Resources.createSound("rock.wav")
    static let buttonSound = Resources.createSound("button.wav")
    static let deadSound = Resources.createSound("dead.wav")
    static let kickSound = Resources.createSound("kick.wav")
    static let hitSound = Resources.createSound("hit.wav")
    
    static let stepSound: AVAudioPlayer = {
        let player = try! AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("run", withExtension: "wav")!)
        player.numberOfLoops = -1
        player.prepareToPlay()
        return player
    }()
    
    static let ticktockSound: AVAudioPlayer = {
        let player = try! AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("ticktock", withExtension: "wav")!)
        player.numberOfLoops = -1
        player.prepareToPlay()
        return player
    }()
}