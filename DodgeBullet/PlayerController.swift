//
//  PlayerController.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import CoreGraphics

protocol PlayerControllerDelegate{
    func moveByDirection(direction: CGPoint)
}

protocol PlayerController{
    var delegate: PlayerControllerDelegate? {get set}
}