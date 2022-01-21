//
//  Main+Gradient.swift
//  Sora
//
//  Created by Anton Heestand on 2022-01-21.
//  Copyright © 2022 Hexagons. All rights reserved.
//

import Foundation
import UIKit
import PixelKit
import PixelColor

extension Main {
    
    #if !targetEnvironment(simulator)
    func makeGradient(at count: Int, from pixels: PIX.PixelPack, in direction: Direction) -> Gradient {
        var colorStops: [Gradient.ColorStop] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1)
            let relFraction = (CGFloat(i) + 0.5) / CGFloat(count)
            let pixelColor: PixelColor
            switch direction.axis {
            case .x:
                pixelColor = pixels.pixel(uv: CGVector(dx: relFraction, dy: 0.5)).color
            case .y:
                pixelColor = pixels.pixel(uv: CGVector(dx: 0.5, dy: 1.0 - relFraction)).color
            }
            let color = Color(red: pixelColor.blue, green: pixelColor.green, blue: pixelColor.red)
            let colorStop = Gradient.ColorStop(color: color, fraction: fraction)
            colorStops.append(colorStop)
        }
        return Gradient(direction: direction, colorStops: colorStops)
    }
    #endif
    
    func makeGradient(at count: Int, from fromColor: Color, to toColor: Color, in direction: Direction) -> Gradient {
        var colorStops: [Gradient.ColorStop] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1)
            let color = Color(red: fromColor.red * (1.0 - fraction) + toColor.red * fraction,
                              green: fromColor.green * (1.0 - fraction) + toColor.green * fraction,
                              blue: fromColor.blue * (1.0 - fraction) + toColor.blue * fraction)
            let colorStop = Gradient.ColorStop(color: color, fraction: fraction)
            colorStops.append(colorStop)
        }
        return Gradient(direction: direction, colorStops: colorStops)
    }
    
    func makeTemplateGradient() -> Gradient {
        makeGradient(at: kSteps,
                     from: Main.Color(red: 1.0, green: 0.5, blue: 0.0),
                     to: Main.Color(red: 0.0, green: 0.5, blue: 1.0),
                     in: direction)
    }
    
    static func gradient(from soraGradient: SoraGradient) -> Main.Gradient? {
        guard let json: String = soraGradient.gradient else { return nil }
        guard let data: Data = json.data(using: .utf8) else { return nil }
        guard let gradient = try? JSONDecoder().decode(Main.Gradient.self, from: data) else { return nil }
        return gradient
    }
    
    func templateGradient(in direction: Direction) -> Main.Gradient {
        Main.Gradient(direction: direction, colorStops: [
            Main.Gradient.ColorStop(color: Main.Color(red: 1.0, green: 0.5, blue: 0.0), fraction: 0.0),
            Main.Gradient.ColorStop(color: Main.Color(red: 0.0, green: 0.5, blue: 1.0), fraction: 0.0)
        ])
    }
    
    func templateSoraGradient() -> SoraGradient {
        
        let soraGradient = SoraGradient(context: context)
        
        soraGradient.id = UUID()
        soraGradient.date = Date()
        
        let gradient: Main.Gradient = liveTemplateGradient
        let gradientData: Data = try! JSONEncoder().encode(gradient)
        let gradientJson: String = String(data: gradientData, encoding: .utf8)!
        soraGradient.gradient = gradientJson
        
        soraGradient.gradientImage = UIImage(named: "gradient")!.pngData()!
        soraGradient.photoImage = UIImage(named: "photo")!.jpegData(compressionQuality: 0.8)!
        
        return soraGradient
    }
}
