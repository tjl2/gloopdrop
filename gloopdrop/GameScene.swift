//
//  GameScene.swift
//  gloopdrop
//
//  Created by Tim Littlemore on 06/05/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player = Player()
    
    override func didMove(to view: SKView) {
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
        addChild(foreground)
        
        // Set up player
        player.position = CGPoint(x: size.width/2, y: foreground.frame.maxY)
        player.setupConstraints(floor: foreground.frame.maxY)
        addChild(player)
        player.walk()
    }
    
    // MARK: - TOUCH HANDLING
    
    func touchDown(atPoint pos : CGPoint ) {
        if pos.x < player.position.x {
            player.moveToPosition(pos: pos, direction: "L", speed: 1.0)
        } else {
            player.moveToPosition(pos: pos, direction: "R", speed: 1.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
}
