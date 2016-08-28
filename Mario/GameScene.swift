//
//  GameScene.swift
//  Mario
//
//  Created by Wenzhe on 16/7/16.
//  Copyright (c) 2016 Wenzhe. All rights reserved.
//

import SpriteKit

struct CollisionNames{
    static let Mario : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Coin : UInt32 = 0x1 << 3
    static let Flag : UInt32 = 0x1 << 4
    static let Power : UInt32 = 0x1 << 5
    static let Fireball : UInt32 = 0x1 << 6
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Map = JSTileMap()
    var Mario = SKSpriteNode()
    
    var cam = SKCameraNode()
    
    var movingLeft = Bool()
    var movingRight = Bool()
    
    var bankValue = Int()
    var flag = SKSpriteNode()
    
    var level = Int()
    
    var coinLabel = SKLabelNode()
    
    var time = Int()
    var bulletEndTime = Int()
    var bulletIntervalTime = Int()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        level = 1
        bankValue = 0
        SetUpScene("level\(level).tmx")
    }
    
    func SetUpScene(scene: String){
        
        for node in self.children {
            node.removeFromParent()
        }
        
        movingLeft = false
        movingRight = false
        
        coinLabel.text = "Coins : \(bankValue)"
        coinLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 3)
        self.addChild(coinLabel)
        
        Map = JSTileMap(named: scene)
        
        Map.position = CGPoint(x: 0, y: 0)
        addChild(Map)
        self.physicsWorld.contactDelegate = self
        
        let gestureUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.jump))
        gestureUp.direction = .Up
        view!.addGestureRecognizer(gestureUp)
        
        self.camera = cam
        self.addChild(cam)
        cam.position = CGPoint(x: frame.width/2, y: frame.height/2)
        
        Mario = SKSpriteNode(imageNamed: "Mario1")
        Mario.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        Mario.size = CGSizeMake(30, 45)
        
        Mario.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(Mario.size.width, Mario.size.height))
        Mario.physicsBody?.categoryBitMask = CollisionNames.Mario
        Mario.physicsBody?.collisionBitMask = CollisionNames.Ground
        Mario.physicsBody?.contactTestBitMask = CollisionNames.Ground | CollisionNames.Coin
        Mario.physicsBody?.affectedByGravity = true
        Mario.physicsBody?.allowsRotation = false
        
        addChild(Mario)
        
        let groundGroup : TMXObjectGroup = Map.groupNamed("GroundObj")
        let coinGroup : TMXObjectGroup = Map.groupNamed("Coins")
        let flagGroup : TMXObjectGroup = Map.groupNamed("End")
        let powerGroup : TMXObjectGroup = Map.groupNamed("PowerUp")
        
        for i in 0..<powerGroup.objects.count{
            let powerObj = powerGroup.objects.objectAtIndex(i) as! NSDictionary
            
            let width = powerObj.objectForKey("width") as! String
            let height = powerObj.objectForKey("height") as! String
            let powerSize = CGSize(width: Int(width)!, height: Int(height)!)
            
            let powerSprite = SKSpriteNode(imageNamed: "fire")
            powerSprite.size = powerSize
            
            let x = powerObj.objectForKey("x") as! Int
            let y = powerObj.objectForKey("y") as! Int
            
            powerSprite.position = CGPoint(x: x + Int(coinGroup.positionOffset.x) + Int(width)! / 2, y: y + Int(coinGroup.positionOffset.y) + Int(height)! / 2)
            powerSprite.physicsBody = SKPhysicsBody(rectangleOfSize: powerSize)
            powerSprite.physicsBody?.categoryBitMask = CollisionNames.Power
            powerSprite.physicsBody?.collisionBitMask = 0
            powerSprite.physicsBody?.contactTestBitMask = CollisionNames.Mario
            
            powerSprite.physicsBody?.affectedByGravity = false
            powerSprite.physicsBody?.dynamic = false
            
            self.addChild(powerSprite)
            
        }
        
        let flagObj = flagGroup.objectNamed("Flag") as NSDictionary
        
        let width = flagObj.objectForKey("width") as! String
        let height = flagObj.objectForKey("height") as! String
        let flagSize = CGSize(width: Int(width)!, height: Int(height)!)
        
        flag = SKSpriteNode(imageNamed: "flag")
        flag.size = flagSize
        
        let x = flagObj.objectForKey("x") as! Int
        let y = flagObj.objectForKey("y") as! Int
        
        flag.position = CGPoint(x: x + Int(flagGroup.positionOffset.x) + Int(width)! / 2, y: y + Int(flagGroup.positionOffset.y) + Int(height)! / 2)
        flag.physicsBody = SKPhysicsBody(rectangleOfSize: flagSize)
        flag.physicsBody?.categoryBitMask = CollisionNames.Flag
        flag.physicsBody?.collisionBitMask = 0
        flag.physicsBody?.contactTestBitMask = CollisionNames.Mario
        
        flag.physicsBody?.affectedByGravity = false
        flag.physicsBody?.dynamic = false
        
        self.addChild(flag)
        
        for i in 0..<coinGroup.objects.count{
            let coinObj = coinGroup.objects.objectAtIndex(i) as! NSDictionary
            
            let width = coinObj.objectForKey("width") as! String
            let height = coinObj.objectForKey("height") as! String
            let coinSize = CGSize(width: Int(width)!, height: Int(height)!)
            
            let coinSprite = SKSpriteNode(imageNamed: "coin")
            coinSprite.size = coinSize
            
            let x = coinObj.objectForKey("x") as! Int
            let y = coinObj.objectForKey("y") as! Int
            
            coinSprite.position = CGPoint(x: x + Int(coinGroup.positionOffset.x) + Int(width)! / 2, y: y + Int(coinGroup.positionOffset.y) + Int(height)! / 2)
            coinSprite.physicsBody = SKPhysicsBody(rectangleOfSize: coinSize)
            coinSprite.physicsBody?.categoryBitMask = CollisionNames.Coin
            coinSprite.physicsBody?.collisionBitMask = 0
            coinSprite.physicsBody?.contactTestBitMask = CollisionNames.Mario
            
            coinSprite.physicsBody?.affectedByGravity = false
            coinSprite.physicsBody?.dynamic = false
            
            self.addChild(coinSprite)
            
        }
        
        for i in 0..<groundGroup.objects.count{
            let gObj = groundGroup.objects.objectAtIndex(i) as! NSDictionary
            
            let width = gObj.objectForKey("width") as! String
            let height = gObj.objectForKey("height") as! String
            let wallSize = CGSize(width: Int(width)!, height: Int(height)!)
            
            let gSprite = SKSpriteNode(color: .clearColor(), size: wallSize)
            
            let x = gObj.objectForKey("x") as! Int
            let y = gObj.objectForKey("y") as! Int
            
            gSprite.position = CGPoint(x: x + Int(groundGroup.positionOffset.x) + Int(width)! / 2, y: y + Int(groundGroup.positionOffset.y) + Int(height)! / 2)
            gSprite.physicsBody = SKPhysicsBody(rectangleOfSize: wallSize)
            gSprite.physicsBody?.categoryBitMask = CollisionNames.Ground
            gSprite.physicsBody?.collisionBitMask = CollisionNames.Mario
            gSprite.physicsBody?.contactTestBitMask = CollisionNames.Mario
            
            gSprite.physicsBody?.affectedByGravity = false
            gSprite.physicsBody?.dynamic = false
            
            self.addChild(gSprite)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        for touch in touches{
            let location = touch.locationInNode(self)
            
            if location.x >= Mario.position.x{
                movingLeft = true
                
                let textureArray = [SKTexture(imageNamed : "Mario2"), SKTexture(imageNamed : "Mario3")]
                Mario.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textureArray, timePerFrame: 0.2)))
                Mario.xScale = 1
                
            }else{
                movingRight = true
                
                let textureArray = [SKTexture(imageNamed : "Mario2"), SKTexture(imageNamed : "Mario3")]
                Mario.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textureArray, timePerFrame: 0.2)))
                Mario.xScale = -1
            }
        }
        
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        movingLeft = false
        movingRight = false
        Mario.removeAllActions()
        Mario.texture = SKTexture(imageNamed: "Mario1")
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        time += 1
        
        if bulletEndTime > time {
            // shoot fire ball
            if bulletIntervalTime == time {
                shootFireballs()
            }
            
        }
        
        if(movingLeft){
            if Mario.physicsBody?.velocity.dx <= 100 {
                Mario.physicsBody?.applyForce(CGVectorMake(100, 0))
            }else {
                
            }
            
        }else if(movingRight){
            if Mario.physicsBody?.velocity.dx >= -100 {
                Mario.physicsBody?.applyForce(CGVectorMake(-100, 0))
            }else {
                
            }
            
        }
        
        if Mario.position.x >= self.frame.width / 2 {
            cam.position.x = Mario.position.x
            
            coinLabel.position.x = Mario.position.x
        }
        
        if Mario.position.y <= 0 {
            SetUpScene("level\(level).tmx")
            Mario.removeAllActions()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB
        
        if a.node?.physicsBody?.categoryBitMask == CollisionNames.Mario && b.node?.physicsBody?.categoryBitMask == CollisionNames.Coin {
            
            b.node?.removeFromParent()
            bankValue += 1
            coinLabel.text = "Coins : \(bankValue)"
            
        }else if a.node?.physicsBody?.categoryBitMask == CollisionNames.Coin && b.node?.physicsBody?.categoryBitMask == CollisionNames.Mario{
            
            a.node?.removeFromParent()
            bankValue += 1
            coinLabel.text = "Coins : \(bankValue)"
            
        }
        
        else if ((a.node?.physicsBody?.categoryBitMask)! | (b.node?.physicsBody?.categoryBitMask)!) == (CollisionNames.Mario | CollisionNames.Flag) {
            
            level += 1
            if level > 2{
                level = 1
            }
            SetUpScene("level\(level).tmx")
            Mario.removeAllActions()
            
        }
        
        else if a.node?.physicsBody?.categoryBitMask == CollisionNames.Mario && b.node?.physicsBody?.categoryBitMask == CollisionNames.Power {
            
            b.node?.removeFromParent()
            shootFireballs()
            bulletEndTime = time + 600
            
        }else if a.node?.physicsBody?.categoryBitMask == CollisionNames.Power && b.node?.physicsBody?.categoryBitMask == CollisionNames.Mario{
            
            a.node?.removeFromParent()
            shootFireballs()
            bulletEndTime = time + 600
        }
    }
    
    func jump() {
        
        Mario.physicsBody?.applyImpulse(CGVectorMake(0, 30))
        movingLeft = false
        movingRight = false
        Mario.texture = SKTexture(imageNamed: "Mario1")
        
    }
    
    func shootFireballs() {
        bulletIntervalTime = time + 20
        let fireball = SKSpriteNode(imageNamed: "fireball")
        fireball.size = CGSize(width: 15, height: 15)
        fireball.position = Mario.position
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: fireball.size.width / 2)
        fireball.physicsBody?.affectedByGravity = true
        fireball.physicsBody?.friction = 0
        fireball.physicsBody?.restitution = 0.8
        fireball.physicsBody?.categoryBitMask = CollisionNames.Fireball
        fireball.physicsBody?.collisionBitMask = CollisionNames.Ground
        
        let actionSequence = SKAction.sequence([SKAction.waitForDuration(2),SKAction.fadeOutWithDuration(0.3)])
        fireball.runAction(actionSequence)
        
        self.addChild(fireball)
        if Mario.xScale == -1 {
            fireball.physicsBody?.applyImpulse(CGVectorMake(-2, 2))
        }else{
            fireball.physicsBody?.applyImpulse(CGVectorMake(2, 2))
        }
        
    }
}
