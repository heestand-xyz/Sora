//
//  Sora.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
#if !targetEnvironment(simulator)
import PixelKit
#endif

class Sora: ObservableObject {
    
    #if !targetEnvironment(simulator)
    let cameraPix: CameraPIX
    let resolutionPix: ResolutionPIX
    let blurPix: BlurPIX
    let gradientPix: GradientPIX
    let lookupPix: LookupPIX
    let finalPix: PIX
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
            case .vertical:
                gradientPix.direction = .vertical
                lookupPix.axis = .y
            }
            #endif
        }
    }
    
    init() {
        
        #if !targetEnvironment(simulator)
        cameraPix = CameraPIX()
        cameraPix.view.placement = .aspectFill
        
        resolutionPix = ResolutionPIX(at: .square(255))
        resolutionPix.input = cameraPix
        resolutionPix.placement = .aspectFill

        blurPix = BlurPIX()
        blurPix.input = resolutionPix
        blurPix.radius = 0.5

        gradientPix = GradientPIX(at: .square(255))
        gradientPix.direction = .vertical

        lookupPix = LookupPIX()
        lookupPix.axis = .y
        lookupPix.inputA = gradientPix
        lookupPix.inputB = blurPix
        
        finalPix = lookupPix
        #endif
        
    }
    
}
