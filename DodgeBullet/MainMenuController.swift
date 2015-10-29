//
//  MainMenu.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/15.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import UIKit
class MainMenuController: UIViewController {
    override func viewDidLoad() {
        if UserDocuments.musicStatus{
            SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
        }
    }
    
    @IBAction func startGameButtonPressed(sender: UIButton) {
        if UserDocuments.soundStatus{
            SKTAudio.sharedInstance().playSoundEffect("button_press.wav")
        }
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("GameViewController"){
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        if UserDocuments.soundStatus{
            SKTAudio.sharedInstance().playSoundEffect("button_press.wav")
        }
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("SettingsController"){
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}