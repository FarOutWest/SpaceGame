//
//  GameOverScene.swift
//  SpaceGame
//
//  Created by West Castro on 11/17/16.
//  Copyright © 2016 West Castro. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let restartLabel = SKLabelNode(text: "Restart")
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "launch")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(text: "")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 70
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.85)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(text: "")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 40
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = SKColor.yellow
        scoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.65)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScore = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highScore {
            highScore = gameScore
            defaults.set(highScore, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(text: "")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontSize = 40
        highScoreLabel.fontName = "AvenirNext-Bold"
        highScoreLabel.fontColor = SKColor.yellow
        highScoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.45)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 60
        restartLabel.fontName = "AvenirNext-Bold"
        restartLabel.fontColor = SKColor.blue
        restartLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.15)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch) {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transition)
            }
        }
    }
    
}
