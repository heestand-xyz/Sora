//
//  SoraModels.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import UIKit
import LiveValues

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
    
    let color: SoraColor
    
    let step: CGFloat
    
}

struct SoraColor {
    
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    
    var color: Color {
        Color(.sRGB, red: Double(red), green: Double(green), blue: Double(blue), opacity: 1.0)
    }
    
    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var hex: String {
        LiveColor(uiColor).hex
    }
    
    init(_ liveColor: LiveColor) {
        red = liveColor.r.cg
        green = liveColor.g.cg
        blue = liveColor.b.cg
    }
    
}
