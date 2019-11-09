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

class Main: ObservableObject, NODEDelegate {
    
    let kRes: Int = 255
    let kSteps: Int = 10
    let kImgRes: Resolution = ._1024
    let kAnimationSeconds: CGFloat = 0.25
    
    enum State {
        case capture
        case grid
    }
    @Published var state: State = .capture {
        didSet {
            bypass = state != .capture
        }
    }
    
    var sortMethod: SortMethod = .date {
        didSet {
            sort()
        }
    }
    
    let sketch: Sketch
    
    @Published var liveGaradient: Gradient!
    
    #if !targetEnvironment(simulator)
    let cameraPix: CameraPIX
    let flipFlopPix: FlipFlopPIX
    let resolutionPix: ResolutionPIX
    let feedbackPix: FeedbackPIX
    let crossPix: CrossPIX
    let hueSaturation: HueSaturationPIX
    let blurPix: BlurPIX
    let cropVerticalPix: CropPIX
    let cropHorizontalPix: CropPIX
    let resolutionVerticalPix: ResolutionPIX
    let resolutionHorizontalPix: ResolutionPIX
    let postGradientPix: GradientPIX
    let postCirclePix: CirclePIX
    let postBlendPix: BlendPIX
    #endif
    
    var bypass: Bool = false {
        didSet {
            #if !targetEnvironment(simulator)
            cameraPix.bypass = bypass
            flipFlopPix.bypass = bypass
            resolutionPix.bypass = bypass
            feedbackPix.bypass = bypass
            crossPix.bypass = bypass
            hueSaturation.bypass = bypass
            blurPix.bypass = bypass
            cropVerticalPix.bypass = bypass
            cropHorizontalPix.bypass = bypass
            resolutionVerticalPix.bypass = bypass
            resolutionHorizontalPix.bypass = bypass
            postGradientPix.bypass = bypass
            postCirclePix.bypass = bypass
            postBlendPix.bypass = bypass
            #endif
        }
    }
    
    @Published var direction: Direction = .vertical {
        didSet {
//            #if !targetEnvironment(simulator)
//            switch direction {
//            case .horizontal:
//                gradientPix.direction = .horizontal
//                gradientPix.offset = 0.0
//                gradientPix.extendRamp = .hold
//                lookupPix.axis = .x
//            case .vertical:
//                gradientPix.direction = .vertical
//                gradientPix.extendRamp = .mirror
//                gradientPix.offset = 1.0
//                lookupPix.axis = .y
//            case .angle:
//                gradientPix.direction = .angle
//                gradientPix.offset = 0.75
//                gradientPix.extendRamp = .loop
//                lookupPix.axis = .y
//            case .radial:
//                gradientPix.direction = .radial
//                gradientPix.offset = 1.0
//                gradientPix.extendRamp = .mirror
//                lookupPix.axis = .y
//            }
//            #endif
        }
    }
    
    @Published var photos: [Photo] = []
    
    @Published var displayPhoto: Photo?
    @Published var displayFrame: CGRect?
    @Published var displayFraction: CGFloat = 0.0
    
    @Published var showShare: Bool = false
    @Published var shareItems: [Any] = []
    
    init() {
        
        sketch = Sketch()
        
        #if !targetEnvironment(simulator)
        
        cameraPix = CameraPIX()
        cameraPix.view.placement = .aspectFill
        cameraPix.view.checker = false
        
        // FIXME: Take away once bug is fixed.
        flipFlopPix = FlipFlopPIX()
        flipFlopPix.input = cameraPix
        flipFlopPix.flip = .y
        
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
        
        hueSaturation = HueSaturationPIX()
        hueSaturation.input = crossPix
        hueSaturation.saturation = 1.25

        blurPix = BlurPIX()
        blurPix.input = hueSaturation
        blurPix.radius = 0.0

        cropVerticalPix = CropPIX()
        cropVerticalPix.input = blurPix
        cropVerticalPix.cropFrame = CGRect(x: 0.5 - 0.5 / CGFloat(kRes), y: 0.0, width: 1.0 / CGFloat(kRes), height: 1.0)
        
        cropHorizontalPix = CropPIX()
        cropHorizontalPix.input = blurPix
        cropHorizontalPix.cropFrame = CGRect(x: 0, y: 0.5 - 0.5 / CGFloat(kRes), width: 1.0, height: 1.0 / CGFloat(kRes))

        resolutionVerticalPix = ResolutionPIX(at: .custom(w: 3, h: kSteps * 3))
        resolutionVerticalPix.placement = .fill
        resolutionVerticalPix.extend = .hold
        resolutionVerticalPix.input = cropVerticalPix
        
        resolutionHorizontalPix = ResolutionPIX(at: .custom(w: kSteps * 3, h: 3))
        resolutionHorizontalPix.placement = .fill
        resolutionHorizontalPix.extend = .hold
        resolutionHorizontalPix.input = cropHorizontalPix
        
        postGradientPix = GradientPIX(at: kImgRes)
        
        postCirclePix = CirclePIX(at: kImgRes)
        postCirclePix.radius = 0.5
        postCirclePix.bgColor = .clear
        
        postBlendPix = BlendPIX()
        postBlendPix.blendMode = .multiply
        postBlendPix.inputA = postGradientPix
        postBlendPix.inputB = postCirclePix
        
        resolutionVerticalPix.delegate = self
        resolutionHorizontalPix.delegate = self
        
        #endif
        
        let black = Color(red: 0.0, green: 0.0, blue: 0.0)
        liveGaradient = makeGradient(at: kSteps, from: black, to: black, in: direction)
        
        addTemplates()
        
    }
    
    func nodeDidRender(_ node: NODE) {
        guard let pixels = getPixels() else { return }
        liveGaradient = makeGradient(at: kSteps, from: pixels, in: direction)
    }
    
    func capture() {
        
        #if !targetEnvironment(simulator)
        
        guard let cameraImage = flipFlopPix.renderedImage else { captureFailed(); return }
        guard let pixels = getPixels() else { captureFailed(); return }
        
        let gradient: Gradient = makeGradient(at: kSteps, from: pixels, in: direction)
        
        getImage(from: gradient, done: { image in
        
            let photo = Photo(id: UUID(), photoImage: cameraImage, gradientImage: image, date: Date(), direction: self.direction, gradient: gradient)
            self.photos.append(photo)
            
        }) {
            self.captureFailed()
        }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        #endif
        
    }
    
    func getImage(from gradient: Gradient, done: @escaping (UIImage) -> (), failed: @escaping () -> ()) {
        postGradientPix.colorSteps = gradient.colorStops.map({ colorStop -> ColorStep in
            ColorStep(LiveFloat(colorStop.fraction), colorStop.color.liveColor)
        })
        var gotTexture: Bool?
        postBlendPix.nextTextureAvalible {
            guard gotTexture == nil else { return }
            gotTexture = true
            guard let image = self.postBlendPix.renderedImage else {
                failed()
                return
            }
            done(image)
        }
        RunLoop.current.add(Timer(timeInterval: 1.0, repeats: false, block: { _ in
            guard gotTexture == nil else { return }
            gotTexture = false
            failed()
        }), forMode: .common)
    }
    
    func getPixels() -> PIX.PixelPack? {
        switch direction.axis {
        case .x:
            return resolutionHorizontalPix.renderedPixels
        case .y:
            return resolutionVerticalPix.renderedPixels
        }
    }
    
    func captureFailed() {}
    
    #if !targetEnvironment(simulator)
    func makeGradient(at count: Int, from pixels: PIX.PixelPack, in direction: Direction) -> Gradient {
        var colorStops: [ColorStop] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1)
            let relFraction = (CGFloat(i) + 0.5) / CGFloat(count)
            let color: Color
            switch direction.axis {
            case .x:
                color = Color(pixels.pixel(uv: CGVector(dx: relFraction, dy: 0.5)).color)
            case .y:
                color = Color(pixels.pixel(uv: CGVector(dx: 0.5, dy: 1.0 - relFraction)).color)
            }
            let colorStop = ColorStop(color: color, fraction: fraction)
            colorStops.append(colorStop)
        }
        return Gradient(direction: direction, colorStops: colorStops)
    }
    #endif
    
    func makeGradient(at count: Int, from fromColor: Color, to toColor: Color, in direction: Direction) -> Gradient {
        var colorStops: [ColorStop] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1)
            let color = Color(red: fromColor.red * (1.0 - fraction) + toColor.red * fraction,
                                  green: fromColor.green * (1.0 - fraction) + toColor.green * fraction,
                                  blue: fromColor.blue * (1.0 - fraction) + toColor.blue * fraction)
            let colorStop = ColorStop(color: color, fraction: fraction)
            colorStops.append(colorStop)
        }
        return Gradient(direction: direction, colorStops: colorStops)
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
    
    func reDragPhoto() {
        if let timer = animationTimer {
            timer.invalidate()
        }
    }
    
    func reDisplayPhoto() {
        let currentFraction = displayFraction
        guard currentFraction != 1.0 else { return }
        animate(for: kAnimationSeconds - currentFraction * kAnimationSeconds, ease: .easeOut, animate: { fraction in
            self.displayFraction = currentFraction * (1.0 - fraction) + fraction
        }) {}
    }
    
    func reHidePhoto() {
        let currentFraction = displayFraction
        guard currentFraction != 0.0 else { return }
        animate(for: kAnimationSeconds * currentFraction, ease: .easeOut, animate: { fraction in
            self.displayFraction = currentFraction * (1.0 - fraction)
        }) {
            self.displayPhoto = nil
            self.displayFrame = nil
        }
    }
    
    var animationTimer: Timer?
    
    enum Ease {
        case easeIn
        case easeOut
        case easeInOut
    }
    
    func animate(for seconds: CGFloat, ease: Ease? = nil, animate: @escaping (CGFloat) -> (), done: @escaping () -> ()) {
        if let timer = animationTimer {
            timer.invalidate()
        }
        var index = 0
        let count = Int(seconds / 0.01)
        animationTimer = Timer(timeInterval: 0.01, repeats: true, block: { timer in
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
            if index >= count {
                timer.invalidate()
                self.animationTimer = nil
                done()
            }
        })
        RunLoop.current.add(animationTimer!, forMode: .common)
    }
    
    func share(_ item: Any) {
        shareItems = [item]
        showShare = true
    }
    
    func shareSketch() {
        guard let photo = displayPhoto else { return }
        do {
            let file = try sketch.generate(from: photo, with: photo.gradient)
            share(file)
        } catch {
            shareSketchFailed()
        }
    }
    
    func shareSketchFailed() {}
    
    func addTemplates() {
        
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
                              gradient: makeGradient(at: kSteps,
                                                     from: Color(hue: hue),
                                                     to: Color(hue: invHue),
                                                     in: direction))
            photos.append(photo)
        }
        
        let photo = Photo(id: UUID(),
                          photoImage: photoImage,
                          gradientImage: gradientImage,
                          date: Date(),
                          direction: .vertical,
                          gradient: makeGradient(at: 5,
                                                 from: Color(red: 1.0, green: 0.5, blue: 0.0),
                                                 to: Color(red: 0.0, green: 0.5, blue: 1.0),
                                                 in: .vertical))
        photos.append(photo)
        
    }
    
    enum SortMethod: String, CaseIterable {
        case date = "Date"
        case hue = "Hue"
        case sat = "Saturation"
        case val = "Brightness"
    }
    
    func sort() {
        photos = photos.sorted(by: { photoA, photoB -> Bool in
            let colorA = photoA.gradient.averageColor.liveColor
            let colorB = photoB.gradient.averageColor.liveColor
            switch self.sortMethod {
            case .date:
                return photoA.date < photoB.date
            case .hue:
                return colorA.hue.cg < colorB.hue.cg
            case .sat:
                return colorA.sat.cg < colorB.sat.cg
            case .val:
                return colorA.val.cg < colorB.val.cg
            }
        })
    }
    
}
