//
//  GameScene.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright (c) 2015年 赵涛. All rights reserved.
//

import SpriteKit
import GPUImage

import AudioToolbox
class GameScene: SKScene, PlayerControllerDelegate, SKPhysicsContactDelegate {
    
    static let hitRockActionKey = "hitRockAction"
    static let playerKickActionKey = "playerKickAction"
    static let turnCatActionKey = "turnCatAction"
    
    static let tinyMessageAction = SKAction.sequence([
        SKAction.moveByX(0, y: 100, duration: 0.5),
        SKAction.fadeOutWithDuration(0.2),
        SKAction.removeFromParent()])
    static let showInstructionAnim: SKAction = {
        let action = SKAction.sequence([
            SKAction.group([
                SKAction.moveByX(0, y: 300, duration: 1.5),
                SKAction.fadeOutWithDuration(1.5)]),
            SKAction.removeFromParent()])
        action.timingMode = .EaseIn
        return action
    }()
    static let showInstructionAnimRev: SKAction = {
        let action = SKAction.sequence([
            SKAction.group([
                SKAction.moveByX(0, y: -300, duration: 1.5),
                SKAction.fadeOutWithDuration(1.5)]),
            SKAction.removeFromParent()])
        action.timingMode = .EaseOut
        return action
    }()
    static let touchToStartAnim = SKAction.repeatActionForever(SKAction.sequence([
        SKAction.fadeOutWithDuration(0.8),
        SKAction.fadeInWithDuration(0.2)]))
    static let pauseBtnAnim = SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(-M_PI), duration: 10))
    static let restartBtnAnim = SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(2*M_PI), duration: 5))
    static let blurAnim = SKAction.group([
        SKAction.fadeInWithDuration(0.2),
        SKAction.scaleTo(1.1, duration: 0.2)])
    
    static var gameTransition = SKTransition.crossFadeWithDuration(0.3)
    
    static var GPUBlurFilter: GPUImageGaussianBlurFilter!
    
    var initialing = true
    var isGameOver = false
    //当前移动速度
    let moveSpeed: CGFloat = GameSpeed.PlayerDefaultSpeed.rawValue
    //游戏区域
    var playableArea = CGRectMake(0, 0, 0, 0)
    var backgroundNode: SKSpriteNode!
    //用户与敌人
    var player: Player!
    var enemyCage: SKNode!
    var enemyLayer: SKNode!
    var enemyGenerator: EnemyGenerator!
    var enemiesToAdjustDirection = [Enemy]()
    //游戏道具
    var gamePropsLayer: SKNode!
    var gamePropsGenerator: GamePropsGenerator!
    var gamePropsMap = [GamePropsType:GameProps]()//正在起作用的道具集合
    var gamePropsBanner: GamePropsBanner!//正在起作用的道具显示区域
    
    var playerPhantom: Player?//用户幻象
    var dogFoodArea: CGRect?//狗粮区域
    var shieldCount = 0//护盾次数
    var slowDownEnabled = false//减速光环效果
    //游戏内菜单
    var pauseButton: SKNode!
    var inGameMenu: SKSpriteNode!
    var gameOverMenu: SKNode!
    //时间标识
    var timeLabel: SKLabelNode!
    var timePassed: NSTimeInterval = 0
    var lastTimeStamp: NSTimeInterval = 0
    var deltaTime: NSTimeInterval = 0
    // 分钟奖励
    var turnCatEnabled = false//变猫效果
    var stopTimeEnabled = false//时间静止效果
    var nextMinute = 1
    let maxBonusTime: NSTimeInterval = 10
    var bonusTime: NSTimeInterval = 10
    
    /*   初始化   */
    override init(size: CGSize) {
        super.init(size: size)
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        initialing = true
        setupBackground()
        setupPlayableArea()
        setupEnemyCage()
        setupPlayer()
        setupEnemy()
        setupGameProps()
        setupInGameMenu()
        setupGameOverMenu()
        setupUI()
        initialing = false
        if GameViewController.firstLaunch{
            firstStart()
        }
    }
    
    func firstStart(){
        physicsWorld.speed = 0.0
        let touch2Start = SKLabelNode(fontNamed: "Arial-BoldMT")
        touch2Start.text = NSLocalizedString("touch2start", comment: "Touch to Start Game")
        touch2Start.fontSize = 60
        touch2Start.fontColor = SKColor.blackColor()
        touch2Start.name = "touch2start"
        touch2Start.position = CGPointMake(size.width/2, CGRectGetMaxY(playableArea)-250)
        touch2Start.zPosition = CGFloat(SceneZPosition.BackgroundZPosition.rawValue) + 1
        touch2Start.runAction(GameScene.touchToStartAnim)
        addChild(touch2Start)
    }
    
    private func setupBackground(){
//        backgroundColor = SKColorWithRGB(242, g: 244, b: 245)
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "bg"), size: size)
        background.position = CGPointMake(size.width/2, size.height/2)
        background.zPosition = CGFloat(SceneZPosition.BackgroundZPosition.rawValue)
        addChild(background)
    }
    
    private func setupEnemyCage(){
        enemyCage = SKNode()
        enemyCage.zPosition = CGFloat(SceneZPosition.EnemyCageZPosition.rawValue)
        enemyCage.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(CGRectGetMinX(playableArea)-EnemyGenerator.enemyDistance, CGRectGetMinY(playableArea)-EnemyGenerator.enemyDistance, playableArea.width+EnemyGenerator.enemyDistance*2, playableArea.height+EnemyGenerator.enemyDistance*2))
        enemyCage.physicsBody?.categoryBitMask = PhysicsCategory.EnemyCageEdge.rawValue
        addChild(enemyCage)
    }
    
    private func setupPlayableArea(){
        let sz = view!.frame.size
        // width: height = 4 : 3 ipad
        if sz.height / sz.width > 0.7{
            playableArea = CGRectMake(0, 0, size.width, size.height)
        }
            // width: height = 16 : 9 iphone5
            // or width: height = 3 : 2 iphone4s
        else{
            let maxAspectRatio: CGFloat = sz.width / sz.height
            let maxAspectHeight = size.width / maxAspectRatio
            let margin = (size.height - maxAspectHeight) / 2
            playableArea = CGRectMake(0, margin, size.width, maxAspectHeight)
        }
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableArea)
        physicsBody?.categoryBitMask = PhysicsCategory.Edge.rawValue
        physicsBody?.friction = 0
    }
    
    private func setupPlayer(){
        player = Player()
        player.position = CGPointMake(size.width/2, size.height/2)
        addChild(player)
        player.setupTail("playertail")
    }
    
    private func setupEnemy(){
        enemyLayer = SKNode()
        enemyLayer.zPosition = CGFloat(SceneZPosition.EnemyZPosition.rawValue)
        addChild(enemyLayer)
        enemyGenerator = EnemyGenerator(gameScene: self)
    }
    
    private func setupGameProps(){
        gamePropsLayer = SKNode()
        gamePropsLayer.zPosition = CGFloat(SceneZPosition.GamePropsZPosition.rawValue)
        addChild(gamePropsLayer)
        gamePropsBanner = GamePropsBanner(gameScene: self)
        gamePropsGenerator = GamePropsGenerator(gameScene: self)
    }
    
    private func setupInGameMenu(){
        inGameMenu = SKSpriteNode(texture: SKTexture(imageNamed: "set"), size: CGSizeMake(playableArea.size.width/1.5, playableArea.size.height/1.5))
        inGameMenu.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue)
        inGameMenu.position = CGPointMake(size.width/2, size.height/2)
        inGameMenu.hidden = true
        
        let soundSwitch = SKLabelNode()
        soundSwitch.fontSize = 70
        if UserDocuments.soundStatus{
            soundSwitch.fontName = "Arial Bold"
            soundSwitch.fontColor = SKColor.blackColor()
        }
        else{
            soundSwitch.fontName = "Arial"
            soundSwitch.fontColor = SKColor.whiteColor()
        }
        soundSwitch.name = "sound"
        soundSwitch.text = NSLocalizedString("soundText", comment: "Sound Menu Text")
        soundSwitch.position = CGPointMake(0, inGameMenu.size.height/4)
        soundSwitch.zPosition = inGameMenu.zPosition + 1
        inGameMenu.addChild(soundSwitch)
        
        let controllerSwitch = SKLabelNode(fontNamed: "Arial")
        controllerSwitch.fontSize = 70
        controllerSwitch.fontColor = SKColor.blackColor()
        controllerSwitch.name = "controller"
        controllerSwitch.text = NSLocalizedString("controllerText", comment: "Controller Menu Text")
        controllerSwitch.position = CGPointMake(0, 0)
        controllerSwitch.zPosition = inGameMenu.zPosition + 1
        inGameMenu.addChild(controllerSwitch)
        
        let onscreen = SKSpriteNode(texture: SKTexture(imageNamed: "onscreen"), size: CGSizeMake(inGameMenu.size.width/5, inGameMenu.size.width/5))
        let acceremo = SKSpriteNode(texture: SKTexture(imageNamed: "accelerometer"), size: onscreen.size)
        let arrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow"), size: CGSizeMake(inGameMenu.size.width/20, inGameMenu.size.height/6))
        onscreen.position = CGPointMake(-onscreen.size.width*3/2, -inGameMenu.size.height/4)
        onscreen.name = "onscreen"
        onscreen.zPosition = inGameMenu.zPosition + 1
        acceremo.position = CGPointMake(-onscreen.position.x, onscreen.position.y)
        acceremo.name = "accelerometer"
        acceremo.zPosition = inGameMenu.zPosition + 1
        if UserDocuments.controllerStatus == .Accelerometer{
            arrow.position = CGPointMake(acceremo.position.x, acceremo.position.y+acceremo.size.height/2+arrow.size.height/2)
            acceremo.xScale = 1.1
            acceremo.yScale = 1.1
        }
        else{
            arrow.position = CGPointMake(onscreen.position.x, onscreen.position.y+onscreen.size.height/2+arrow.size.height/2)
            onscreen.xScale = 1.1
            onscreen.yScale = 1.1
        }
        arrow.name = "arrow"
        arrow.zPosition = inGameMenu.zPosition + 1
        inGameMenu.addChild(onscreen)
        inGameMenu.addChild(acceremo)
        inGameMenu.addChild(arrow)
        
        addChild(inGameMenu)
    }
    
    func setupGameOverMenu(){
        gameOverMenu = SKNode()
        gameOverMenu.zPosition = CGFloat(SceneZPosition.BackgroundZPosition.rawValue) - 1
        
        let restart = SKSpriteNode(texture: SKTexture(imageNamed: "reload"), size: CGSizeMake(size.width/15, size.width/15))
        restart.name = "restart"
        restart.position = CGPointMake(size.width*3/4, size.height/3)
        gameOverMenu.addChild(restart)
        
        let share = SKSpriteNode(texture: SKTexture(imageNamed: "share"), size: CGSizeMake(size.width/15, size.width/15))
        share.name = "share"
        share.position = CGPointMake(size.width/4, size.height/3)
        gameOverMenu.addChild(share)
        
        let rating = SKSpriteNode(texture: SKTexture(imageNamed: "rating"), size: CGSizeMake(80, 80))
        rating.name = "leaderboard"
        rating.position = CGPointMake(CGRectGetMinX(playableArea)+rating.size.width/2+20, CGRectGetMaxY(playableArea)-rating.size.width/2-20)
        gameOverMenu.addChild(rating)
        
        let score = SKLabelNode(fontNamed: "Levenim MT")
        score.name = "score"
        score.fontColor = SKColorWithRGB(142, g: 63, b: 63)
        score.fontSize = 180
        score.verticalAlignmentMode = .Bottom
        score.position = CGPointMake(size.width/2, size.height*2/3)
        gameOverMenu.addChild(score)
        
        let bestScore = SKLabelNode(fontNamed: "Levenim MT")
        bestScore.name = "bestScore"
        bestScore.fontColor = SKColorWithRGB(142, g: 63, b: 63)
        bestScore.fontSize = 70
        bestScore.position = CGPointMake(size.width/2, score.position.y-100)
        bestScore.verticalAlignmentMode = .Bottom
        gameOverMenu.addChild(bestScore)
        addChild(gameOverMenu)
    }
    
    func setupUI(){
        timeLabel = SKLabelNode(fontNamed: "Arial")
        timeLabel.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue)
        timeLabel.position = CGPointMake(CGRectGetMidX(playableArea)-60, CGRectGetMaxY(playableArea)-70)
        timeLabel.fontColor = SKColor.blackColor()
        timeLabel.fontSize = 50
        timeLabel.horizontalAlignmentMode = .Left
        timeLabel.verticalAlignmentMode = .Center
        timeLabel.text = "00.0"
        addChild(timeLabel)
        
        let pauseBtn = SKSpriteNode(texture: SKTexture(imageNamed: "settings"), size: CGSizeMake(80, 80))
        pauseBtn.position = CGPointMake(CGRectGetMinX(playableArea)+pauseBtn.size.width/2+20, CGRectGetMaxY(playableArea)-pauseBtn.size.width/2-20)
        pauseBtn.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue)
        pauseButton = pauseBtn
        pauseBtn.runAction(GameScene.pauseBtnAnim)
        addChild(pauseBtn)
    }
    
    /*    碰撞检测事件处理    */
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch collision{
            //普通敌人 回笼
        case PhysicsCategory.Cat.rawValue | PhysicsCategory.EnemyCageEdge.rawValue:
            let catBody = contact.bodyA.categoryBitMask == PhysicsCategory.Cat.rawValue ? contact.bodyA : contact.bodyB
            if let cat = catBody.node as? Enemy{
                cat.moveToward((randomPointInRect(player.fireRect)-cat.position).normalized()*CGFloat(GameSpeed.CatSpeed.rawValue))
                enemiesToAdjustDirection.append(cat)
            }
        case PhysicsCategory.EnemyNormal.rawValue | PhysicsCategory.EnemyCageEdge.rawValue:
            let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.EnemyNormal.rawValue ? contact.bodyA : contact.bodyB
            if let enemy = enemyBody.node as? EnemyNormal{
                if let phantom = playerPhantom{
                    enemy.moveToward((randomPointInRect(phantom.fireRect)-enemy.position).normalized()*enemy.moveSpeed)
                }
                else{
                    enemy.moveToward((randomPointInRect(player.fireRect)-enemy.position).normalized()*enemy.moveSpeed)
                }
                enemiesToAdjustDirection.append(enemy)
            }
        case PhysicsCategory.EnemyFast.rawValue | PhysicsCategory.EnemyCageEdge.rawValue:
            let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.EnemyFast.rawValue ? contact.bodyA : contact.bodyB
            if let enemy = enemyBody.node as? EnemyFast{
                enemy.removeFromParent()
            }
            //敌人与用户接触，游戏结束
        case PhysicsCategory.EnemyNormal.rawValue | PhysicsCategory.Player.rawValue:
            fallthrough
        case PhysicsCategory.EnemySlow.rawValue | PhysicsCategory.Player.rawValue:
            fallthrough
        case PhysicsCategory.EnemyFast.rawValue | PhysicsCategory.Player.rawValue:
            let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.Player.rawValue ? contact.bodyB : contact.bodyA
            if enemyBody.node?.actionForKey(GameScene.playerKickActionKey) != nil || enemyBody.node?.actionForKey(GameScene.hitRockActionKey) != nil || stopTimeEnabled{
                break
            }
            else if shieldCount > 0{
                if UserDocuments.soundStatus{
                    AudioServicesPlaySystemSound(Resources.kickSound)
                }
                shieldCount--
                if let shield = player.childNodeWithName("shield") as? SKSpriteNode{
                    shield.alpha /= 2
                }
                if let enemy = enemyBody.node as? Enemy{
                    let nextVelocity = (enemyBody.node!.position-player.position).normalized()*enemy.moveSpeed
                    enemy.currentSpeed = 0
                    enemy.runAction(SKAction.sequence([
                        SKAction.group([
                            SKAction.moveBy(CGVector(point: nextVelocity.normalized()*400), duration: 1),
                            SKAction.rotateByAngle(CGFloat(M_PI*4.0), duration: 1)]),
                        SKAction.runBlock({ () -> Void in
                            if enemy.actionForKey(GameScene.hitRockActionKey) == nil{
                                enemy.moveToward(nextVelocity)
                                enemy.faceCurrentDirection()
                            }
                        })]), withKey: GameScene.playerKickActionKey)
                }
                if shieldCount <= 0{
                    gamePropsGenerator.disableEffect(.WhosYourDaddy)
                }
                else{
                    showTinyMessage(player.position, text: String(format: NSLocalizedString("shieldRemaining", comment: "Shield Remaining Text"), shieldCount), color: SKColor.blackColor())
                }
            }
            else{
                handleGameOver()
            }
            //用户拾得道具 增加特殊效果
        case PhysicsCategory.GameProps.rawValue | PhysicsCategory.Player.rawValue:
            let gamePropsBody = contact.bodyA.categoryBitMask == PhysicsCategory.GameProps.rawValue ? contact.bodyA : contact.bodyB
            if let gameProps = gamePropsBody.node as? GameProps{
                gamePropsGenerator.handleGamePropsEffect(gameProps)
            }
            //石头接触猫，增加额外时间
        case PhysicsCategory.Cat.rawValue | PhysicsCategory.Rock.rawValue:
            fallthrough
            //用户接触猫，增加额外时间
        case PhysicsCategory.Cat.rawValue | PhysicsCategory.Player.rawValue:
            if UserDocuments.soundStatus{
                AudioServicesPlaySystemSound(Resources.coinSound)
            }
            var catBody: SKPhysicsBody!
            var otherBody: SKPhysicsBody!
            if contact.bodyA.categoryBitMask == PhysicsCategory.Cat.rawValue{
                catBody = contact.bodyA
                otherBody = contact.bodyB
            }
            else{
                catBody = contact.bodyB
                otherBody = contact.bodyA
            }
            if let cat = catBody.node{
                showTinyMessage(cat.position, text: "+0.1s", color: SKColor.goldColor())
                cat.removeAllActions()
                cat.removeFromParent()
            }
            if let normalEnemy = catBody.node as? EnemyNormal{
                if let index = enemyGenerator.normalEnemies.indexOf(normalEnemy){
                    enemyGenerator.normalEnemies.removeAtIndex(index)
                }
            }
            else if let slowEnemy = catBody.node as? EnemySlow{
                if let index = enemyGenerator.slowEnemies.indexOf(slowEnemy){
                    enemyGenerator.slowEnemies.removeAtIndex(index)
                }
            }
            timePassed += 0.1
            if otherBody.categoryBitMask == PhysicsCategory.Rock.rawValue{
                otherBody.node?.removeFromParent()
            }
            //石头接触笼子，移除石头
        case PhysicsCategory.Rock.rawValue | PhysicsCategory.EnemyCageEdge.rawValue:
            let rockBody = contact.bodyA.categoryBitMask == PhysicsCategory.Rock.rawValue ? contact.bodyA : contact.bodyB
            rockBody.node?.removeFromParent()
            //石头接触敌人，敌人眩晕
        case PhysicsCategory.Rock.rawValue | PhysicsCategory.EnemySlow.rawValue:
            fallthrough
        case PhysicsCategory.Rock.rawValue | PhysicsCategory.EnemyNormal.rawValue:
            fallthrough
        case PhysicsCategory.Rock.rawValue | PhysicsCategory.EnemyFast.rawValue:
            if UserDocuments.soundStatus{
                AudioServicesPlaySystemSound(Resources.hitSound)
            }
            var rockBody: SKPhysicsBody!
            var enemyBody: SKPhysicsBody!
            if contact.bodyA.categoryBitMask == PhysicsCategory.Rock.rawValue{
                rockBody = contact.bodyA
                enemyBody = contact.bodyB
            }
            else{
                rockBody = contact.bodyB
                enemyBody = contact.bodyA
            }
            rockBody.node?.removeFromParent()
            if enemyBody.node?.actionForKey(GameScene.hitRockActionKey) == nil{
                let dizzy = SKEmitterNode(fileNamed: "dizzy")!
                if let enem = enemyBody.node as? Enemy{
                    enem.currentSpeed = 0
                    enem.sprite.removeActionForKey(Enemy.runningActionKey)
                    dizzy.position = CGPointMake(enem.sprite.texture!.size().width/5, 0)
                    dizzy.name = "dizzy"
                    enem.addChild(dizzy)
                }
                enemyBody.node?.runAction(SKAction.sequence([
                    SKAction.waitForDuration(2),
                    SKAction.runBlock({ () -> Void in
                        if let enemy = enemyBody.node as? Enemy{
                            dizzy.removeFromParent()
                            if !self.stopTimeEnabled{
                                enemy.sprite.runAction(Enemy.runningAnim, withKey: Enemy.runningActionKey)
                                enemy.currentSpeed = enemy.moveSpeed
                            }
                        }
                    })]), withKey: GameScene.hitRockActionKey)
            }
        default:
            break
        }
    }
    
    func showTinyMessage(position: CGPoint, text: String, color: SKColor){
        let tinyMessage = SKLabelNode(fontNamed: "Arial")
        tinyMessage.fontColor = color
        tinyMessage.fontSize = 50
        tinyMessage.text = text
        tinyMessage.position = position
        tinyMessage.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue) - 2
        addChild(tinyMessage)
        tinyMessage.runAction(GameScene.tinyMessageAction)
    }
    
    /*    用户手势处理    */
    let maxStoredPoint = 30
    var previousPoints = [CGPoint]()
    //拖动手势 触摸屏幕控制
    func handlePanGesture(sender: UIPanGestureRecognizer){
        if !isGameOver{
            var v = sender.velocityInView(view)
            v.y *= -1
            if sender.state == .Began{
                previousPoints.append(v)
            }
            else if sender.state == .Changed{
                previousPoints.append(v)
                if previousPoints.count > 1 && previousPoints.count <= maxStoredPoint{
                    let prev = previousPoints.first!
                    var avg = CGPointZero
                    for index in 1 ..< previousPoints.count{
                        let point = previousPoints[index]
                        avg.x += point.x * CGFloat(previousPoints.count-index)
                        avg.y += point.y * CGFloat(previousPoints.count-index)
                    }
                    avg.x /= CGFloat(previousPoints.count-1)
                    avg.y /= CGFloat(previousPoints.count-1)
                    player.moveToward((avg-prev).normalized() * moveSpeed)
                }
                else if previousPoints.count > maxStoredPoint{
                    let prev = previousPoints.removeFirst()
                    var avg = CGPointZero
                    for index in 0 ..< previousPoints.count{
                        let point = previousPoints[index]
                        avg.x += point.x * CGFloat(previousPoints.count-index)
                        avg.y += point.y * CGFloat(previousPoints.count-index)
                    }
                    avg.x /= CGFloat(previousPoints.count)
                    avg.y /= CGFloat(previousPoints.count)
                    player.moveToward((avg-prev).normalized() * moveSpeed)
                }
            }
            else if sender.state == .Ended{
                previousPoints.removeAll()
                player.moveToward(CGPointZero)
            }
        }
    }
    
    /*   点击事件处理   */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let atouch = touches.first
        if let touch = atouch{
            let touchPos = touch.locationInNode(self)
            if !paused{
                if !pauseButton.hidden{
                    if (touchPos-pauseButton.position).length() < 100{
                        playButtonPress()
                        pauseGame()
                    }
                }
                //游戏结束菜单
                else if !gameOverMenu.hidden{
                    //重新开始
                    let restart = gameOverMenu.childNodeWithName("restart")
                    if (touchPos-restart!.position).length() < 100{
                        playButtonPress()
                        restartGame()
                    }
                    //分享
                    let share = gameOverMenu.childNodeWithName("share")
                    if (touchPos-share!.position).length() < 100{
                        playButtonPress()
                        popOverShare()
                    }
                    //排行榜
                    let leader = gameOverMenu.childNodeWithName("leaderboard")
                    if (touchPos-leader!.position).length() < 100{
                        playButtonPress()
                        ABGameKitHelper.sharedHelper().showLeaderboard(GameCenter.BestTimeLeaderBoardID.rawValue)
                    }
                }
            }
            else{
                //游戏内菜单
                if !inGameMenu.hidden{
                    if !inGameMenu.containsPoint(touchPos){
                        playButtonPress()
                        resumeGame()
                    }
                    else{
                        let inGamePos = touch.locationInNode(inGameMenu)
                        //切换音效
                        let sound = inGameMenu.childNodeWithName("sound") as! SKLabelNode
                        if sound.containsPoint(inGamePos){
                            UserDocuments.soundStatus = !UserDocuments.soundStatus
                            playButtonPress()
                            if UserDocuments.soundStatus{
                                sound.fontName = "Arial Bold"
                                sound.fontColor = SKColor.blackColor()
                            }
                            else{
                                sound.fontName = "Arial"
                                sound.fontColor = SKColor.whiteColor()
                            }
                        }
                        //切换控制
                        let arrow = inGameMenu.childNodeWithName("arrow")!
                        let onscreen = inGameMenu.childNodeWithName("onscreen")!
                        let accelerometer = inGameMenu.childNodeWithName("accelerometer")!
                        if (onscreen.containsPoint(inGamePos) && UserDocuments.controllerStatus != .OnScreen) || (accelerometer.containsPoint(inGamePos) && UserDocuments.controllerStatus != .Accelerometer){
                            playButtonPress()
                            if UserDocuments.controllerStatus == .OnScreen{
                                if !Resources.accelerometerAvailable{
                                    showAlert()
                                    return
                                }
                                UserDocuments.controllerStatus = .Accelerometer
                                onscreen.xScale = 1.0
                                onscreen.yScale = 1.0
                                accelerometer.xScale = 1.1
                                accelerometer.yScale = 1.1
                                arrow.position = CGPointMake(accelerometer.position.x, arrow.position.y)
                            }
                            else{
                                UserDocuments.controllerStatus = .OnScreen
                                accelerometer.xScale = 1.0
                                accelerometer.yScale = 1.0
                                onscreen.xScale = 1.1
                                onscreen.yScale = 1.1
                                arrow.position = CGPointMake(onscreen.position.x, arrow.position.y)
                            }
                            NSNotificationCenter.defaultCenter().postNotificationName(UserDocuments.ControllerStatusChangedNotification, object: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func showAlert(){
        let alert = UIAlertController(title: NSLocalizedString("error", comment: "Error Text"), message: NSLocalizedString("noAccelerometer", comment: "No Accelerometer Text"), preferredStyle: .Alert)
        let cancleAction = UIAlertAction(title: NSLocalizedString("ok", comment: "OK Text"), style: .Cancel, handler: nil)
        alert.addAction(cancleAction)
        view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func playButtonPress(){
        if UserDocuments.soundStatus{
            AudioServicesPlaySystemSound(Resources.buttonSound)
        }
    }
    
    func popOverShare(){
        let shareContent = [
            NSString(format: NSLocalizedString("shareText", comment: "Share Text"), timePassed),
            convertViewToImage(CGRectMake(-GameViewController.ADPadding, 0, view!.bounds.size.width-2*GameViewController.ADPadding, view!.bounds.size.height-GameViewController.ADHeight))
            ]
        let activityVC = UIActivityViewController(activityItems: shareContent, applicationActivities: Resources.activities)
        activityVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad{
            activityVC.modalPresentationStyle = .Popover
            activityVC.popoverPresentationController?.sourceView = view
            activityVC.popoverPresentationController?.sourceRect = CGRectMake(view!.frame.size.width/2, view!.frame.size.height/2, 10, 10)
            activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        view?.window?.rootViewController?.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func convertViewToImage(area: CGRect) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(area.size, false, 0.0)
        view!.drawViewHierarchyInRect(area, afterScreenUpdates: false)
        let original = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return original
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if GameViewController.firstLaunch{
            physicsWorld.speed = 1.0
            childNodeWithName("touch2start")?.removeFromParent()
            GameViewController.firstLaunch = false
        }
    }
    
    /*   主刷新循环   */
    override func update(currentTime: NSTimeInterval) {
        //首次启动游戏，暂停循环
        if GameViewController.firstLaunch{
            return
        }
        //从后台唤醒，暂停循环
        if !inGameMenu.hidden && !paused{
            lastTimeStamp = 0.0
            paused = true
        }
        //scene暂停或游戏结束，暂停循环
        if paused || isGameOver{
            return
        }
        if !turnCatEnabled{
            if lastTimeStamp == 0.0{
                lastTimeStamp = currentTime
            }
            else{
                deltaTime = currentTime - lastTimeStamp
                lastTimeStamp = currentTime
            }
            timePassed += deltaTime
            let minute = Int(timePassed/60)
            timeLabel.text = minute > 0 ? (NSString(format: "%0.2d:%04.1f", minute, timePassed % 60) as String) : (NSString(format: "%04.1f", timePassed) as String)
            if timePassed > UserDocuments.bestRecord && timeLabel.fontColor != SKColor.redColor(){
                timeLabel.fontColor = SKColor.redColor()
            }
            
            if Int(timePassed/30) == nextMinute{
                addTurnCatEffect()
            }
        }
    }
    
    func addTurnCatEffect(){
        //开启变猫效果
        bonusTime = maxBonusTime
        turnCatEnabled = true
        nextMinute++
        lastTimeStamp = 0.0
//        backgroundNode.runAction(SKAction.fadeAlphaTo(0.2, duration: 1))
        //取消道具效果
        for type in gamePropsMap.keys{
            gamePropsGenerator.disableEffect(type)
        }
        for node in gamePropsLayer.children{
            node.removeFromParent()
        }
        gamePropsBanner.queue.removeAll()
        //时间静止
        stopTimeEnabled = true
        for enemyNode in enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                enemy.turnCat(true)
                enemy.sprite.removeActionForKey(Enemy.runningActionKey)
                enemy.removeActionForKey(GameScene.playerKickActionKey)
                enemy.removeActionForKey(GameScene.hitRockActionKey)
                enemy.childNodeWithName("dizzy")?.removeFromParent()
            }
        }
        //开启倒计时
        timeLabel.text = NSString(format: "%04.1f", bonusTime) as String
        let originColor = timeLabel.fontColor
        timeLabel.fontColor = SKColor.goldColor()
        //弹出提示
        let instructionLabel = SKLabelNode(fontNamed: "Arial")
        instructionLabel.fontSize = 80
        instructionLabel.fontColor = SKColor.redColor()
        instructionLabel.text = NSLocalizedString("eatThem", comment: "Eat Them Text")
        instructionLabel.position = CGPointMake(CGRectGetMidX(playableArea), CGRectGetMidY(playableArea))
        instructionLabel.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue) - 2
        addChild(instructionLabel)
        
        instructionLabel.runAction(GameScene.showInstructionAnim){
                //取消时间静止
                if UserDocuments.soundStatus{
//                    self.runAction(GameScene.tickTockAnim, withKey: GameScene.tickTockActionKey)
                    Resources.ticktockSound.play()
                }
                self.stopTimeEnabled = false
                for enemyNode in self.enemyLayer.children{
                    if let enemy = enemyNode as? Enemy{
                        enemy.sprite.runAction(Enemy.runningAnim, withKey: Enemy.runningActionKey)
                        enemy.currentSpeed = CGFloat(GameSpeed.CatSpeed.rawValue)
                    }
                }
                self.runAction(SKAction.repeatActionForever(SKAction.sequence([
                    SKAction.waitForDuration(0.1),
                    SKAction.runBlock({ () -> Void in
                        self.bonusTime -= 0.1
                        self.timeLabel.text = NSString(format: "%04.1f", self.bonusTime) as String
                        switch self.bonusTime{
                        case 4 ... 10:
                            self.timeLabel.fontColor = SKColor.goldColor()
                        case 0 ... 3:
                            self.timeLabel.fontColor = SKColor.redColor()
                        default:
                            break
                        }
                        if self.bonusTime < 0{
                            self.timeLabel.text = "0.00"
                            self.removeActionForKey(GameScene.turnCatActionKey)
//                            self.removeActionForKey(GameScene.tickTockActionKey)
                            Resources.ticktockSound.stop()
                            //时间静止
                            self.stopTimeEnabled = true
                            for enemyNode in self.enemyLayer.children{
                                if let enemy = enemyNode as? Enemy{
                                    enemy.resumeFromCat()
                                    enemy.sprite.removeActionForKey(Enemy.runningActionKey)
                                    enemy.currentSpeed = 0
                                }
                            }
                            instructionLabel.alpha = 1
                            instructionLabel.text = NSLocalizedString("bonusTimeUp", comment: "Bonus Time Up Text")
                            self.addChild(instructionLabel)
                            instructionLabel.runAction(GameScene.showInstructionAnimRev){
                                //取消变猫效果
                                self.turnCatEnabled = false
                                self.timeLabel.fontColor = originColor
                                //取消时间静止
                                self.stopTimeEnabled = false
                                for enemyNode in self.enemyLayer.children{
                                    if let enemy = enemyNode as? Enemy{
                                        if enemy.actionForKey(GameScene.hitRockActionKey) == nil{
                                            enemy.currentSpeed = enemy.moveSpeed
                                            enemy.sprite.runAction(Enemy.runningAnim, withKey: Enemy.runningActionKey)
                                        }
                                    }
                                }
                            }
                        }
                    })])), withKey: GameScene.turnCatActionKey)
        }
    }
    
    //调整敌人朝向与速度
    override func didSimulatePhysics() {
        if isGameOver{
            return
        }
        if !stopTimeEnabled{
            //所有狗都朝向狗粮
            if dogFoodArea != nil && !turnCatEnabled{
                var dogIn = false
                for enemyNode in enemyLayer.children{
                    if enemyNode.actionForKey(GameScene.hitRockActionKey) == nil && enemyNode.actionForKey(GameScene.playerKickActionKey) == nil{
                        if let enemy = enemyNode as? Enemy{
                            enemy.moveToward((randomPointInRect(dogFoodArea!)-enemy.position).normalized()*enemy.moveSpeed)
                            enemy.faceCurrentDirection()
                        }
                    }
                    if dogFoodArea!.contains(enemyNode.position){
                        dogIn = true
                    }
                }
                let dust = gamePropsLayer.childNodeWithName("dust")
                if dogIn && dust?.actionForKey(GamePropsGenerator.dustInActionKey) == nil{
                    dust?.runAction(GamePropsGenerator.dustInAnim, withKey: GamePropsGenerator.dustInActionKey)
                }
            }
            else{
                //普通敌人调整朝向
                for enemy in enemiesToAdjustDirection{
                    enemy.faceCurrentDirection()
                }
                //慢速敌人始终朝向player
                for enemy in enemyGenerator.slowEnemies{
                    if enemy.actionForKey(GameScene.hitRockActionKey) == nil && enemy.actionForKey(GameScene.playerKickActionKey) == nil{
                        var speed = enemy.moveSpeed
                        if enemy.physicsBody?.categoryBitMask == PhysicsCategory.Cat.rawValue{
                            speed = CGFloat(GameSpeed.CatSpeed.rawValue)
                        }
                        //变猫时不追逐幻象
                        if playerPhantom != nil && enemy.physicsBody?.categoryBitMask != PhysicsCategory.Cat.rawValue{
                            enemy.physicsBody?.velocity = CGVector(point: (playerPhantom!.position-enemy.position).normalized()*speed)
                        }
                        else{
                            enemy.physicsBody?.velocity = CGVector(point: (player.position-enemy.position).normalized()*speed)
                        }
                        enemy.faceCurrentDirection()
                    }
                }
            }
            enemiesToAdjustDirection.removeAll()
            if slowDownEnabled && !turnCatEnabled{
                for enemyNode in enemyLayer.children{
                    if let enemy = enemyNode as? Enemy{
                        if (enemy.position-player.position).length() <= gamePropsGenerator.slowDownRadius{
                            enemy.purge()
                        }
                        else{
                            enemy.resumeFromPurge()
                        }
                    }
                }
            }
        }
        else{
            for enemy in enemiesToAdjustDirection{
                enemy.currentSpeed = 0
            }
        }
    }
    
    /*    处理游戏事件    */
    func handleGameOver(){
        isGameOver = true
        physicsWorld.speed = 0.0
        player.death()
        removeAllActions()
        for prop in gamePropsLayer.children{
            prop.removeAllActions()
        }
        for enemyNode in self.enemyLayer.children{
            if let enemy = enemyNode as? Enemy{
                enemy.sprite.removeAllActions()
            }
        }
        pauseButton.hidden = true
        timeLabel.hidden = true
        runAction(SKAction.group([
            SKAction.waitForDuration(0.02),
            SKAction.runBlock({ () -> Void in
                self.player.mainSprite.texture = self.player.deadTexture
            })])){
                //模糊效果
                let blurNode = self.createBlurScreen()
                blurNode.position = CGPointMake(self.size.width/2, self.size.height/2)
                blurNode.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue) - 1
                self.addChild(blurNode)
                blurNode.runAction(GameScene.blurAnim){
                    self.gameOverMenu.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue)
                    if let score = self.gameOverMenu.childNodeWithName("score") as? SKLabelNode{
                        score.text = NSString(format: "%3.1fs", self.timePassed) as String
                    }
                    self.gameOverMenu.childNodeWithName("restart")?.runAction(GameScene.restartBtnAnim)
                    if self.timePassed > UserDocuments.bestRecord{
                        UserDocuments.bestRecord = self.timePassed
                        ABGameKitHelper.sharedHelper().reportScore(UInt(self.timePassed*10), forLeaderboard: GameCenter.BestTimeLeaderBoardID.rawValue)
                    }
                    if let bestScore = self.gameOverMenu.childNodeWithName("bestScore") as? SKLabelNode{
                        bestScore.text = NSLocalizedString("bestScore", comment: "Best Score Text") + (NSString(format: "%3.1fs", UserDocuments.bestRecord) as String)
                    }
                    if let gvc = self.view?.window?.rootViewController as? GameViewController{
                        gvc.layoutAdBanner()
                    }
                }

        }
}
    
    func createBlurScreen() -> SKSpriteNode{
        let screenshot = convertViewToImage(view!.bounds)
        let picture = GPUImagePicture(image: screenshot)
        picture.addTarget(GameScene.GPUBlurFilter)
        GameScene.GPUBlurFilter.useNextFrameForImageCapture()
        picture.processImage()
        let output = GameScene.GPUBlurFilter.imageFromCurrentFramebuffer()
        let blurNode = SKSpriteNode(texture: SKTexture(image: output), size: playableArea.size)
        return blurNode
    }
    
    func resumeGame(){
        if !isGameOver{
            inGameMenu.hidden = true
            pauseButton.hidden = false
            paused = false
            if let accelerometerController = (view as? GameView)?.controller as? AccelerometerController{
                accelerometerController.start()
            }
            if UserDocuments.soundStatus{
                if turnCatEnabled && !stopTimeEnabled{
                    Resources.ticktockSound.play()
                }
            }
        }
    }
    
    func pauseGame(){
        if !isGameOver{
            paused = true
            inGameMenu.hidden = false
            pauseButton.hidden = true
            lastTimeStamp = 0.0
            if let accelerometerController = (view as? GameView)?.controller as? AccelerometerController{
                accelerometerController.stop()
            }
            player.moveToward(CGPointZero)
            Resources.ticktockSound.stop()
        }
    }
    
    func restartGame(){
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        let gameView = view as! GameView
        gameView.changeControllerTarget(scene)
        gameView.presentScene(scene, transition: GameScene.gameTransition)
        removeAllActions()
        removeAllChildren()
        if let gvc = view?.window?.rootViewController as? GameViewController{
            gvc.hideAdBanner()
        }
    }
    
    /*   PlayerControllerDelegate   */
    func moveByDirection(direction: CGPoint) {
        if !initialing && !isGameOver && !GameViewController.firstLaunch && !paused{
            player.moveToward(direction*moveSpeed)
        }
    }
}
