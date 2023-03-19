//
//  GameScene.swift
//  BlasterGameMacApp
//
//  Created by Daria Moreno-Gogoleva on 19.03.2023.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "playerShip")
    let fireSound = SKAction.playSoundFileNamed("big-laser.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosionSound.wav", waitForCompletion: false)
    
    var gameArea: CGRect
    
    // Declare physical contact between player and enemy
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 // 1
        static let Bullet: UInt32 = 0b10 // 2
        static let Enemy: UInt32 = 0b100 // 3
    }
    
    //  Declare score and lives label
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelNumber = 0
    var livesNumber = 3
    
    
    let kLeftArrowKeyCode: UInt16 = 123
    let kRightArrowKeyCode: UInt16 = 124
    let kDownArrowKeyCode: UInt16 = 125
    let kUpArrowKeyCode: UInt16 = 126
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override init(size: CGSize) {
        let playableWidth = size.width
        let margin = (size.width - playableWidth) / 4
        
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        player.physicsBody?.collisionBitMask = PhysicsCategories.None
        player.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        startLevel()
        
        // initiate score
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 80
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: 70, y: 1664)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        // initiate lives
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 80
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        livesLabel.position = CGPoint(x: 1624, y: 1664)
        livesLabel.zPosition = 100
        self.addChild(scoreLabel)
    }
    
    func fireBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.zPosition = 2
        bullet.position = player.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategories.None
        //        should be PhysicsCategories.Player ???
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy | PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([fireSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func enemyRocket() {
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomYStart = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomYStart, y: self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.zPosition = 2
        enemy.position = startPoint
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseLifeAction = SKAction.run(loseLife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseLifeAction])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    override func mouseDown(with event: NSEvent) {
        fireBullet()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
//        var body1 = SKPhysicsBody()
//        var body2 = SKPhysicsBody()
//
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            body1 = contact.bodyA
//            body2 = contact.bodyB
//        } else {
//            body1 = contact.bodyB
//            body2 = contact.bodyA
//        }
//
//        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
//            if body1.node != nil {
//                spawnExplosion(spawnPosition: body1.node!.position)
//            }
//
//            if body2.node != nil {
//                spawnExplosion(spawnPosition: body2.node!.position)
//            }
//        }
//
//
//        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height {
//
//            if body2.node != nil {
//                spawnExplosion(spawnPosition: body2.node!.position)
//            }
//
//            body1.node?.removeFromParent()
//            body2.node?.removeFromParent()
//        }
    }
    
    
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
            startLevel()
        }
    }
    
    func loseLife() {
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            print("game over")
            // gameOver()
        }
    }
    
    func startLevel() {
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default: levelDuration = 0.5
            print("cannot find level info")
        }
        
        
        let spawn = SKAction.run(enemyRocket)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnMovement = SKAction.repeatForever(spawnSequence)
        self.run(spawnMovement, withKey: "spawningEnemies")
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case kLeftArrowKeyCode:
            if player.position.x != 124 {
                player.position.x = player.position.x - 100
            }
            break
        case kRightArrowKeyCode:
            if player.position.x != 1924 {
                player.position.x = player.position.x + 100
            }
            break
        case kDownArrowKeyCode:
            break
        case kUpArrowKeyCode:
            break
        default:
            print("other")
            break
        }
        
        print("key with number \(event.keyCode) was pressed")

    }
}
 
