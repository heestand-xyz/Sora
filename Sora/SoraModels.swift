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

enum SoraDirection {
    case horizontal
    case vertical
    case angle
    case radial
}

struct SoraPhoto {
    
    let photoImage: UIImage
    let gradientImage: UIImage
    
    let date: Date
    
    let direction: SoraDirection
    
    let gradients: [SoraGradient]
    
}

struct SoraGradient {
    
//    let direction: SoraDirection
    
    let colorSteps: [SoraColorStep]
    
}

struct SoraColorStep: Identifiable {
    
    var id: CGFloat { step }

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
        LiveColor(uiColor).hex.uppercased()
    }
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    init(_ liveColor: LiveColor) {
        red = liveColor.r.cg
        green = liveColor.g.cg
        blue = liveColor.b.cg
    }
    
}
