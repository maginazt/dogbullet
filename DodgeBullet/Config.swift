//
//  Config.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/17.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
class Config {
    static let ControllerStatusChangedNotification = "ControllerStatusChangedNotification"
    static let SpeedValueChangedNotification = "SpeedValueChangedNotification"
    
    private static let NONE = 0
    private static let ON = 1
    private static let OFF = 2
    
    private static let MUSIC_STATUS_KEY = "MusicStatusKey"
    static var musicStatus: Bool = {
        do{
            var status = true
            try status = Config.getStatusForKey(MUSIC_STATUS_KEY)
            return status
        }
        catch{
            return true
        }
    }()
    
    private static let SOUND_STATUS_KEY = "SoundStatusKey"
    static var soundStatus: Bool = {
        do{
            var status = true
            try status = Config.getStatusForKey(SOUND_STATUS_KEY)
            return status
        }
        catch{
            return true
        }
    }()
    
    private static let CONTROLLER_STATUS_KEY = "ControllerStatusKey"
    static var controllerStatus: ControllerType = {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let status = userDefaults.integerForKey(CONTROLLER_STATUS_KEY)
        return ControllerType(rawValue: status)!
    }()
    
    private static func getStatusForKey(key: String) throws -> Bool{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let status = userDefaults.integerForKey(key)
        if status == NONE{
            throw PreferenceErrorType.NotExist
        }
        else{
            return status == ON
        }
    }
    
    private static func setStatus(status: Bool, forKey key: String){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if status{
            userDefaults.setInteger(ON, forKey: key)
        }
        else{
            userDefaults.setInteger(OFF, forKey: key)
        }
    }
    
    static func saveConfiguration(){
        setStatus(musicStatus, forKey: MUSIC_STATUS_KEY)
        setStatus(soundStatus, forKey: SOUND_STATUS_KEY)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(controllerStatus.rawValue, forKey: CONTROLLER_STATUS_KEY)
        NSNotificationCenter.defaultCenter().postNotificationName(ControllerStatusChangedNotification, object: nil)
    }
}