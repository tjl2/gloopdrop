//
//  Player.swift
//  gloopdrop
//
//  Created by Tim Littlemore on 16/05/2021.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    // MARK: - PROPERTIES
    // Textures (Animation)
    private var walkTextures: [SKTexture]?
    // This enum lets you easily switch between animations
    enum PlayerAnimationType: String {
        case walk
    }
    // MARK: - INIT
    init() {
        // Set default texture
        let texture = SKTexture(imageNamed: "blob-walk_0")
        
        // Call to superr.init
        super.init(texture: texture, color: .clear, size: texture.size())
        
        // Set up animation textures
        self.walkTextures = self.loadTextures(atlas: "blob", prefix: "blob-walk_", startsAt: 0, stopsAt: 2)
        
        // Set up other properties after init
        self.name = "player"
        self.setScale(1.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0) // centre-bottom
        self.zPosition = Layer.player.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
