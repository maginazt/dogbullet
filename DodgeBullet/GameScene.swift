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
    
    var playerPhantom: Player?//用户幻象
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
//        player.setupEngine()
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
        settings.fontColor = SKColor.whiteColor()
        settings.fontSize = 80
        settings.text = "Settings"
        settings.name = "settings"
        settings.position = CGPointMake(size.width/2, size.height/2)
        inGameMenu.addChild(settings)
        
        let mainMenu = SKLabelNode(fontNamed: "Chalkduster")
        mainMenu.fontColor = SKColor.whiteColor()
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
        currentTimeLabel.fontColor = SKColor.whiteColor()
        currentTimeLabel.fontSize = 50
        currentTimeLabel.text = NSString(format: "CT: %2.2f", timePassed) as String
        currentTimeLabel.horizontalAlignmentMode = .Left
        currentTimeLabel.position = CGPointMake(0, 30)
        timeLabel.addChild(currentTimeLabel)
        
        bestRecordLabel = SKLabelNode(fontNamed: "Chalkduster")
        bestRecordLabel.name = "br"
        bestRecordLabel.fontColor = SKColor.whiteColor()
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
        case PhysicsCategory.EnemyNormal.rawValue | PhysicsCategory.EnemyCageEdge.rawValue:
            let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.EnemyNormal.rawValue ? contact.bodyA : contact.bodyB
            if let enemy = enemyBody.node as? EnemyNormal{
                enemy.moveToward((randomPointInRect(player.fireRect)-enemy.position).normalized()*CGFloat(GameSpeed.EnemyNormalSpeed.rawValue))
                enemiesToAdjustDirection.append(enemy)
            }
            //快速敌人 移除
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
//            handleGameOver(false)
            break
            //用户拾得道具 增加特殊效果
        case PhysicsCategory.GameProps.rawValue | PhysicsCategory.Player.rawValue:
            let gamePropsBody = contact.bodyA.categoryBitMask == PhysicsCategory.GameProps.rawValue ? contact.bodyA : contact.bodyB
            if let gameProps = gamePropsBody.node as? GameProps{
                gamePropsGenerator.handleGamePropsEffect(gameProps)
            }
        default:
            break
        }
    }
    
    /*    用户手势处理    */
    //划动手势
    func handleSwipeGesture(){
        player.mainSprite.runAction(SKAction.sequence([
            SKAction.runBlock({self.player.physicsBody = nil}),
            SKAction.scaleXTo(0, duration: 0.1),
            SKAction.scaleXTo(-1, duration: 0.1),
            SKAction.scaleXTo(0, duration: 0.1),
            SKAction.scaleXTo(1, duration: 0.1),
            SKAction.runBlock({self.player.physicsBody = self.player.mainBody})]))
    }
    
    /*   点击事件处理   */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let atouch = touches.first
        if paused{
            if let touch = atouch{
                let touchPos = touch.locationInNode(self)
                let resume = inGameMenu.childNodeWithName("resume")
                if resume!.containsPoint(touchPos){
                    inGameMenu.hidden = true
                    paused = false
                }
                let settings = inGameMenu.childNodeWithName("settings")
                if settings!.containsPoint(touchPos){
                    let navc = view?.window?.rootViewController as! UINavigationController
                    navc.pushViewController((navc.storyboard?.instantiateViewControllerWithIdentifier("SettingsController"))!, animated: true)
                }
                let mainMenu = inGameMenu.childNodeWithName("mainMenu")
                if mainMenu!.containsPoint(touchPos){
                    (view?.window?.rootViewController as! UINavigationController).popToRootViewControllerAnimated(true)
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
        
        //慢速敌人始终朝向player
        for enemy in enemyGenerator.slowEnemies{
            enemy.physicsBody?.velocity = CGVector(point: (player.position-enemy.position).normalized()*CGFloat(GameSpeed.EnemySlowSpeed.rawValue))
            enemy.faceCurrentDirection()
        }
    }
    
    override func didSimulatePhysics() {
        for enemy in enemiesToAdjustDirection{
            enemy.faceCurrentDirection()
        }
        enemiesToAdjustDirection.removeAll()
    }
    
    /*    处理游戏结束    */
    func handleGameOver(won: Bool){
        let gameOver = GameOverScene()
        gameOver.size = size
        gameOver.scaleMode = scaleMode
        gameOver.won = won
        view?.presentScene(gameOver, transition: SKTransition.flipVerticalWithDuration(0.3))
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
