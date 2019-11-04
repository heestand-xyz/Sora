//
//  SoraModels.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit

struct SoraPhoto {
    
    let photoImage: UIImage
    let gradientImage: UIImage
    
    let gradients: [SoraGradient]
    
}

struct SoraGradient {
    
    enum Direction {
        case horizontal
        case vertical
        case angle
        case radial
    }
    let direction: Direction
    
    let colorSteps: [SoraColorStep]
    
}

struct SoraColorStep {
    
    let color: UIColor
    
    let step: CGFloat
    
}
