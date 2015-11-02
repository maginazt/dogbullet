//
//  Types.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import CoreGraphics
enum PhysicsCategory: UInt32{
    case None = 0
    case Edge = 1
    case Player = 2
    case EnemyCageEdge = 4
    case EnemyNormal = 8
    case EnemySlow = 16
    case EnemyFast = 32
    case GameProps = 64
    case Cat = 128
    case Rock = 256
}

enum SceneZPosition: Int{
    case EnemyCageZPosition = -100
    case GamePropsZPosition = 50
    case EnemyZPosition = 80
    case PlayerZPosition = 100
    case GameMenuZPosition = 200
}

//控制方式
enum ControllerType: Int{
    case JoystickRight //右手摇杆
    case JoystickLeft //左手摇杆
    case Accelerometer //加速计
}

enum PreferenceErrorType: ErrorType{
    case NotExist
}

//移动速度
enum GameSpeed: CGFloat{
    case EnemyNormalSpeed = 250
    case EnemySlowSpeed = 150
    case EnemyFastSpeed = 750
    case PlayerMinSpeed = 180
    case PlayerMaxSpeed = 540
    case PlayerDefaultSpeed = 300
    case CatSpeed = 400
    case RockSpeed = 600
}

//游戏道具
enum GamePropsType: Int{
    case SpeedUp = 0 //加速
    case ScaleDown //缩小
    case Phantom //幻象
    case StopTime //时间静止
    case TurnCats //变猫
    case DogFood //狗粮
    case Rock //石头 晕眩
    case WhosYourDaddy //无敌
    case SlowDown //减速光环
    case Maximum
}