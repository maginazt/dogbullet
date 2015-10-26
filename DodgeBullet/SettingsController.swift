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
        musicSwitch.on = Config.musicStatus
        soundSwitch.on = Config.soundStatus
        controllerSegment.selectedSegmentIndex = Config.controllerStatus.rawValue
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        if Config.soundStatus{
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
        Config.musicStatus = status
    }
    
    @IBAction func changeSoundState(sender: UISwitch) {
        Config.soundStatus = sender.on
    }
    
    @IBAction func changeControllerState(sender: UISegmentedControl) {
        Config.controllerStatus = ControllerType(rawValue: sender.selectedSegmentIndex)!
    }
    
}