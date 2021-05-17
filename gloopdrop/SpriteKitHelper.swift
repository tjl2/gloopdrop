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
}
