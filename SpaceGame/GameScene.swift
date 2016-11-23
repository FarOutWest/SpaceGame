//
//  GameScene.swift
//  SpaceGame
//
//  Created by West Castro on 11/10/16.
//  Copyright © 2016 West Castro. All rights reserved.
//
//  helpful tutorial here: https://www.youtube.com/watch?v=7_kftKVT9-Q
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    let scoreLabel = SKLabelNode(text: "")
    var level = 0
    var lives = 5
    let livesLabel = SKLabelNode(text: "")
    let ship = SKSpriteNode(imageNamed: "ship")
    let tapToStartLabel = SKLabelNode(text: "")
    
    enum gameState {
        case preGame //before game starts
        case inGame //durring the game play
        case afterGame //game is over
    }
    
    var currentGameState = gameState.preGame
    
    //Create a Struct of Physics Categories to deal with contacts
    struct physicsCategories {
        static let None : UInt32 = 0 //0
        static let Ship : UInt32 = 0b1 //1
        static let Projectile : UInt32 = 0b10 //2
        static let Asteroid : UInt32 = 0b100 //4
    }
    
    //Random Function Utilities
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func randomdouble() -> Double {
        return Double(Double(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func randomdouble(min: Double, max: Double) -> Double {
        return randomdouble() * (max - min) + min
    }
    
    //Define a Game Area
    let gameArea: CGRect
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    //Required by SWIFT
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Createing the game scene
    override func didMove(to view: SKView) {
        gameScore = 0

        self.physicsWorld.contactDelegate = self
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2,
                                          y: self.size.height * CGFloat(i))
            background.zPosition = 0
            background.name = "background"
            self.addChild(background)
        }
        
        ship.setScale(0.15)
        ship.position = CGPoint(x: self.size.width/2, y: -ship.size.height)
        ship.zPosition = 2
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.categoryBitMask = physicsCategories.Ship
        ship.physicsBody!.collisionBitMask = physicsCategories.None
        ship.physicsBody!.contactTestBitMask = physicsCategories.Asteroid
        self.addChild(ship)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 25
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.color = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.1, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 5"
        livesLabel.fontSize = 25
        livesLabel.fontName = "AvenirNext-Bold"
        livesLabel.color = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.9, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOntoScreen = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.75)
        scoreLabel.run(moveOntoScreen)
        livesLabel.run(moveOntoScreen)
        
        tapToStartLabel.text = "Tap to Begin"
        tapToStartLabel.fontSize = 50
        tapToStartLabel.fontName = "AvenirNext-Bold"
        tapToStartLabel.color = SKColor.white
        tapToStartLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        tapToStartLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height / 2)
        tapToStartLabel.zPosition = 100
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.75)
        tapToStartLabel.run(fadeInAction)
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    let ammountToMove: CGFloat = 600.0
    
    func update(currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let ammountToMoveBackground = ammountToMove * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "background") {
            background, stop in
            
            if self.currentGameState == gameState.inGame {
                background.position.y -= ammountToMoveBackground
            }
            
            if background.position.y < -self.size.height {
                background.position.y += self.size.height * 2
            }
        }
    }
    
    func startGame() {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let delete = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([fadeOutAction, delete])
        
        tapToStartLabel.run(sequenceAction)
        
        let moveShipToScreen = SKAction.moveTo(y: self.size.height * 0.15, duration: 0.75)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipToScreen, startLevelAction])
        ship.run(startGameSequence)
    }
    
    func loseLife() {
        lives -= 1
        livesLabel.text = "Lives: \(lives)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let livesSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(livesSequence)
        
        if lives == 0 {
            gameOver()
        }
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 20 || gameScore == 30 || gameScore == 40 || gameScore == 50 || gameScore == 60 || gameScore == 70 || gameScore == 80 || gameScore == 100 {
            startNewLevel()
        }
    }
    
    func gameOver() {
        currentGameState = gameState.afterGame
        
        //self.removeAllActions()
        
        self.enumerateChildNodes(withName: "projectile") {
            projectile, stop in
            projectile.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "asteroid") {
            asteroid, stop in
            asteroid.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "asteroid1") {
            asteroid1, stop in
            asteroid1.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 0.5)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.removeAllActions()
        self.run(changeSceneSequence)
    }
    
    func changeScene() {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: transition)
    }
    
    //Handle the contacts between Physics Bodies
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == physicsCategories.Ship && body2.categoryBitMask == physicsCategories.Asteroid {
            //ship hits asteroid
            if body1.node != nil {
                spawnExplosion(spawnposition: body1.node!.position)
            }
            
            if body2.node != nil {
                spawnExplosion(spawnposition: body2.node!.position)
            }
            
            body2.node?.removeFromParent()
            body1.node?.removeFromParent()
            
            gameOver()
        }
        
        if body1.categoryBitMask == physicsCategories.Projectile && body2.categoryBitMask == physicsCategories.Asteroid {
            //projectile hits asteroid
            addScore()
            
            if body2.node != nil {
                spawnExplosion(spawnposition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    //Spawn an explosion when two Physics Bodies make contact with One Another
    func spawnExplosion(spawnposition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnposition
        explosion.zPosition = 4
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 0.3, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        let delete = SKAction.removeFromParent()
        let explosionsequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionsequence)
    }
    
    //Create a new Level for Leveling System
    func startNewLevel() {
        level += 1
        
        if self.action(forKey: "spawningasteroids") != nil {
            self.removeAction(forKey: "spawningasteroids")
        }
        
        var spawnduration = TimeInterval()
        
        switch level{
            case 1: spawnduration = 2.0
            case 2: spawnduration = 1.75
            case 3: spawnduration = 1.5
            case 4: spawnduration = 1.25
            case 5: spawnduration = 1.0
            case 6: spawnduration = 0.75
            case 7: spawnduration = 0.5
            case 8: spawnduration = 0.25
            case 9: spawnduration = 0.15
            case 10: spawnduration = 0.1
            default:
                spawnduration = 2.0
                print("cannot find level information")
        }
        
        let spawn = SKAction.run(spawnAsteroid)
        let waitToSpawn = SKAction.wait(forDuration: spawnduration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningasteroids")
    }
    
    //Spawn and shoot a projectile from the ship
    func fireprojectile () {
        let projectile = SKSpriteNode(imageNamed: "missile")
        projectile.name = "projectile"
        projectile.setScale(0.05)
        projectile.position = ship.position
        projectile.zPosition = 1
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody!.affectedByGravity = false
        projectile.physicsBody!.categoryBitMask = physicsCategories.Projectile
        projectile.physicsBody!.collisionBitMask = physicsCategories.None
        projectile.physicsBody!.contactTestBitMask = physicsCategories.Asteroid
        self.addChild(projectile)
        
        let moveProjectile = SKAction.moveTo(y: self.size.height + projectile.size.height, duration: 1)
        let deleteProjectile = SKAction.removeFromParent()
        
        let projectilesequence = SKAction.sequence([moveProjectile, deleteProjectile])
        projectile.run(projectilesequence)
    }
    
    //Generate 2 Asteroids with a random x-axis position and y-axis speed
    func spawnAsteroid() {
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXStart1 = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd1 = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        let startPoint1 = CGPoint(x: randomXStart1, y: self.size.height * 1.2)
        let endPoint1 = CGPoint(x: randomXEnd1, y: -self.size.height * 0.2)
        
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        let asteroid1 = SKSpriteNode(imageNamed: "asteroid1")
        asteroid.name = "asteroid"
        asteroid1.name = "asteroid1"
        asteroid.setScale(random(min: 0.05, max: 0.2))
        asteroid1.setScale(random(min: 0.075, max: 0.25))
        asteroid.position = startPoint
        asteroid1.position = startPoint1
        
        if asteroid.xScale > asteroid1.xScale || asteroid.yScale > asteroid1.yScale {
            asteroid.zPosition = 2
            asteroid1.zPosition = 3
        } else {
            asteroid.zPosition = 3
            asteroid1.zPosition = 2
        }
        
        //asteroid physics
        asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size)
        asteroid.physicsBody!.affectedByGravity = false
        asteroid.physicsBody!.categoryBitMask = physicsCategories.Asteroid
        asteroid.physicsBody!.collisionBitMask = physicsCategories.None
        asteroid.physicsBody!.contactTestBitMask = physicsCategories.Ship | physicsCategories.Projectile
        
        asteroid1.physicsBody = SKPhysicsBody(rectangleOf: asteroid1.size)
        asteroid1.physicsBody!.affectedByGravity = false
        asteroid1.physicsBody!.categoryBitMask = physicsCategories.Asteroid
        asteroid1.physicsBody!.collisionBitMask = physicsCategories.None
        asteroid1.physicsBody!.contactTestBitMask = physicsCategories.Ship | physicsCategories.Projectile
       
        self.addChild(asteroid)
        self.addChild(asteroid1)
        
        let moveAsteroid = SKAction.move(to: endPoint, duration: randomdouble(min: 2.5, max: 5.0))
        let moveAsteroid1 = SKAction.move(to: endPoint1, duration: randomdouble(min: 2.5, max: 5.0))
        let deleteAsteroid = SKAction.removeFromParent()
        let loseAlifeAction = SKAction.run({ self.loseLife() })
        let asteroidSequence = SKAction.sequence([moveAsteroid, deleteAsteroid, loseAlifeAction])
        let asteroidSequence1 = SKAction.sequence([moveAsteroid1, deleteAsteroid, loseAlifeAction])
        
        if currentGameState == gameState.inGame {
            asteroid.run(asteroidSequence)
            asteroid1.run(asteroidSequence1)
        }
        
        asteroid.zRotation += random(min: 0.0, max: 360.0)
        asteroid1.zRotation += random(min: 0.0, max: 360.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame {
            startGame()
        } else if currentGameState == gameState.inGame {
            fireprojectile()
        }
    }
    
    //Create the handles for moving the ship along the x-axis
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let PreviousPointOfTouch = touch.previousLocation(in: self)
            let ammountDragged = pointOfTouch.x - PreviousPointOfTouch.x
            
            if currentGameState == gameState.inGame {
                ship.position.x += ammountDragged
            }
            
            if ship.position.x > gameArea.maxX - ship.size.width/2{
                ship.position.x = gameArea.maxX - ship.size.width/2
            }
            
            if ship.position.x < gameArea.minX + ship.size.width/2{
                ship.position.x = gameArea.minX + ship.size.width/2
            }
            
        }
    }
}
