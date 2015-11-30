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
import GPUImage
class Resources{
    
    static let appStoreUrl = NSURL(string: "https://www.store.apple.com")
    
    static let characterAtlas = SKTextureAtlas(named: "characters")
    static let effectAtlas = SKTextureAtlas(named: "effects")
    
    static var activities: [UIActivity]!
    
    static func loadResources(completionHandler: (() -> Void)?){
        SKTextureAtlas.preloadTextureAtlases([characterAtlas, effectAtlas]){
            completionHandler?()
        }
        let blurFilter = GPUImageGaussianBlurFilter()
        blurFilter.blurRadiusInPixels = 7.0
        GameScene.GPUBlurFilter = blurFilter
        coinSound = createSound("coin.wav")
        purgeSound = createSound("purge.wav")
        shieldSound = createSound("shield.wav")
        slowdownSound = createSound("slowdown.wav")
        gamepropsSound = createSound("gameprops.wav")
        rockSound = createSound("rock.wav")
        buttonSound = createSound("button.wav")
        deadSound = createSound("dead.wav")
        kickSound = createSound("kick.wav")
        hitSound = createSound("hit.wav")
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        }
        catch{
            print("AVAudioSession AVAudioSessionCategoryAmbient failed")
        }
        ticktockSound = createMusic("ticktock.wav")
        stepSound = createMusic("run.wav")
        activities = [WeixinSessionActivity(), WeixinTimelineActivity()]
    }
    
    static var accelerometerAvailable = false
    
    static func checkAvailablity(){
        accelerometerAvailable = CMMotionManager().accelerometerAvailable
    }
    
    static var coinSound: SystemSoundID!
    static var purgeSound: SystemSoundID!
    static var shieldSound: SystemSoundID!
    static var slowdownSound: SystemSoundID!
    static var gamepropsSound: SystemSoundID!
    static var rockSound: SystemSoundID!
    static var buttonSound: SystemSoundID!
    static var deadSound: SystemSoundID!
    static var kickSound: SystemSoundID!
    static var hitSound: SystemSoundID!
    
    static var stepSound: AVAudioPlayer!
    static var ticktockSound: AVAudioPlayer!
    
    private static func createSound(file: String) -> SystemSoundID{
        var sound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(NSBundle.mainBundle().URLForResource(file, withExtension: nil)!, &sound)
        return sound
    }
    
    private static func createMusic(file: String) -> AVAudioPlayer{
        let player = try! AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource(file, withExtension: nil)!)
        player.numberOfLoops = -1
        player.prepareToPlay()
        return player
    }
}