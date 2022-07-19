//
//  GameScene.swift
//  CollectDrops
//
//  Created by R Albani on 8/27/18.
//  Copyright © 2018 hello. All rights reserved.
//

import SpriteKit
import GameplayKit
//ideas
//make it so its like a sponge that the player would have to emty it after a bit in a bucket
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var cup:SKSpriteNode?
    var waterDrop:SKSpriteNode?
    var frames:[SKTexture] = []
    var framesFire:[SKTexture] = []
    
    var duration:TimeInterval = 0.7
    var dur:TimeInterval = 0.5
    
    var progresslabel:SKLabelNode!
    var multiplyLabel:SKLabelNode!
    var fireSprite:SKSpriteNode!
    
    var score:Int = 0
    var score2:Int = 10
    var val = 1
    var lostWtrDrops:Int = 0
    
    var reached5:Bool = false
    var fireSpawned:Bool = false
    var DidContact:Bool = false
    var removedByFunc:Bool = false
    
    let waterDropBitmask:UInt32 = 1
    let cupBitmask:UInt32 = 2
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
//        self.physicsBody?.usesPreciseCollisionDetection = true
        view.showsPhysics = true
//        ProgressBar()
        progresslbl()
        SpawnCup()
        delay()
  
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
           let location = touch.location(in: self)
            cup?.position.x = location.x
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody:SKPhysicsBody = contact.bodyA
        let secondBody:SKPhysicsBody = contact.bodyB
        
        let cupPos = cup?.position.y
        
        if contact.contactPoint.y > (cupPos! + 5){
            if (secondBody.categoryBitMask == waterDropBitmask){
                secondBody.node?.removeFromParent()
                score += 1
            }else{
                firstBody.node?.removeFromParent()
                score += 1
            }
        }
        DidContact = true
    }
    
    
    func progresslbl(){
        progresslabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        progresslabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 130)
        progresslabel.fontSize = 65
        progresslabel.fontColor = SKColor.black
        self.addChild(progresslabel)
        
    }
    
    func multiplayerLbl(){
        if score != 10 && val != 5{
            val += 1
        }
        multiplyLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX + 100, y: self.frame.maxY - 150), duration: 1.5)
        let scaleAction = SKAction.scale(by: 0.25, duration: 1.5)
        let actionGroup = SKAction.group([moveAction,scaleAction])
        
        multiplyLabel.fontSize = 250
        multiplyLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        multiplyLabel.zPosition = -2
        multiplyLabel.fontColor = SKColor.black
        multiplyLabel.text = "x\(val)"
        multiplyLabel.alpha = 0
        self.addChild(multiplyLabel)
        
        if val >= 5 && reached5 == false{
            spawnFire()
            print("helloooooo")
            multiplyLabel.run(actionGroup)
            fireSpawned = true
            reached5 = true
        }
    }
    
    func spawnFire(){
        for i in 1...8{
            framesFire.append(SKTexture(imageNamed: "\(i)img"))
        }
        fireSprite = SKSpriteNode(imageNamed: "1img")
        fireSprite.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 100)
        fireSprite.setScale(2)
        fireSprite.zPosition = -1
        self.addChild(fireSprite)
        let animat = SKAction.repeatForever(SKAction.animate(with: framesFire, timePerFrame: 0.09))
        fireSprite.run(animat)
    }

    
    
    func SpawnCup(){
        for i in 1...7{
            frames.append(SKTexture(imageNamed: "\(i)"))
        }
        _ = self.frame.minY
        
        cup = SKSpriteNode(imageNamed: "cupSprite")
        
        cup?.setScale(2.5)
        cup?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ((cup?.size.width)! / 2 + 50), height: ((cup?.size.height)! / 4)))
        
        cup?.physicsBody?.categoryBitMask = cupBitmask
        cup?.physicsBody?.contactTestBitMask = waterDropBitmask
        cup?.zPosition = 1
        
        cup?.physicsBody?.allowsRotation = false
        cup?.physicsBody?.affectedByGravity = false
        cup?.physicsBody?.isDynamic = false
        
        cup?.position.y = self.frame.minY + 200
        
        self.addChild(cup!)
    }
    
    func spawnDrops(){
        
        waterDrop = SKSpriteNode(imageNamed: "1")
        waterDrop?.setScale(1.2)
        
        waterDrop?.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat((waterDrop?.size.width)! / 4))
        waterDrop?.physicsBody?.categoryBitMask = waterDropBitmask
        waterDrop?.physicsBody?.collisionBitMask = 0x0
        waterDrop?.physicsBody?.affectedByGravity = false
        
        let rndpos = rndPostion(Min: Int(self.frame.minX + 50), Max: Int(self.frame.maxX - 50))
        waterDrop?.position = CGPoint(x: Double(rndpos), y: Double(self.view!.frame.height))
        
        _ = self.frame.height + 150
        
        self.addChild(waterDrop!)
        
        if score == score2 {
            duration = duration * 0.99
            score2 += 10
            if fireSpawned == false {
            multiplayerLbl()
            }
            if val != 5 && reached5 == false{
                multiplyLabel.run(SKAction.fadeIn(withDuration: 0.3), completion: {
                    self.multiplyLabel.run(SKAction.fadeOut(withDuration: 0.3))
                })
           }else if fireSpawned == true{
                multiplyLabel.run(SKAction.fadeIn(withDuration: 0.3))
                reached5 = true
            }
        }
        moveWtrDrop()
        let animation = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.06))
        waterDrop?.run(animation)
        progresslabel.text = "\(score)"
    }
    
    func moveWtrDrop(){
        
        let he = waterDrop
        
        let distance = self.frame.height + 150
        
        let move = SKAction.moveBy(x: 0, y: -distance, duration: duration)
        
        let remove = SKAction.run {
            he?.removeFromParent()
            self.removedByFunc = true
        }
        let check = SKAction.run{
            if self.removedByFunc == true{
                self.lostWtrDrops += 1
                print("didnt touch the cup")
            }
        
        }
        let moveAndRemove = SKAction.sequence([move,remove,check])
        
        he?.run(moveAndRemove)
    }
    
    
    func delay(){
    //make an action in side that is called with the sequence that chnaged the duration
        var sequence: SKAction?

        let timing = SKAction.wait(forDuration:  dur)
        
        if dur > 0.2{
            dur = dur * 0.995
        }
//        print("delay duration\(dur)")
        
        let spawn = SKAction.run{
            self.spawnDrops()
            }

        sequence = SKAction.sequence([spawn,timing])
        self.run(sequence!){
           self.delay()
        }
    }
    
    func rndPostion(Min: Int, Max: Int) -> Int {
        return Min + Int(arc4random_uniform(UInt32(Max - Min + 1)))
    }
    
}

















