//
//  Main.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import SwiftUI
import RenderKit
import PixelKit
import Resolution
import CoreData
import PixelColor

class Main: ObservableObject, NODEDelegate {
    
    var persistentContainer: NSPersistentCloudKitContainer!
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    let kRes: Int = 256
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
    
    @Published var sortMethod: SortMethod = .date
    
    let sketch: Sketch
    
    #if !targetEnvironment(simulator)
    @Published var liveGradient: Gradient!
    #endif
    @Published var liveTemplateGradient: Gradient!
    
    #if !targetEnvironment(simulator)
    let cameraPix: CameraPIX
    let resolutionPix: ResolutionPIX
    let feedbackPix: FeedbackPIX
    let crossPix: CrossPIX
    let colorShift: ColorShiftPIX
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
            resolutionPix.bypass = bypass
            feedbackPix.bypass = bypass
            crossPix.bypass = bypass
            colorShift.bypass = bypass
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
    
    var soraGradients: [SoraGradient]? {
        let request: NSFetchRequest<SoraGradient> = SoraGradient.sortedFetchRequest()
        guard let results: [SoraGradient] = try? context.fetch(request) else { return nil }
        return results
    }
    
    @Published var direction: Direction = .vertical {
        didSet {
            liveTemplateGradient = makeTemplateGradient()
        }
    }
    
//    @Published var photos: [Photo] = []
//    @Published var lastPhoto: Photo?
    @Published var lastSoraGradient: SoraGradient?
    
    @Published var displaySoraGradient: SoraGradient?
    @Published var displayFrame: CGRect?
    @Published var displayFraction: CGFloat = 0.0
    @Published var nextDisplaySoraGradient: SoraGradient?
    @Published var nextDisplayFraction: CGFloat?
    @Published var nextDisplayWay: Way?
    var gridFrames: [UUID: CGRect] = [:]
    
    @Published var showShare: Bool = false
    @Published var shareItems: [Any] = []
        
    @Published var showQuickLook: Bool = false
    @Published var quickLookItems: [URL] = []
    
    var animationTimer: Timer?
    
    init() {
        
        sketch = Sketch()
        
        #if !targetEnvironment(simulator)
        
        cameraPix = CameraPIX()
        cameraPix.view.placement = .fill
        cameraPix.view.checker = false
        
        resolutionPix = ResolutionPIX(at: .square(kRes))
        resolutionPix.input = cameraPix
        resolutionPix.placement = .fill
        
        feedbackPix = FeedbackPIX()
        feedbackPix.input = resolutionPix
        
        crossPix = CrossPIX()
        crossPix.fraction = 0.95
        crossPix.inputA = resolutionPix
        crossPix.inputB = feedbackPix
        
        feedbackPix.feedbackInput = crossPix
        
        colorShift = ColorShiftPIX()
        colorShift.input = crossPix
        colorShift.saturation = 1.25

        cropVerticalPix = CropPIX()
        cropVerticalPix.input = colorShift
        cropVerticalPix.cropFrame = CGRect(x: 0.5 - 0.5 / CGFloat(kRes), y: 0.0, width: 1.0 / CGFloat(kRes), height: 1.0)
        
        cropHorizontalPix = CropPIX()
        cropHorizontalPix.input = colorShift
        cropHorizontalPix.cropFrame = CGRect(x: 0, y: 0.5 - 0.5 / CGFloat(kRes), width: 1.0, height: 1.0 / CGFloat(kRes))

        resolutionVerticalPix = ResolutionPIX(at: .custom(w: 3, h: kSteps * 3))
        resolutionVerticalPix.placement = .stretch
        resolutionVerticalPix.extend = .hold
        resolutionVerticalPix.input = cropVerticalPix
        
        resolutionHorizontalPix = ResolutionPIX(at: .custom(w: kSteps * 3, h: 3))
        resolutionHorizontalPix.placement = .stretch
        resolutionHorizontalPix.extend = .hold
        resolutionHorizontalPix.input = cropHorizontalPix
        
        postGradientPix = GradientPIX(at: kImgRes)
        
        postCirclePix = CirclePIX(at: kImgRes)
        postCirclePix.radius = 0.5
        postCirclePix.backgroundColor = .clear
        
        postBlendPix = BlendPIX()
        postBlendPix.blendMode = .multiply
        postBlendPix.inputA = postGradientPix
        postBlendPix.inputB = postCirclePix
        
        resolutionVerticalPix.delegate = self
        resolutionHorizontalPix.delegate = self
        
        #endif
        
        #if !targetEnvironment(simulator)
        liveGradient = makeGradient(at: kSteps, from: .black, to: .black, in: direction)
        #endif
        liveTemplateGradient = makeTemplateGradient()
        
//        #if DEBUG
//        addTemplates()
//        #endif

//        #if DEBUG
//        deleteAllData()
//        #endif
        
        setupCoreData()
        listenToApp()
        
    }
    
    func nodeDidRender(_ node: NODE) {
        #if !targetEnvironment(simulator)
        guard let pixels = getPixels() else { return }
        liveGradient = makeGradient(at: kSteps, from: pixels, in: direction)
        #endif
    }
    
    func capture() {
        
        print("Sora - Main - Capture")
        
        #if !targetEnvironment(simulator)
        guard let cameraImage = cameraPix.renderedImage else { captureFailed(); return }
        guard let pixels = getPixels() else { captureFailed(); return }
        
        let gradient: Gradient = makeGradient(at: kSteps, from: pixels, in: direction)

        getImage(from: gradient, done: { image in
        
            do {
                
                try self.save(gradient: gradient, cameraImage: cameraImage, gradientImage: image)
                
            } catch {
                self.captureFailed(with: error)
            }
            
        }) {
            self.captureFailed()
        }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        #else
        
        self.lastSoraGradient = templateSoraGradient()
        
        try! self.save(gradient: liveTemplateGradient, cameraImage: UIImage(named: "photo")!, gradientImage: UIImage(named: "gradient")!)
        
        #endif
        
    }
    
    func save(gradient: Gradient, cameraImage: UIImage, gradientImage: UIImage) throws {
        
        let gradientData: Data = try JSONEncoder().encode(gradient)
        let gradientJson: String = String(data: gradientData, encoding: .utf8)!
        
        let soraGradient = SoraGradient(context: self.context)
        soraGradient.id = UUID()
        soraGradient.date = Date()
        soraGradient.photoImage = cameraImage.jpegData(compressionQuality: 0.8)
        soraGradient.gradientImage = gradientImage.pngData()
        soraGradient.gradient = gradientJson
        
        try self.context.save()
        
        self.lastSoraGradient = soraGradient
        
    }
    
    #if !targetEnvironment(simulator)
    func getImage(from gradient: Gradient, done: @escaping (UIImage) -> (), failed: @escaping () -> ()) {
        postBlendPix.texture = nil
        switch gradient.direction {
        case .horizontal:
            postGradientPix.direction = .horizontal
            postGradientPix.offset = 0.0
            postGradientPix.extend = .hold
        case .vertical:
            postGradientPix.direction = .vertical
            postGradientPix.extend = .mirror
            postGradientPix.offset = 1.0
        case .angle:
            postGradientPix.direction = .angle
            postGradientPix.offset = 0.75
            postGradientPix.extend = .loop
        case .radial:
            postGradientPix.direction = .radial
            postGradientPix.offset = 1.0
            postGradientPix.extend = .mirror
        }
        postGradientPix.colorSteps = gradient.colorStops.map({ colorStop -> ColorStop in
            ColorStop(colorStop.fraction, PixelColor(colorStop.color.uiColor))
        })
        var index = 0
        RunLoop.current.add(Timer(timeInterval: 0.1, repeats: true, block: { timer in
            guard let image = self.postBlendPix.renderedImage else {
                if index < 10 {
                    index += 1
                    return
                }
                failed()
                timer.invalidate()
                return
            }
            done(image)
            timer.invalidate()
        }), forMode: .common)
    }
    #endif
    
    #if !targetEnvironment(simulator)
    func getPixels() -> PIX.PixelPack? {
        switch direction.axis {
        case .x:
            return resolutionHorizontalPix.renderedPixels
        case .y:
            return resolutionVerticalPix.renderedPixels
        }
    }
    #endif
    
    func captureFailed(with error: Error? = nil) {}
    
    enum SortMethod: String, CaseIterable {
        case date = "Date"
        case hue = "Hue"
        case sat = "Saturation"
        case val = "Brightness"
    }
    
    static func sort(a sgA: SoraGradient, b sgB: SoraGradient, with sortMethod: SortMethod) -> Bool {
        let colorA = gradient(from: sgA)!.averageColor.pixelColor
        let colorB = gradient(from: sgB)!.averageColor.pixelColor
        switch sortMethod {
        case .date:
            return sgA.date! < sgB.date!
        case .hue:
            return colorA.hue < colorB.hue
        case .sat:
            return colorA.saturation < colorB.saturation
        case .val:
            return colorA.brightness < colorB.brightness
        }
    }
    
    static func name(for sg: SoraGradient) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        return "sora \(dateFormatter.string(from: sg.date!))"
    }
    
}
