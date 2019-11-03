//
//  Sora.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
#if !targetEnvironment(simulator)
import RenderKit
import PixelKit
#endif

class Sora: ObservableObject {
    
    #if !targetEnvironment(simulator)
    let cameraPix: CameraPIX
    let resolutionPix: ResolutionPIX
    let feedbackPix: FeedbackPIX
    let crossPix: CrossPIX
    let blurPix: BlurPIX
    let gradientPix: GradientPIX
    let lookupPix: LookupPIX
    let finalPix: PIX & NODEOut
    let backgroundPix: PIX
    let capturePix: PIX
    #endif
    
    enum Direction {
        case horizontal
        case vertical
    }
    @Published var direction: Direction = .vertical {
        didSet {
            #if !targetEnvironment(simulator)
            switch direction {
            case .horizontal:
                gradientPix.direction = .horizontal
                lookupPix.axis = .x
                gradientPix.offset = 0.0
            case .vertical:
                gradientPix.direction = .vertical
                lookupPix.axis = .y
                gradientPix.offset = 1.0
            }
            #endif
        }
    }
    
    init() {
        
        #if !targetEnvironment(simulator)
        cameraPix = CameraPIX()
        cameraPix.view.placement = .aspectFill
        cameraPix.view.checker = false
        
        resolutionPix = ResolutionPIX(at: .square(255))
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

        gradientPix = GradientPIX(at: .square(255))
        gradientPix.direction = .vertical
        gradientPix.offset = 1.0
        gradientPix.extendRamp = .mirror

        lookupPix = LookupPIX()
        lookupPix.axis = .y
        lookupPix.inputA = gradientPix
        lookupPix.inputB = blurPix
        
        finalPix = lookupPix
        finalPix.view.checker = false
        
        backgroundPix = finalPix._nil()
        backgroundPix.view.placement = .fill
        backgroundPix.view.checker = false
        
        capturePix = finalPix._nil()
        capturePix.view.checker = false
        
        #endif
        
    }
    
}
