//
//  Collectible.swift
//  gloopdrop
//
//  Created by Tim Littlemore on 18/05/2021.
//

import Foundation
import SpriteKit

enum CollectibleType: String {
    case none
    case gloop
}

class Collectible: SKSpriteNode {
    // MARK: - PROPERTIES
    private var collectibleType: CollectibleType = .none
    
    // MARK: - INIT
    init(collectibleType: CollectibleType) {
        var texture: SKTexture!
        self.collectibleType = collectibleType
        
        // Set thhe texture based on the type
        switch self.collectibleType {
        case .gloop:
            texture = SKTexture(imageNamed: "gloop")
        case .none:
            break
        }
        
        // Call to super.init
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        
        // Set up collectible
        self.name = "co_\(collectibleType)"
        self.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.zPosition = Layer.collectible.rawValue
    }
    
    required init?(coder aDecoder : NSCoder) {
        fatalError("init(coderr:) has not been implemented")
    }
    
    // MARK: - FUNCTIONS
    func drop(dropSpeed: TimeInterval, floorLevel: CGFloat) {
        let pos = CGPoint(x: position.x, y: floorLevel)
        
        let scaleX = SKAction.scaleX(to: 1.0, duration: 1.0)
        let scaleY = SKAction.scaleY(to: 1.3, duration: 1.0)
        let scale = SKAction.group([scaleX, scaleY])
        
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let moveAction = SKAction.move(to: pos, duration: dropSpeed)
        let actionSequence = SKAction.sequence([appear, scale, moveAction])
        
        // Shrink first, then fall action
        self.scale(to: CGSize(width: 0.25, height: 1.0))
        self.run(actionSequence, withKey: "drop")
    }
}
