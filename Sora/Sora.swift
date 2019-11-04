//
//  Sora.swift
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
    
    @Published var direction: SoraGradient.Direction = .vertical {
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
    
    @Published var photos: [SoraPhoto] = []
    
    init() {
        
        #if !targetEnvironment(simulator)
        
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
        
        let photo = generatePhoto(photoImage: cameraImage, gradientImage: gradientImage, from: pixels, in: direction)
        photos.append(photo)
        
        state = .display
        
        #if !targetEnvironment(simulator)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
    
    func captureFailed() {}
    
    func generatePhoto(photoImage: UIImage, gradientImage: UIImage, from pixels: PIX.PixelPack, in direction: SoraGradient.Direction) -> SoraPhoto {
        let gradients: [SoraGradient] = [3, 5, 10].map { count -> SoraGradient in
            gradient(at: count, from: pixels, in: direction)
        }
        return SoraPhoto(photoImage: photoImage, gradientImage: gradientImage, gradients: gradients)
    }
    
    func gradient(at count: Int, from pixels: PIX.PixelPack, in direction: SoraGradient.Direction) -> SoraGradient {
        var colorSteps: [SoraColorStep] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1)
            let color: SoraColor
            if direction == .horizontal {
                color = SoraColor(pixels.pixel(uv: CGVector(dx: fraction, dy: 0.0)).color)
            } else {
                color = SoraColor(pixels.pixel(uv: CGVector(dx: 0.0, dy: 1.0 - fraction)).color)
            }
            let colorStep = SoraColorStep(color: color, step: fraction)
            colorSteps.append(colorStep)
        }
        return SoraGradient(direction: direction, colorSteps: colorSteps)
    }
    
}
