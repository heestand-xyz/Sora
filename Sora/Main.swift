//
//  Main.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
#if !targetEnvironment(simulator)
import LiveValues
import RenderKit
import PixelKit
#endif

class Main: ObservableObject {
    
    let kRes: Int = 255
    let kSteps: [Int] = [3, 5, 10]
    let kAnimationSeconds: CGFloat = 0.5
    
    enum State {
        case capture
        case grid
    }
    @Published var state: State = .capture
    
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
    
    @Published var displayPhoto: Photo?
    @Published var displayFrame: CGRect?
    @Published var displayFraction: CGFloat = 0.0
    
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
        
        let photoImage = UIImage(named: "photo")!
        let gradientImage = UIImage(named: "gradient")!
        
        for _ in 0..<33 {
            let hue = CGFloat.random(in: 0.0...1.0)
            let invHue = (hue + (1 / 3)).truncatingRemainder(dividingBy: 1.0)
            let direction = Direction.allCases[.random(in: 0..<4)]
            let photo = Photo(id: UUID(),
                              photoImage: photoImage,
                              gradientImage: gradientImage,
                              date: Date(),
                              direction: .vertical,
                              gradients: [gradient(at: 5,
                                                   from: Color(hue: hue),
                                                   to: Color(hue: invHue),
                                                   in: direction)])
            photos.append(photo)
        }
        
        let photo = Photo(id: UUID(),
                          photoImage: photoImage,
                          gradientImage: gradientImage,
                          date: Date(),
                          direction: .vertical,
                          gradients: [gradient(at: 5,
                                               from: Color(red: 1.0, green: 0.5, blue: 0.0),
                                               to: Color(red: 0.0, green: 0.5, blue: 1.0),
                                               in: .vertical)])
        photos.append(photo)
        
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
        return Photo(id: UUID(), photoImage: photoImage, gradientImage: gradientImage, date: Date(), direction: direction, gradients: gradients)
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
    
    func display(photo: Photo, from frame: CGRect) {
        displayFrame = frame
        displayPhoto = photo
        animate(for: kAnimationSeconds, ease: .easeOut, animate: { fraction in
            self.displayFraction = fraction
        }) {}
    }
    
    func hidePhoto() {
        animate(for: kAnimationSeconds, ease: .easeOut, animate: { fraction in
            self.displayFraction = 1.0 - fraction
        }) {
            self.displayPhoto = nil
            self.displayFrame = nil
        }
    }
    
    func reDisplayPhoto() {
        let currentFraction = displayFraction
        animate(for: kAnimationSeconds - currentFraction, ease: .easeOut, animate: { fraction in
            self.displayFraction = currentFraction * (1.0 - fraction) + fraction
        }) {}
    }
    
    func reHidePhoto() {
        let currentFraction = displayFraction
        animate(for: kAnimationSeconds * currentFraction, ease: .easeOut, animate: { fraction in
            self.displayFraction = currentFraction * (1.0 - fraction)
        }) {
            self.displayPhoto = nil
            self.displayFrame = nil
        }
    }
    
    enum Ease {
        case easeIn
        case easeOut
        case easeInOut
    }
    
    func animate(for seconds: CGFloat, ease: Ease? = nil, animate: @escaping (CGFloat) -> (), done: @escaping () -> ()) {
        var index = 0
        let count = Int(seconds / 0.01)
        RunLoop.current.add(Timer(timeInterval: 0.01, repeats: true, block: { timer in
            index += 1
            var fraction = CGFloat(index) / CGFloat(count)
            if let ease = ease {
                switch ease {
                case .easeIn:
                    fraction = sin(fraction * .pi / 2 - .pi / 2) + 1.0
                case .easeOut:
                    fraction = sin(fraction * .pi / 2)
                case .easeInOut:
                    fraction = sin(fraction * .pi - .pi / 2) / 2 + 0.5
                }
            }
            animate(fraction)
            if index == count {
                timer.invalidate()
                done()
            }
        }), forMode: .common)
    }
    
}
