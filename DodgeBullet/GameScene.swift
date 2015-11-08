//
//  GameScene.swift
//  DodgeBullet
//
//  Created by 赵涛 on 15/10/11.
//  Copyright (c) 2015年 赵涛. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, PlayerControllerDelegate, SKPhysicsContactDelegate {
    
    var forceTouchAvailable: Bool = false
    var initialing = true
    //当前移动速度
    var moveSpeed: CGFloat = GameSpeed.PlayerDefaultSpeed.rawValue
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
    
    let hitRockActionKey = "hitRockAction"
    let playerKickActionKey = "playerKickAction"
    
    var playerPhantom: Player?//用户幻象
    var stopTimeEnabled = false//时间静止效果
    var turnCatEnabled = false//变猫效果
    var dogFoodArea: CGRect?//狗粮区域
    var shieldCount = 0//护盾次数
    var slowDownEnabled = false//减速光环效果
    //游戏内菜单
    var inGameMenu: SKNode!
    //时间标识
    var currentTimeLabel: SKLabelNode!
    var bestRecordLabel: SKLabelNode!
    var timePassed: NSTimeInterval = 0
    var lastTimeStamp: NSTimeInterval = 0
    var deltaTime: NSTimeInterval = 0
    
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
        backgroundColor = SKColor(red: 242.0/255.0, green: 244.0/255.0, blue: 245.0/255.0, alpha: 1)
        initialing = true
        setupPlayableArea()
        setupEnemyCage()
        setupPlayer()
        setupEnemy()
        setupGameProps()
        setupInGameMenu()
        setupUI()
        initialing = false
    }
    
    private func setupEnemyCage(){
        enemyCage = SKNode()
        enemyCage.zPosition = CGFloat(SceneZPosition.EnemyCageZPosition.rawValue)
        enemyCage.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(CGRectGetMinX(playableArea)-EnemyGenerator.enemyDistance, CGRectGetMinY(playableArea)-EnemyGenerator.enemyDistance, playableArea.width+EnemyGenerator.enemyDistance*2, playableArea.height+EnemyGenerator.enemyDistance*2))
        enemyCage.physicsBody?.categoryBitMask = PhysicsCategory.EnemyCageEdge.rawValue
        addChild(enemyCage)
    }
    
    private func setupPlayableArea(){
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let maxAspectHeight = size.width / maxAspectRatio
        let margin = (self.size.height - maxAspectHeight) / 2
        playableArea = CGRectMake(0, margin, size.width, maxAspectHeight)
//        print(playableArea)
        
//        let edgeShape = SKShapeNode(rect: playableArea)
//        edgeShape.strokeColor = SKColor.redColor()
//        edgeShape.lineWidth = 10.0
//        addChild(edgeShape)
//        backgroundColor = SKColor.whiteColor()
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableArea)
        physicsBody?.categoryBitMask = PhysicsCategory.Edge.rawValue
        physicsBody?.friction = 0
    }
    
    private func setupPlayer(){
        player = Player()
        player.position = CGPointMake(size.width/2, size.height/2)
        addChild(player)
        player.setupTail()
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
        resume.fontSize = 80
        resume.text = "Resume Game"
        resume.name = "resume"
        resume.position = CGPointMake(size.width/2, size.height/2+200)
        inGameMenu.addChild(resume)
        
        let settings = SKLabelNode(fontNamed: "Chalkduster")
        settings.fontColor = SKColor.blueColor()
        settings.fontSize = 80
        settings.text = "Settings"
        settings.name = "settings"
        settings.position = CGPointMake(size.width/2, size.height/2)
        inGameMenu.addChild(settings)
        
        let mainMenu = SKLabelNode(fontNamed: "Chalkduster")
        mainMenu.fontColor = SKColor.blueColor()
        mainMenu.fontSize = 80
        mainMenu.text = "Main Menu"
        mainMenu.name = "mainMenu"
        mainMenu.position = CGPointMake(size.width/2, size.height/2-200)
        inGameMenu.addChild(mainMenu)
        addChild(inGameMenu)
    }
    
    func setupUI(){
        let timeLabel = SKNode()
        timeLabel.zPosition = CGFloat(SceneZPosition.GameMenuZPosition.rawValue)
        timeLabel.position = CGPointMake(CGRectGetMinX(playableArea)+30, CGRectGetMaxY(playableArea)-80)
        addChild(timeLabel)
        currentTimeLabel = SKLabelNode(fontNamed: "Chalkduster")
        currentTimeLabel.name = "ct"
        currentTimeLabel.fontColor = SKColor.blackColor()
        currentTimeLabel.fontSize = 50
        currentTimeLabel.text = NSString(format: "CT: %2.2f", timePassed) as String
        currentTimeLabel.horizontalAlignmentMode = .Left
        currentTimeLabel.position = CGPointMake(0, 30)
        timeLabel.addChild(currentTimeLabel)
        
        bestRecordLabel = SKLabelNode(fontNamed: "Chalkduster")
        bestRecordLabel.name = "br"
        bestRecordLabel.fontColor = SKColor.blackColor()
        bestRecordLabel.fontSize = 50
        bestRecordLabel.text = NSString(format: "BR: %2.2f", UserDocuments.bestRecord) as String
        bestRecordLabel.horizontalAlignmentMode = .Left
        bestRecordLabel.position = CGPointMake(0, -30)
        timeLabel.addChild(bestRecordLabel)
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
            if !stopTimeEnabled{
                if shieldCount > 0{
                    shieldCount--
                    let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.Player.rawValue ? contact.bodyB : contact.bodyA
                    if enemyBody.node?.actionForKey(playerKickActionKey) == nil{
                        if let enemy = enemyBody.node as? Enemy{
                            let nextVelocity = (enemyBody.node!.position-player.position).normalized()*enemy.moveSpeed
                            enemyBody.velocity = CGVectorMake(0, 0)
                            enemy.runAction(SKAction.sequence([
                                SKAction.group([
                                    SKAction.moveBy(CGVector(point: nextVelocity), duration: 1),
                                    SKAction.rotateByAngle(CGFloat(M_PI*2.0), duration: 1)]),
                                SKAction.runBlock({ () -> Void in
                                    enemy.moveToward(nextVelocity)
                                    enemy.faceCurrentDirection()
                                })]), withKey: playerKickActionKey)
                        }
                    }
                    if shieldCount <= 0{
                        gamePropsGenerator.disableEffect(.WhosYourDaddy)
                    }
                }
                else{
//                    handleGameOver(false)
                }
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
            timePassed += 0.5
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
            if enemyBody.node?.actionForKey(hitRockActionKey) == nil{
                enemyBody.velocity = CGVectorMake(0, 0)
                enemyBody.node?.runAction(SKAction.sequence([
                    SKAction.waitForDuration(2),
                    SKAction.runBlock({ () -> Void in
                        if let enemy = enemyBody.node as? Enemy{
                            if !self.stopTimeEnabled{
                                enemy.currentSpeed = enemy.moveSpeed
                            }
                        }
                    })]), withKey: hitRockActionKey)
            }
        default:
            break
        }
    }
    
    let bonusTimeAction = SKAction.sequence([
        SKAction.moveByX(0, y: 100, duration: 0.5),
        SKAction.fadeOutWithDuration(0.2),
        SKAction.removeFromParent()])
    func showBonusTimeEffect(position: CGPoint){
        let bonusLabel = SKLabelNode(fontNamed: "Arial")
        bonusLabel.fontColor = SKColor.yellowColor()
        bonusLabel.fontSize = 50
        bonusLabel.text = "+0.5s"
        bonusLabel.position = position
        addChild(bonusLabel)
        bonusLabel.runAction(bonusTimeAction)
    }
    
    /*    用户手势处理    */
    //划动手势
    func handleSwipeGesture(){
//        player.mainSprite.runAction(SKAction.sequence([
//            SKAction.runBlock({self.player.physicsBody = nil}),
//            SKAction.scaleXTo(0, duration: 0.1),
//            SKAction.scaleXTo(-1, duration: 0.1),
//            SKAction.scaleXTo(0, duration: 0.1),
//            SKAction.scaleXTo(1, duration: 0.1),
//            SKAction.runBlock({self.player.physicsBody = self.player.mainBody})]))
    }
    
    /*   点击事件处理   */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let atouch = touches.first
        if paused{
            if let touch = atouch{
                let touchPos = touch.locationInNode(self)
                let resume = inGameMenu.childNodeWithName("resume")
                if resume!.containsPoint(touchPos){
                    resumeGame()
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
            }
        }
//        else{
//            if forceTouchAvailable{
//                if let touch = atouch{
//                    if touch.force > 0.2{
//                        player.mainSprite.runAction(SKAction.sequence([
//                            SKAction.runBlock({self.player.physicsBody = nil}),
//                            SKAction.scaleTo(0, duration: 0.1),
//                            SKAction.runBlock({self.player.position = touch.locationInNode(self)}),
//                            SKAction.scaleTo(1, duration: 0.1),
//                            SKAction.runBlock({self.player.physicsBody = self.player.mainBody})]))
//                    }
//                }
//            }
//        }
    }
    
    private func handleMainMenuAction(){
        let alert = UIAlertController(title: "warning", message: "Ingame status will be discarded, continue?", preferredStyle: .Alert)
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
        if !inGameMenu.hidden && !paused{
            lastTimeStamp = 0.0
            paused = true
        }
        if paused{
            return
        }
        if lastTimeStamp == 0.0{
            lastTimeStamp = currentTime
        }
        else{
            deltaTime = currentTime - lastTimeStamp
            lastTimeStamp = currentTime
        }
        timePassed += deltaTime
        currentTimeLabel.text = NSString(format: "CT: %2.2f", timePassed) as String
        if timePassed > UserDocuments.bestRecord{
            currentTimeLabel.fontColor = SKColor.redColor()
            bestRecordLabel.text = NSString(format: "BR: %2.2f", timePassed) as String
            bestRecordLabel.fontColor = SKColor.redColor()
        }
    }
    
    //调整敌人朝向与速度
    override func didSimulatePhysics() {
        if !stopTimeEnabled{
            //所有狗都朝向狗粮
            if dogFoodArea != nil && !turnCatEnabled{
                for enemyNode in enemyLayer.children{
                    if enemyNode.actionForKey(hitRockActionKey) == nil && enemyNode.actionForKey(playerKickActionKey) == nil{
                        if let enemy = enemyNode as? Enemy{
                            enemy.moveToward((randomPointInRect(dogFoodArea!)-enemy.position).normalized()*enemy.moveSpeed)
                            enemy.faceCurrentDirection()
                        }
                    }
                }
            }
            else{
                //普通敌人调整朝向
                for enemy in enemiesToAdjustDirection{
                    enemy.faceCurrentDirection()
                }
                //慢速敌人始终朝向player
                for enemy in enemyGenerator.slowEnemies{
                    if enemy.actionForKey(hitRockActionKey) == nil && enemy.actionForKey(playerKickActionKey) == nil{
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
                    if enemyNode.actionForKey(hitRockActionKey) == nil && enemyNode.actionForKey(playerKickActionKey) == nil{
                        if let enemy = enemyNode as? Enemy{
                            if (enemy.position-player.position).length() <= gamePropsGenerator.slowDownRadius{
                                enemy.currentSpeed = CGFloat(GameSpeed.SlowDownSpeed.rawValue)
                            }
                            else{
                                if enemy.physicsBody?.categoryBitMask == PhysicsCategory.Cat.rawValue{
                                    enemy.currentSpeed = CGFloat(GameSpeed.CatSpeed.rawValue)
                                }
                                else{
                                    enemy.currentSpeed = enemy.moveSpeed
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*    处理游戏事件    */
    func handleGameOver(won: Bool){
        if timePassed > UserDocuments.bestRecord{
            UserDocuments.bestRecord = timePassed
        }
        let gameOver = GameOverScene()
        gameOver.size = size
        gameOver.scaleMode = scaleMode
        gameOver.won = won
        view?.presentScene(gameOver, transition: SKTransition.flipVerticalWithDuration(0.3))
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
    
    /*   PlayerControllerDelegate   */
    func moveByDirection(direction: CGPoint) {
        if !initialing{
            player.moveToward(direction*moveSpeed)
        }
    }
    
    deinit{
        if timePassed > UserDocuments.bestRecord{
            UserDocuments.bestRecord = timePassed
        }
    }
}
