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

    enum Direction: CaseIterable {
        case horizontal
        case vertical
        case angle
        case radial
        enum Axis {
            case x
            case y
        }
        var axis: Axis {
            self == .horizontal ? .x : .y
        }
    }

    struct Photo: Identifiable, Equatable {
        
        let id: UUID
        
        let photoImage: UIImage
        let gradientImage: UIImage
        
        let date: Date
        
        let direction: Direction
        
        let gradient: Gradient
        
        static func == (lhs: Photo, rhs: Photo) -> Bool {
            lhs.id == rhs.id
        }
        
    }

    struct Gradient {
        
        let direction: Direction
        
        let colorStops: [ColorStop]
        
        var averageColor: Color {
            let black = Color(red: 0.0, green: 0.0, blue: 0.0)
            var color = colorStops.reduce(black) { result, colorStop -> Color in
                Color(red: result.red + colorStop.color.red,
                      green: result.green + colorStop.color.green,
                      blue: result.blue + colorStop.color.blue)
            }
            let count = CGFloat(colorStops.count)
            color = Color(red: color.red / count,
                          green: color.green / count,
                          blue: color.blue / count)
            return color
        }
        
    }

    struct ColorStop {
        
        let color: Color
        
        let fraction: CGFloat
        
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
        
        var liveColor: LiveColor {
            LiveColor(r: LiveFloat(red), g: LiveFloat(green), b: LiveFloat(blue))
        }
        
        var hex: String {
            LiveColor(uiColor).hex.uppercased()
        }
        
        init(red: CGFloat, green: CGFloat, blue: CGFloat) {
            self.red = red
            self.green = green
            self.blue = blue
        }
        
        init(hue: CGFloat) {
            let liveColor = LiveColor(h: LiveFloat(hue))
            red = liveColor.r.cg
            green = liveColor.g.cg
            blue = liveColor.b.cg
        }
        
        init(_ liveColor: LiveColor) {
            red = liveColor.r.cg
            green = liveColor.g.cg
            blue = liveColor.b.cg
        }
        
    }

    
}
