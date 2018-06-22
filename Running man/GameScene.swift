//
//  GameScene.swift
//  Running man
//
//  Created by GUY Bertrand on 19/06/2018.
//  Copyright © 2018 GUY Bertrand. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var logo: SKLabelNode!
    var gameOver: SKLabelNode!
    
    var gameState = GameState.showingLogo
    
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var timer = Timer()
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView)
    {
        createLogos()
        createPlayer()
        createSky()
        createGround()
        createBackground()
        createScore()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        switch gameState {
            case .showingLogo:
                gameState = .playing
                
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                let wait = SKAction.wait(forDuration: 0.5)
                let activatePlayer = SKAction.run { [unowned self] in
                    self.player.physicsBody?.isDynamic = true
                    self.startRocks()
                }
                
                let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
                logo.run(sequence)
            
            case .playing:
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
            
            case .dead:
                let scene = GameScene(fileNamed: "GameScene")!
                let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
                self.view?.presentScene(scene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard player != nil else { return }
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        
        player.run(rotate)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            speed += 0.2
            score += 1
            
            return
        }
        
        guard contact.bodyA.node != nil && contact.bodyB.node != nil else {
            return
        }
        
        if contact.bodyA.node == player || contact.bodyB.node == player {
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                explosion.position = player.position
                addChild(explosion)
            }

            gameOver.alpha = 1
            gameState = .dead

            player.removeFromParent()
            speed = 0
        }
    }
    
    func createLogos() {
        logo = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        logo.fontSize = 24
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        logo.text = "Start !"
        logo.fontColor = UIColor.black
        
        addChild(logo)
        
        gameOver = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        gameOver.fontSize = 24
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.text = "Game Over ..."
        gameOver.alpha = 0
        gameOver.fontColor = UIColor.black
        addChild(gameOver)
    }
    
    func createPlayer()
    {
        let playerTexture = SKTexture(imageNamed: "player")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        player.position = CGPoint(x: frame.width / 8, y: frame.height / 2)

        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = false
        
        let animation = SKAction.animate(with: [playerTexture], timePerFrame: 0.01)
        let runForever = SKAction.repeatForever(animation)

        player.run(runForever)

    }
    
    func createSky()
    {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 2)
            
            addChild(ground)
            
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            ground.physicsBody?.isDynamic = false
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
    }
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -5
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 100)
            addChild(background)
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    func startRocks() {
        let create = SKAction.run { [unowned self] in
            self.createRocks()
        }
        
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    @objc func createRocks() {
        let rockTexture = SKTexture(imageNamed: "rock")
        
        let topRock = SKSpriteNode(texture: rockTexture)
        topRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        topRock.physicsBody?.isDynamic = false
        topRock.zRotation = .pi
        topRock.xScale = -1.0
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        bottomRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        bottomRock.physicsBody?.isDynamic = false
        
        let rockCollision = SKSpriteNode(color: UIColor.red, size: CGSize(width: 32, height: frame.height))
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false
        rockCollision.name = "scoreDetect"
        rockCollision.alpha = 0
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        
        let xPosition = frame.width + topRock.frame.width
        
        let max = Int(frame.height / 3)
        let rand = GKRandomDistribution(lowestValue: -50, highestValue: max)
        let yPosition = CGFloat(rand.nextInt())
        

        let rockDistance: CGFloat = CGFloat(Float(arc4random_uniform(40) + 50))
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance)
        bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: frame.midY)
        
        let endPosition = frame.width + (topRock.frame.width * 2)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black
        
        addChild(scoreLabel)

    }
}
