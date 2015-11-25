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
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return documentPath.stringByAppendingPathComponent("userData.plist")
    }()
    static let userData: NSMutableDictionary = {
        if NSFileManager.defaultManager().fileExistsAtPath(UserDocuments.userDataFilePath){
            return NSMutableDictionary(contentsOfFile: UserDocuments.userDataFilePath)!
        }
        else{
            return NSMutableDictionary()
        }
    }()
    
    private static let SOUND_STATUS_KEY = "SoundStatusKey"
    static var soundStatus: Bool = {
        if let status = UserDocuments.userData.objectForKey(UserDocuments.SOUND_STATUS_KEY) as? NSNumber{
            return status.boolValue
        }
        else{
            return true
        }
    }()
    
    static let ControllerStatusChangedNotification = "ControllerStatusChangedNotification"
    private static let CONTROLLER_STATUS_KEY = "ControllerStatusKey"
    static var controllerStatus: ControllerType = {
        if let status = UserDocuments.userData.objectForKey(UserDocuments.CONTROLLER_STATUS_KEY) as? NSNumber{
            return ControllerType(rawValue: status.integerValue)!
        }
        else{
            return ControllerType(rawValue: 0)!
        }
    }()
    
    private static let BEST_RECORD_KEY = "BestRecordKey"
    static var bestRecord: NSTimeInterval = {
        if let record = UserDocuments.userData.objectForKey(UserDocuments.BEST_RECORD_KEY) as? NSNumber{
            return record.doubleValue
        }
        else{
            return 0.0
        }
    }()
    
    static func saveUserDocuments(){
        userData.setObject(NSNumber(bool: soundStatus), forKey: SOUND_STATUS_KEY)
        userData.setObject(NSNumber(integer: controllerStatus.rawValue), forKey: CONTROLLER_STATUS_KEY)
        userData.setObject(NSNumber(double: bestRecord), forKey: BEST_RECORD_KEY)
        userData.writeToFile(userDataFilePath, atomically: true)
    }
}