//
//  Models.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import UIKit
import LiveValues

extension Main {

    enum Direction {
        case horizontal
        case vertical
        case angle
        case radial
    }

    struct Photo {
        
        let photoImage: UIImage
        let gradientImage: UIImage
        
        let date: Date
        
        let direction: Direction
        
        let gradients: [Gradient]
        
    }

    struct Gradient {
        
        let direction: Direction
        
        let colorSteps: [ColorStep]
        
    }

    struct ColorStep: Identifiable {
        
        var id: CGFloat { step }

        let color: Color
        
        let step: CGFloat
        
    }

    struct Color {
        
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        
        var color: SwiftUI.Color {
            SwiftUI.Color(.sRGB, red: Double(red), green: Double(green), blue: Double(blue), opacity: 1.0)
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

    
}
