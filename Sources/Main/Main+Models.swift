//
//  Models.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import UIKit
import CoreData
import PixelColor

extension Main {

    enum Direction: String, CaseIterable, Codable {
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

//    struct Photo: Identifiable, Equatable {
//
//        let id: UUID
//
//        let photoImage: UIImage
//        let gradientImage: UIImage
//
//        let date: Date
//
//        let gradient: Gradient
//
//        static func == (lhs: Photo, rhs: Photo) -> Bool {
//            lhs.id == rhs.id
//        }
//
//    }

    struct Gradient: Codable {
        
        let direction: Direction
    
        struct ColorStop: Codable {
            
            let color: Color
            
            let fraction: CGFloat
            
        }
        
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

    struct Color: Codable {
        
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        
        static let black = Color(red: 0.0, green: 0.0, blue: 0.0)
        static let white = Color(red: 1.0, green: 1.0, blue: 1.0)
        
        var color: SwiftUI.Color {
            SwiftUI.Color(.sRGB, red: Double(red), green: Double(green), blue: Double(blue), opacity: 1.0)
        }
        
        var uiColor: UIColor {
            UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        
        var pixelColor: PixelColor {
            PixelColor(red: red, green: green, blue: blue)
        }
        
        var hex: String {
            PixelColor(uiColor).hex.uppercased()
        }
        
        init(red: CGFloat, green: CGFloat, blue: CGFloat) {
            self.red = red
            self.green = green
            self.blue = blue
        }
        
        init(hue: CGFloat) {
            let pixelColor = PixelColor(hue: hue, saturation: 1.0, brightness: 1.0)
            red = pixelColor.red
            green = pixelColor.green
            blue = pixelColor.blue
        }
        
        init(_ pixelColor: PixelColor) {
            red = pixelColor.red
            green = pixelColor.green
            blue = pixelColor.blue
        }
        
    }

    
}
