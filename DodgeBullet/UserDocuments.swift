//
//  Config.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/17.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
class UserDocuments {
    
    static let userDataFilePath: String = {
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        return NSString(string: documentPath).stringByAppendingPathComponent("userData.plist")
    }()
    static let ControllerStatusChangedNotification = "ControllerStatusChangedNotification"
    
    private static let NONE = 0
    private static let ON = 1
    private static let OFF = 2
    
    private static let MUSIC_STATUS_KEY = "MusicStatusKey"
    static var musicStatus: Bool = {
        do{
            var status = true
            try status = UserDocuments.getStatusForKey(MUSIC_STATUS_KEY)
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
            try status = UserDocuments.getStatusForKey(SOUND_STATUS_KEY)
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
    
    private static let BEST_RECORD_KEY = "BestRecordKey"
    static var bestRecord: NSTimeInterval = {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.doubleForKey(BEST_RECORD_KEY)
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
    
    private static func getUserDataForKey(key: String) throws -> Bool{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        return true
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
    }
    
    static func saveUserDocuments(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble(bestRecord, forKey: BEST_RECORD_KEY)
    }
}