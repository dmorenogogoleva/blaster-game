//
//  GameOverScene.swift
//  BlasterGameMacApp
//
//  Created by Daria Moreno-Gogoleva on 19.03.2023.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 180
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score \(gameScore)"
        scoreLabel.fontSize = 130
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 1)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        
        var highScoreNumber = defaults.integer(forKey: "savedHighScore")
        if gameScore > highScoreNumber {
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "savedHighScore")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        highScoreLabel.text = "High score \(highScoreNumber)"
        highScoreLabel.fontSize = 100
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        highScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 3)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "Restart"
        restartLabel.fontSize = 100
        restartLabel.fontColor = SKColor.white
        restartLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 4)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
    }
    
    func restartGame() {
        gameScore = 0
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFill
        let transition = SKTransition.flipHorizontal(withDuration: 1.5)
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        
        if atPoint(location) == restartLabel {
            restartGame()
        }
        
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 49:
            restartGame()
            break
        default:
            print("other")
            break
        }
        
        print("key with number \(event.keyCode) was pressed")

    }

}
