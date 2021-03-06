//
//  GameScene.swift
//  gloopdrop
//
//  Created by Tim Littlemore on 06/05/2021.
//

import AVFoundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player = Player()
    let playerSpeed: CGFloat = 1.5
    // Player movement
    var movingPlayer = false
    var lastPosition: CGPoint?
    var level: Int = 1 {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var numberOfDrops: Int = 10
    var dropsExpected = 10
    var dropsCollected = 0
    var dropSpeed: CGFloat = 1.0
    var minDropSpeed: CGFloat = 0.12 // (fastest drop)
    var maxDropSpeed: CGFloat = 1.0 // (slowest drop)
    // Levels
    var scoreLabel: SKLabelNode = SKLabelNode()
    var levelLabel: SKLabelNode = SKLabelNode()
    // Audio nodes
    let musicAudioNode = SKAudioNode(fileNamed: "music.mp3")
    // Game states
    var gameInProgress = false
    
    override func didMove(to view: SKView) {
        // Decrease the audio engine's volume (so we can fade in the music)
        audioEngine.mainMixerNode.outputVolume = 0.0
        // Set up the background music audio node
        musicAudioNode.autoplayLooped = true
        musicAudioNode.isPositional = false
        // Add the audio node to the scene
        addChild(musicAudioNode)
        // Use an action to adjust the audio node's volume to 0
        musicAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
        // Run a delayed action on tne scene that fades in the music
        run(SKAction.wait(forDuration: 1.0), completion: { [unowned self] in
            self.audioEngine.mainMixerNode.outputVolume = 1.0
            self.musicAudioNode.run(SKAction.changeVolume(to: 0.75, duration: 2.0))
        })
        
        // Set up the physics world contact delegate
        physicsWorld.contactDelegate = self
        
        // Set up background
        let background = SKSpriteNode(imageNamed: "background_1")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.background.rawValue
        addChild(background)
        
        // Set up foreground
        let foreground = SKSpriteNode(imageNamed: "foreground_1")
        foreground.anchorPoint = CGPoint(x: 0, y: 0)
        foreground.position = CGPoint(x: 0, y: 0)
        foreground.zPosition = Layer.foreground.rawValue
        // Add physics body
        foreground.physicsBody = SKPhysicsBody(edgeLoopFrom: foreground.frame)
        foreground.physicsBody?.affectedByGravity = false
        foreground.physicsBody?.categoryBitMask = PhysicsCategory.foreground
        foreground.physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        foreground.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(foreground)
        
        // Set up User Interface
        setupLabels()
        
        // Set up player
        player.position = CGPoint(x: size.width/2, y: foreground.frame.maxY)
        player.setupConstraints(floor: foreground.frame.maxY)
        addChild(player)
        // player.walk() - NOW MOVED DO spawnMultipleGloops
        
        // Set up game ??? NOW MOVED TO touchDown SO THAT GAME STARTS ON TAP
        //spawnMultipleGloops()
        
        // Show message
        showMessage("Tap to start game")
    }
    
    // MARK: - GAME FUNCTIONS
    
    func spawnMultipleGloops() {
        // Start player walk animation
        player.walk()
        // Set up drop speed
        dropSpeed = 1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrops)))
        if dropSpeed < minDropSpeed {
            dropSpeed = minDropSpeed
        } else if dropSpeed > maxDropSpeed {
            dropSpeed = maxDropSpeed
        }
        
        // Reset the level and score
        if gameInProgress == false {
            score = 0
            level = 1
        }
        
        // Set the number of drops based on the level
        switch level {
        case 1, 2, 3, 4, 5:
            numberOfDrops = level * 10
        case 6:
            numberOfDrops = 75
        case 7:
            numberOfDrops = 100
        case 8:
            numberOfDrops = 150
        default:
            numberOfDrops = 150
        }
        
        // Reset and update the collected and expected drop count
        dropsCollected = 0
        dropsExpected = numberOfDrops
        
        // Set up repeating action
        let wait = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn = SKAction.run { [unowned self] in self.spawnGloop() }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrops)
        
        // Run action
        run(repeatAction, withKey: "gloop")
        // Update game state
        gameInProgress = true
        // Hide 'start game' or 'get ready' message
        hideMessage()
    }
    
    func spawnGloop() {
        let collectible = Collectible(collectibleType: CollectibleType.gloop)
        
        // set random position
        let margin = collectible.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin,
                                upperLimit: frame.maxX - margin)
        let randomX = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)
        
        collectible.position = CGPoint(x: randomX, y: player.position.y * 2.5)
        addChild(collectible)
        collectible.drop(dropSpeed: TimeInterval(1.0), floorLevel: player.frame.minY)
    }
    
    func checkForRemainingDrops() {
        if dropsCollected == dropsExpected {
            nextLevel()
        }
    }
    
    func nextLevel() {
        showMessage("Get Ready!")
        let wait = SKAction.wait(forDuration: 2.25)
        run(wait, completion: {[unowned self] in self.level += 1
                                self.spawnMultipleGloops()})
    }
    
    func setupLabels() {
        // SCORE LABEL
        scoreLabel.name = "score"
        scoreLabel.fontName = "Nosifer"
        scoreLabel.fontColor = .yellow
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = Layer.ui.rawValue
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: viewTop() - 100)
        // Set the text and add the label node to scene
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        // LEVEL LABEL
        levelLabel.name = "level"
        levelLabel.fontName = "Nosifer"
        levelLabel.fontColor = .yellow
        levelLabel.fontSize = 35.0
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.zPosition = Layer.ui.rawValue
        levelLabel.position = CGPoint(x: frame.minX + 50, y: viewTop() - 100)
        // Set the text and add the label node to scene
        levelLabel.text = "Level: \(level)"
        addChild(levelLabel)
    }
    
    func showMessage(_ message: String) {
        // Set up message label
        let messageLabel = SKLabelNode()
        messageLabel.name = "message"
        messageLabel.position = CGPoint(x: frame.midX, y: player.frame.maxY + 100)
        messageLabel.zPosition = Layer.ui.rawValue
        messageLabel.numberOfLines = 2
        
        // Set up attrributed text
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: SKColor(red: 251.0/255.0, green: 155.0/255.0, blue: 24.0/255.0, alpha: 1.0),
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: "Nosifer", size: 45.0)!,
            .paragraphStyle: paragraph
        ]
        
        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributes)
        
        // Run a fade action and add the label to the scene
        messageLabel.run(SKAction.fadeIn(withDuration: 0.25))
        addChild(messageLabel)
    }
    
    func hideMessage() {
        // Remove message label if it exists
        if let messageLabel = childNode(withName: "//message") as? SKLabelNode {
            messageLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.25),
                                                SKAction.removeFromParent()]))
        }
    }
    
    func gameOver() {
        // Show message
        showMessage("Game Over\nTap to try again")
        // Start the playerr die animation
        player.die()
        // Remove repeatable action on main scene
        removeAction(forKey: "gloop")
        // Loop thrrought child nodes and stop actions on collectibles
        enumerateChildNodes(withName: "//co_*") {
            (node, stop) in
            // stop and remove drops
            node.removeAction(forKey: "drop") // remove action
            node.physicsBody = nil // rermove body so no collisions occur
        }
        // Update game state
        gameInProgress = false
        resetPlayerPosition()
        popRemainingDrops()
    }
    
    func resetPlayerPosition() {
        let resetPoint = CGPoint(x: frame.midX, y: player.position.y)
        let distance = hypot(resetPoint.x-player.position.x, 0)
        let calculatedSpeed = TimeInterval(distance / (playerSpeed * 2)) / 255
        
        if player.position.x > frame.midX {
            player.moveToPosition(pos: resetPoint, direction: "L", speed: calculatedSpeed)
        } else {
            player.moveToPosition(pos: resetPoint, direction: "R", speed: calculatedSpeed)
        }
    }
    
    func popRemainingDrops() {
        var i = 0
        enumerateChildNodes(withName: "//co_*") {
            (node, stop) in
            // Pop remaining drops in sequence
            let initialWait = SKAction.wait(forDuration: 1.0)
            let wait = SKAction.wait(forDuration: TimeInterval(0.15 * CGFloat(i)))
            
            let removeFromParent = SKAction.removeFromParent()
            let actionSequence = SKAction.sequence([initialWait, wait, removeFromParent])
            node.run(actionSequence)
            i += 1
        }
    }
    
    // MARK: - TOUCH HANDLING
    
    func touchDown(atPoint pos : CGPoint ) {
        if gameInProgress == false {
            spawnMultipleGloops()
            return
        }
        let touchedNode = atPoint(pos)
        if touchedNode.name == "player" {
            movingPlayer = true
        }
    }
    
    func touchMoved(toPoint pos: CGPoint) {
        if movingPlayer == true {
            // Clamp position
            let newPos = CGPoint(x: pos.x, y: player.position.y)
            player.position = newPos
            
            // Check last position; if empty, set it
            let recordedPosition = lastPosition ?? player.position
            if recordedPosition.x > newPos.x {
                player.xScale = -abs(xScale)
            } else {
                player.xScale = abs(xScale)
            }
            
            // Save the last known position
            lastPosition = newPos
        }
    }
    
    func touchUp(atPoint pos: CGPoint) {
        movingPlayer = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
}

// MARK: - COLLISION DETECTION

// COLLISION DETECTION METHODS START HERE

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Check collision bodies
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Did the [PLAYER] collide with the [COLLECTIBLE]?
        if collision == PhysicsCategory.player | PhysicsCategory.collectible {
            print("player hit collectible")
            // Find out which body is attached do the collectible node
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ?
                contact.bodyA.node : contact.bodyB.node
            // Verify the object is a collectible and run the .collected() function
            if let sprite = body as? Collectible {
                sprite.collected()
                dropsCollected += 1
                score += level
                checkForRemainingDrops()
            }
        }
        
        // Or did the [COLLECTIBLE] collide with the [FOREGROUND]?
        if collision == PhysicsCategory.foreground | PhysicsCategory.collectible {
            print("collectible hit foreground")
            // Find out which body is attached do the collectible node
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ?
                contact.bodyA.node : contact.bodyB.node
            // Verify the object is a collectible and run the .missed() function
            if let sprite = body as? Collectible {
                sprite.missed()
                gameOver()
            }
        }
    }
}
