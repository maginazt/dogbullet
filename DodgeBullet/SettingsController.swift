//
//  SettingsController.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/17.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import UIKit
class SettingsController: UIViewController {
    
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var controllerSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicSwitch.on = UserDocuments.musicStatus
        soundSwitch.on = UserDocuments.soundStatus
        controllerSegment.selectedSegmentIndex = UserDocuments.controllerStatus.rawValue
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        if UserDocuments.soundStatus{
            SKTAudio.sharedInstance().playSoundEffect("button_press.wav")
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func changeMusicState(sender: UISwitch) {
        let status = sender.on
        if status{
            SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
        }
        else{
            SKTAudio.sharedInstance().pauseBackgroundMusic()
        }
        UserDocuments.musicStatus = status
    }
    
    @IBAction func changeSoundState(sender: UISwitch) {
        UserDocuments.soundStatus = sender.on
    }
    
    @IBAction func changeControllerState(sender: UISegmentedControl) {
        UserDocuments.controllerStatus = ControllerType(rawValue: sender.selectedSegmentIndex)!
        NSNotificationCenter.defaultCenter().postNotificationName(UserDocuments.ControllerStatusChangedNotification, object: nil)
    }
    
}