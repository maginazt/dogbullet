//
//  GamePropsBanner.swift
//  DodgeBullet
//
//  Created by user on 15/10/27.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import SpriteKit
class GamePropsBanner {
    
    unowned let gameScene: GameScene
    let area: CGRect
    
    var head: GamePropsNode?
    
    init(gameScene: GameScene){
        self.gameScene = gameScene
        area = CGRectMake(CGRectGetMinX(gameScene.playableArea)+CGRectGetWidth(gameScene.playableArea)/3, CGRectGetMaxY(gameScene.playableArea)-100, CGRectGetWidth(gameScene.playableArea)/3, 100)
    }
    
    func add(gameProps: GameProps){
        let node = GamePropsNode(gameProps: gameProps)
        var pos: CGPoint!
        if head == nil{
            pos = CGPointMake(CGRectGetMaxX(area)-gameProps.size.width/1.5, CGRectGetMaxY(area)-gameProps.size.height/1.5)
            head = node
        }
        else{
            pos = CGPointMake(head!.gameProps.position.x-gameProps.size.width*1.5, head!.gameProps.position.y)
            node.next = head
            head = node
        }
        gameProps.removeActionForKey(GameProps.SpinActionKey)
        gameProps.runAction(SKAction.group([
            SKAction.sequence([SKAction.scaleTo(0.2, duration: 0.1), SKAction.scaleTo(1.5, duration: 0.1)]),
            SKAction.moveTo(pos, duration: 0.2)]))
    }
    
    func remove(gameProps: GameProps){
        var nodeToRemove: GamePropsNode! = head
        while nodeToRemove != nil{
            if nodeToRemove.gameProps.type == gameProps.type{
                break
            }
            nodeToRemove = nodeToRemove.next
        }
        let lastPos = nodeToRemove.gameProps.position
        nodeToRemove.gameProps.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.2),
            SKAction.removeFromParent()])){
                if nodeToRemove === self.head{
                    self.head = self.head?.next
                }
                else{
                    var prevNode: GamePropsNode! = self.head
                    while prevNode.next !== nodeToRemove{
                        prevNode.gameProps.position = prevNode.next!.gameProps.position
                        prevNode = prevNode.next
                    }
                    prevNode.gameProps.position = lastPos
                    prevNode.next = nodeToRemove.next
                }
        }
    }
}
class GamePropsNode {
    
    unowned let gameProps: GameProps
    var next: GamePropsNode?
    
    init(gameProps: GameProps){
        self.gameProps = gameProps
    }
}