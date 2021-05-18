//
//  SpriteKitHelper.swift
//  gloopdrop
//
//  Created by Tim Littlemore on 16/05/2021.
//

import Foundation
import SpriteKit

// MARK: - SPRITEKIT HELPERS

// Set up shared z-positions
enum Layer: CGFloat {
    case background
    case foreground
    case player
    case collectible
}

// MARK: - SPRITEKIT EXTENSIONS

extension SKSpriteNode {
    // Used to load texture arrrays for animations
    func loadTextures(atlas: String, prefix: String, startsAt: Int, stopsAt: Int) -> [SKTexture] {
        var textureArray = [SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)
        for i in startsAt...stopsAt {
            let textureName = "\(prefix)\(i)"
            let temp = textureAtlas.textureNamed(textureName)
            textureArray.append(temp)
        }
        
        return textureArray
    }
    
    // Start thhe animation using a name and a count (0 = repeat forever)
    func startAnimation(textures: [SKTexture], speed: Double, name: String, count: Int, resize: Bool, restore: Bool) {
        // Run animation only if animation key doesn't already exist
        if (action(forKey: name) == nil) {
            let animation = SKAction.animate(with: textures, timePerFrame: speed, resize: resize, restore: restore)
            
            if count == 0 {
                // Run animation until stopped
                let repeatAction = SKAction.repeatForever(animation)
                run(repeatAction, withKey: name)
            } else if count == 1 {
                run(animation, withKey: name)
            } else {
                let repeatAction = SKAction.repeat(animation, count: count)
                run(repeatAction, withKey: name)
            }
        }
    }
}
