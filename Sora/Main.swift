//
//  Main.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
#if !targetEnvironment(simulator)
import RenderKit
import PixelKit
#endif

class Main: ObservableObject {
    
    let kRes: Int = 255
    let kSteps: [Int] = [3, 5, 10]
    
    enum State {
        case main
        case display
    }
    @Published var state: State = .main
    
    #if !targetEnvironment(simulator)
    let cameraPix: CameraPIX
    let resolutionPix: ResolutionPIX
    let feedbackPix: FeedbackPIX
    let crossPix: CrossPIX
    let blurPix: BlurPIX
    let gradientPix: GradientPIX
    let lookupPix: LookupPIX
    let resolutionVerticalPix: ResolutionPIX
    let resolutionHorizontalPix: ResolutionPIX
    let finalPix: PIX & NODEOut
    let backgroundPix: PIX
    let capturePix: PIX
    #endif
    
    @Published var direction: Direction = .vertical {
        didSet {
            #if !targetEnvironment(simulator)
            switch direction {
            case .horizontal:
                gradientPix.direction = .horizontal
                gradientPix.offset = 0.0
                gradientPix.extendRamp = .hold
                lookupPix.axis = .x
            case .vertical:
                gradientPix.direction = .vertical
                gradientPix.extendRamp = .mirror
                gradientPix.offset = 1.0
                lookupPix.axis = .y
            case .angle:
                gradientPix.direction = .angle
                gradientPix.offset = 0.75
                gradientPix.extendRamp = .loop
                lookupPix.axis = .y
            case .radial:
                gradientPix.direction = .radial
                gradientPix.offset = 1.0
                gradientPix.extendRamp = .mirror
                lookupPix.axis = .y
            }
            #endif
        }
    }
    
    @Published var photos: [Photo] = []
    
    @Published var previewDisplay: Bool = false
    
    init() {
        
        #if targetEnvironment(simulator)
        
        let photo = Photo(photoImage: UIImage(named: "photo")!,
                              gradientImage: UIImage(named: "gradient")!,
                              date: Date(),
                              direction: .vertical,
                              gradients: [gradient(at: 5,
                                                   from: Color(red: 1.0, green: 0.5, blue: 0.0),
                                                   to: Color(red: 0.0, green: 0.5, blue: 1.0),
                                                   in: .vertical)])
        photos.append(photo)
        
        #else
        
        cameraPix = CameraPIX()
        cameraPix.view.placement = .aspectFill
        cameraPix.view.checker = false
        
        resolutionPix = ResolutionPIX(at: .square(kRes))
        resolutionPix.input = cameraPix
        resolutionPix.placement = .aspectFill
        
        feedbackPix = FeedbackPIX()
        feedbackPix.input = resolutionPix
        
        crossPix = CrossPIX()
        crossPix.fraction = 0.95
        crossPix.inputA = resolutionPix
        crossPix.inputB = feedbackPix
        
        feedbackPix.feedPix = crossPix

        blurPix = BlurPIX()
        blurPix.input = crossPix
        blurPix.radius = 1.0

        gradientPix = GradientPIX(at: .square(kRes))
        gradientPix.direction = .vertical
        gradientPix.offset = 1.0
        gradientPix.extendRamp = .mirror

        lookupPix = LookupPIX()
        lookupPix.axis = .y
        lookupPix.inputA = gradientPix
        lookupPix.inputB = blurPix
        
        resolutionVerticalPix = ResolutionPIX(at: .custom(w: 1, h: kRes))
        resolutionVerticalPix.input = blurPix
        
        resolutionHorizontalPix = ResolutionPIX(at: .custom(w: kRes, h: 1))
        resolutionHorizontalPix.input = blurPix
        
        finalPix = lookupPix
        finalPix.view.checker = false
        
        backgroundPix = finalPix._nil()
        backgroundPix.view.placement = .fill
        backgroundPix.view.checker = false
        
        capturePix = finalPix._nil()
        capturePix.view.checker = false
        
        #endif
        
    }
    
    func capture() {
        #if !targetEnvironment(simulator)
        guard let cameraImage = cameraPix.renderedImage else { captureFailed(); return }
        guard let gradientImage = finalPix.renderedImage else { captureFailed(); return }
        var pixels: PIX.PixelPack!
        if direction == .horizontal {
            pixels = resolutionHorizontalPix.renderedPixels
        } else {
            pixels = resolutionVerticalPix.renderedPixels
        }
        guard pixels != nil else { captureFailed(); return }
        #endif
        
        #if !targetEnvironment(simulator)
        let photo = generatePhoto(photoImage: cameraImage, gradientImage: gradientImage, from: pixels, in: direction)
        photos.append(photo)
        #endif
        
        state = .display
        
        #if !targetEnvironment(simulator)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
    
    func captureFailed() {}
    
    #if !targetEnvironment(simulator)
    func generatePhoto(photoImage: UIImage, gradientImage: UIImage, from pixels: PIX.PixelPack, in direction: Direction) -> Photo {
        let gradients: [Gradient] = kSteps.map { count -> Gradient in
            gradient(at: count, from: pixels, in: direction)
        }
        return Photo(photoImage: photoImage, gradientImage: gradientImage, date: Date(), direction: direction, gradients: gradients)
    }
    #endif
    
    #if !targetEnvironment(simulator)
    func gradient(at count: Int, from pixels: PIX.PixelPack, in direction: Direction) -> Gradient {
        var colorSteps: [ColorStep] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1)
            let color: Color
            if direction == .horizontal {
                color = Color(pixels.pixel(uv: CGVector(dx: fraction, dy: 0.0)).color)
            } else {
                color = Color(pixels.pixel(uv: CGVector(dx: 0.0, dy: 1.0 - fraction)).color)
            }
            let colorStep = ColorStep(color: color, step: fraction)
            colorSteps.append(colorStep)
        }
        return Gradient(direction: direction, colorSteps: colorSteps)
    }
    #endif
    
    #if targetEnvironment(simulator)
    func gradient(at count: Int, from fromColor: Color, to toColor: Color, in direction: Direction) -> Gradient {
        var colorSteps: [ColorStep] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1)
            let color = Color(red: fromColor.red * (1.0 - fraction) + toColor.red * fraction,
                                  green: fromColor.green * (1.0 - fraction) + toColor.green * fraction,
                                  blue: fromColor.blue * (1.0 - fraction) + toColor.blue * fraction)
            let colorStep = ColorStep(color: color, step: fraction)
            colorSteps.append(colorStep)
        }
        return Gradient(direction: direction, colorSteps: colorSteps)
    }
    #endif
    
}
