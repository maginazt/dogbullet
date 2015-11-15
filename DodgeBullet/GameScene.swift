//
//  GameScene.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright (c) 2015年 赵涛. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, PlayerControllerDelegate, SKPhysicsContactDelegate {
    
    static let hitRockActionKey = "hitRockAction"
    static let playerKickActionKey = "playerKickAction"
    static let turnCatActionKey = "TurnCatAction"
    
    static let bonusTimeAction = SKAction.sequence([
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
    static let showTimeAnim: SKAction = {
        let action = SKAction.group([
            SKAction.moveByX(0, y: -200, duration: 1),
            SKAction.scaleTo(2, duration: 1)])
        action.timingMode = .EaseOut
        return action
    }()
    
    static let flipTransition = SKTransition.flipVerticalWithDuration(0.3)
    
    var initialing = true
    var isGameOver = false
    //当前移动速度
    let moveSpeed: CGFloat = GameSpeed.PlayerDefaultSpeed.rawValue
    //游戏区域
    var playableArea = CGRectMake(0, 0, 0, 0)
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
    var inGameMenu: SKNode!
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
    }
    
    private func setupBackground(){
//        backgroundColor = SKColorWithRGB(242, g: 244, b: 245)
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "bg"), color: SKColor.whiteColor(), size: size)
        background.alpha = 0.9
        background.zPosition = CGFloat(SceneZPosition.EnemyCageZPosition.rawValue) - 1
        background.position = CGPointMake(size.width/2, size.height/2)
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
        if let sz = view?.frame.size{
            // width: height = 16 : 9 iphone5
            if sz.height / sz.width < 0.65{
                let maxAspectRatio: CGFloat = 16.0 / 9.0
                let maxAspectHeight = size.width / maxAspectRatio
                let margin = (size.height - maxAspectHeight) / 2
                playableArea = CGRectMake(0, margin, size.width, maxAspectHeight)
            }
            // width: height = 4 : 3 ipad
            else{
                playableArea = CGRectMake(0, 0, size.width, size.height)
            }
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
        inGameMenu = SKNode()
        inGameMenu.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue)
        inGameMenu.hidden = true
        let resume = SKLabelNode(fontNamed: "Chalkduster")
        resume.fontColor = SKColor.orangeColor()
        resume.fontSize = 70
        resume.text = "Resume Game"
        resume.name = "resume"
        resume.position = CGPointMake(size.width/2, size.height/2+200)
        inGameMenu.addChild(resume)
        
        let settings = SKLabelNode(fontNamed: "Chalkduster")
        settings.fontColor = SKColor.blueColor()
        settings.fontSize = 70
        settings.text = "Settings"
        settings.name = "settings"
        settings.position = CGPointMake(size.width/2, size.height/2)
        inGameMenu.addChild(settings)
        
        let restart = SKLabelNode(fontNamed: "Chalkduster")
        restart.name = "restart"
        restart.fontColor = SKColor.blueColor()
        restart.fontSize = 70
        restart.position = CGPointMake(size.width/2-250, size.height/2-200)
        restart.text = "Restart"
        inGameMenu.addChild(restart)
        
        let mainMenu = SKLabelNode(fontNamed: "Chalkduster")
        mainMenu.fontColor = SKColor.blueColor()
        mainMenu.fontSize = 70
        mainMenu.text = "Main Menu"
        mainMenu.name = "mainMenu"
        mainMenu.position = CGPointMake(size.width/2+250, size.height/2-200)
        inGameMenu.addChild(mainMenu)
        addChild(inGameMenu)
    }
    
    func setupGameOverMenu(){
        gameOverMenu = SKNode()
        gameOverMenu.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue)
        gameOverMenu.hidden = true
        
        let restart = SKLabelNode(fontNamed: "Chalkduster")
        restart.name = "restart"
        restart.fontColor = SKColor.blueColor()
        restart.fontSize = 70
        restart.position = CGPointMake(size.width/2-250, size.height/2-50)
        restart.text = "Restart"
        gameOverMenu.addChild(restart)
        
        let mainMenu = SKLabelNode(fontNamed: "Chalkduster")
        mainMenu.name = "mainMenu"
        mainMenu.fontColor = SKColor.orangeColor()
        mainMenu.fontSize = 70
        mainMenu.position = CGPointMake(size.width/2+250, size.height/2-50)
        mainMenu.text = "Main Menu"
        gameOverMenu.addChild(mainMenu)
        addChild(gameOverMenu)
    }
    
    func setupUI(){
        timeLabel = SKLabelNode(fontNamed: "Arial")
        timeLabel.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue)
        timeLabel.position = CGPointMake(CGRectGetMidX(playableArea)-60, CGRectGetMaxY(playableArea)-80)
        timeLabel.fontColor = SKColor.blackColor()
        timeLabel.fontSize = 50
        timeLabel.horizontalAlignmentMode = .Left
        addChild(timeLabel)
        
        let pauseLabel = SKLabelNode(fontNamed: "Arial")
        pauseLabel.name = "pause"
        pauseLabel.fontColor = SKColor.blueColor()
        pauseLabel.fontSize = 50
        pauseLabel.text = "pause"
        pauseLabel.position = CGPointMake(CGRectGetMinX(playableArea)+70, CGRectGetMaxY(playableArea)-80)
        pauseButton = pauseLabel
        addChild(pauseLabel)
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
            if enemyBody.node?.actionForKey(GameScene.hitRockActionKey) != nil{
                break
            }
            else if shieldCount > 0{
                shieldCount--
                if let shield = player.childNodeWithName("shield") as? SKSpriteNode{
                    shield.alpha /= 2
                }
                if let enemy = enemyBody.node as? Enemy{
                    let nextVelocity = (enemyBody.node!.position-player.position).normalized()*enemy.moveSpeed
                    enemyBody.velocity = CGVectorMake(0, 0)
                    enemy.runAction(SKAction.sequence([
                        SKAction.group([
                            SKAction.moveBy(CGVector(point: nextVelocity.normalized()*400), duration: 1),
                            SKAction.rotateByAngle(CGFloat(M_PI*4.0), duration: 1)]),
                        SKAction.runBlock({ () -> Void in
                            enemy.moveToward(nextVelocity)
                            enemy.faceCurrentDirection()
                        })]), withKey: GameScene.playerKickActionKey)
                }
                if shieldCount <= 0{
                    gamePropsGenerator.disableEffect(.WhosYourDaddy)
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
            catBody.node?.removeAllActions()
            catBody.node?.removeFromParent()
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
            showBonusTimeEffect(otherBody.node!.position)
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
    
    func showBonusTimeEffect(position: CGPoint){
        let bonusLabel = SKLabelNode(fontNamed: "Arial")
        bonusLabel.fontColor = SKColor.goldColor()
        bonusLabel.fontSize = 50
        bonusLabel.text = "+0.1s"
        bonusLabel.position = position
        addChild(bonusLabel)
        bonusLabel.runAction(GameScene.bonusTimeAction)
    }
    
    /*    用户手势处理    */
    //双击手势 设置摇杆位置
    func handleDoubleTapGesture(sender: UITapGestureRecognizer){
        if sender.state == .Ended{
            var loc = sender.locationInView(view)
            if let analog = (view as? GameView)?.controller as? AnalogController{
                if loc.x < analog.padPadding + analog.padSide/2{
                    loc.x = analog.padPadding + analog.padSide/2
                }
                else if loc.x > view!.frame.size.width - analog.padPadding - analog.padSide/2{
                    loc.x = view!.frame.size.width - analog.padPadding - analog.padSide/2
                }
                if loc.y < analog.padPadding + analog.padSide/2{
                    loc.y = analog.padPadding + analog.padSide/2
                }
                else if loc.y > view!.frame.size.height - analog.padPadding - analog.padSide/2{
                    loc.y = view!.frame.size.height - analog.padPadding - analog.padSide/2
                }
                analog.center = loc
            }
        }
    }
    
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
                if pauseButton.containsPoint(touchPos){
                    pauseGame()
                    pauseButton.hidden = true
                }
            }
            else{
                //游戏内菜单
                if !inGameMenu.hidden{
                    let resume = inGameMenu.childNodeWithName("resume")
                    if resume!.containsPoint(touchPos){
                        resumeGame()
                        pauseButton.hidden = false
                    }
                    let settings = inGameMenu.childNodeWithName("settings")
                    if settings!.containsPoint(touchPos){
                        let navc = view?.window?.rootViewController as! UINavigationController
                        navc.pushViewController((navc.storyboard?.instantiateViewControllerWithIdentifier("SettingsController"))!, animated: true)
                    }
                    let mainMenu = inGameMenu.childNodeWithName("mainMenu")
                    if mainMenu!.containsPoint(touchPos){
                        handleMainMenuAction()
                    }
                    let restart = inGameMenu.childNodeWithName("restart")
                    if restart!.containsPoint(touchPos){
                        restartGame()
                    }
                }
                else if !gameOverMenu.hidden{
                    //游戏结束菜单
                    let mainMenuOver = gameOverMenu.childNodeWithName("mainMenu")
                    if mainMenuOver!.containsPoint(touchPos){
                        (view?.window?.rootViewController as! UINavigationController).popToRootViewControllerAnimated(true)
                    }
                    let restartOver = gameOverMenu.childNodeWithName("restart")
                    if restartOver!.containsPoint(touchPos){
                        restartGame()
                    }
                }
            }
        }
    }
    
    private func handleMainMenuAction(){
        let alert = UIAlertController(title: "Warning", message: "Ingame status will be discarded, continue?", preferredStyle: .Alert)
        let cancleAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Yes", style: .Destructive) { (action) -> Void in
            (self.view?.window?.rootViewController as! UINavigationController).popToRootViewControllerAnimated(true)
        }
        alert.addAction(cancleAction)
        alert.addAction(continueAction)
        view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    /*   主刷新循环   */
    override func update(currentTime: NSTimeInterval) {
        if (!inGameMenu.hidden || !gameOverMenu.hidden) && !paused{
            lastTimeStamp = 0.0
            paused = true
        }
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
            
            if minute == nextMinute{
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
                enemy.turnCat()
                enemy.paused = true
                enemy.currentSpeed = 0
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
        instructionLabel.text = "Eat them!"
        instructionLabel.position = CGPointMake(CGRectGetMidX(playableArea), CGRectGetMidY(playableArea))
        addChild(instructionLabel)
        
        instructionLabel.runAction(GameScene.showInstructionAnim){
                //取消时间静止
                self.stopTimeEnabled = false
                for enemyNode in self.enemyLayer.children{
                    if let enemy = enemyNode as? Enemy{
                        enemy.paused = false
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
                            //取消变猫效果
                            self.turnCatEnabled = false
                            for enemyNode in self.enemyLayer.children{
                                if let enemy = enemyNode as? Enemy{
                                    enemy.resumeFromCat()
                                }
                            }
                            self.timeLabel.fontColor = originColor
                            self.removeActionForKey(GameScene.turnCatActionKey)
                        }
                    })])), withKey: GameScene.turnCatActionKey)
        }
    }
    
    //调整敌人朝向与速度
    override func didSimulatePhysics() {
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
            if slowDownEnabled{
                for enemyNode in enemyLayer.children{
                    if enemyNode.actionForKey(GameScene.hitRockActionKey) == nil && enemyNode.actionForKey(GameScene.playerKickActionKey) == nil && enemyNode.physicsBody?.categoryBitMask != PhysicsCategory.Cat.rawValue{
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
        removeAllActions()
        pauseButton.hidden = true
        timeLabel.runAction(GameScene.showTimeAnim){
            self.paused = true
            self.gameOverMenu.hidden = false
            if self.timePassed > UserDocuments.bestRecord{
                UserDocuments.bestRecord = self.timePassed
            }
        }
    }
    
    func resumeGame(){
        inGameMenu.hidden = true
        paused = false
        if let accelerometerController = (view as? GameView)?.controller as? AccelerometerController{
            accelerometerController.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: accelerometerController.handler)
        }
        if stopTimeEnabled{
            for enemy in enemyLayer.children{
                enemy.paused = true
            }
        }
    }
    
    func pauseGame(){
        paused = true
        inGameMenu.hidden = false
        lastTimeStamp = 0.0
        player.physicsBody?.velocity = CGVectorMake(0, 0)
        if let accelerometerController = (view as? GameView)?.controller as? AccelerometerController{
            accelerometerController.motionManager.stopAccelerometerUpdates()
        }
    }
    
    func restartGame(){
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        let gameView = view as! GameView
        gameView.setupController(scene)
        gameView.presentScene(scene, transition: GameScene.flipTransition)
    }
    
    /*   PlayerControllerDelegate   */
    func moveByDirection(direction: CGPoint) {
        if !initialing && !isGameOver{
            player.moveToward(direction*moveSpeed)
        }
    }
}
