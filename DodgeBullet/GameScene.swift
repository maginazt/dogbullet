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
    var moveSpeed: CGFloat = 300.0;
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
    //游戏内菜单
    var inGameMenu: SKNode!
    //时间标识
    var timeLabel: SKLabelNode!
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
        gamePropsGenerator = GamePropsGenerator(gameScene: self)
    }
    
    private func setupInGameMenu(){
        inGameMenu = SKNode()
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
        timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel.fontColor = SKColor.whiteColor()
        timeLabel.fontSize = 50
        timeLabel.text = NSString(format: "%2.2f", timePassed) as String
        timeLabel.horizontalAlignmentMode = .Left
        timeLabel.position = CGPointMake(CGRectGetMinX(playableArea), CGRectGetMaxY(playableArea)-90)
        addChild(timeLabel)
    }
    
    /*    碰撞检测事件处理    */
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == (PhysicsCategory.EnemyNormal.rawValue | PhysicsCategory.EnemyCageEdge.rawValue){
            let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.EnemyNormal.rawValue ? contact.bodyA : contact.bodyB
            if let enemy = enemyBody.node as? EnemyNormal{
                enemy.moveToward((randomPointInRect(player.fireRect)-enemy.position).normalized()*CGFloat(GameSpeed.EnemyNormalSpeed.rawValue))
                enemiesToAdjustDirection.append(enemy)
            }
        }
        else if collision == (PhysicsCategory.EnemyFast.rawValue | PhysicsCategory.EnemyCageEdge.rawValue){
            let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.EnemyFast.rawValue ? contact.bodyA : contact.bodyB
            if let enemy = enemyBody.node as? EnemyFast{
                enemy.removeFromParent()
            }
        }
        else if collision == (PhysicsCategory.EnemyNormal.rawValue | PhysicsCategory.Player.rawValue) || collision == (PhysicsCategory.EnemySlow.rawValue | PhysicsCategory.Player.rawValue) || collision == (PhysicsCategory.EnemyFast.rawValue | PhysicsCategory.Player.rawValue){
            handleGameOver(false)
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
        else{
            if forceTouchAvailable{
                if let touch = atouch{
                    if touch.force > 0.2{
                        player.mainSprite.runAction(SKAction.sequence([
                            SKAction.runBlock({self.player.physicsBody = nil}),
                            SKAction.scaleTo(0, duration: 0.1),
                            SKAction.runBlock({self.player.position = touch.locationInNode(self)}),
                            SKAction.scaleTo(1, duration: 0.1),
                            SKAction.runBlock({self.player.physicsBody = self.player.mainBody})]))
                    }
                }
            }
        }
    }
    
    /*   主刷新循环   */
    override func update(currentTime: NSTimeInterval) {
        if !inGameMenu.hidden && !paused{
            paused = true
        }
        if lastTimeStamp == 0.0{
            lastTimeStamp = currentTime
        }
        else{
            deltaTime = currentTime - lastTimeStamp
            lastTimeStamp = currentTime
        }
        timePassed += deltaTime
        timeLabel.text = NSString(format: "%2.2f", timePassed) as String
        
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
}
