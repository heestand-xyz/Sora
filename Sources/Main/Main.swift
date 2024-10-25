//
//  Main.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData
import PixelColor
import AsyncGraphics

class Main: ObservableObject {
    
    var persistentContainer: NSPersistentCloudKitContainer!
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    let kRes: Int = 256
    let kSteps: Int = 10
    let kImgRes: CGSize = CGSize(width: 720,
                                 height: 720)
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
    
    @Published var capturing: Bool = false
    
    @Published var sortMethod: SortMethod = .date
    
    let sketch: Sketch
    
    @Published var liveGradient: Gradient?
    @Published var liveTemplateGradient: Gradient!
    
    var bypass: Bool = false {
        didSet {
            #warning("Bypass")
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
    
    @Published private(set) var cameraGraphic: Graphic?
    
    init() {
        
        sketch = Sketch()
        
        liveTemplateGradient = makeTemplateGradient()
        
//        #if DEBUG
//        addTemplates()
//        #endif

//        #if DEBUG
//        deleteAllData()
//        #endif
        
        setupCoreData()
        listenToApp()
        setupCamera()
    }
    
    private func setupCamera() {
        Task {
            do {
                for await graphic in try Graphic.camera(
                    at: .back,
                    lens: .builtInWideAngleCamera,
                    quality: .hd1280x720
                ) {
                    let squareGraphic: Graphic = try await graphic.resized(to: kImgRes, placement: .fill)
                    await MainActor.run {
                        cameraGraphic = squareGraphic
                    }
                    try await process(graphic: squareGraphic)
                }
            } catch {
                print("Camera Failed:", error)
            }
        }
    }
    
    private func process(graphic: Graphic) async throws {
        let gradient = try await makeGradient(at: kSteps, from: graphic, in: direction)
        await MainActor.run {
            liveGradient = gradient
        }
    }
    
    enum CaptureError: Error {
        case cameraGraphicNotFound
        case liveGradientNotFound
    }
    
    func capture() async throws {
        
        print("Sora - Main - Capture")
        
        #if !targetEnvironment(simulator)
        guard let cameraGraphic else {
            throw CaptureError.cameraGraphicNotFound
        }
        guard let liveGradient else {
            throw CaptureError.liveGradientNotFound
        }
        
        let cameraImage: UIImage = try await cameraGraphic.image
        
        let image: UIImage = try await gradientImage(from: liveGradient)
        
        try self.save(gradient: liveGradient, cameraImage: cameraImage, gradientImage: image)
        
        await UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        #else
        
        self.lastSoraGradient = templateSoraGradient()
        
        try! self.save(gradient: liveTemplateGradient, cameraImage: UIImage(named: "photo")!, gradientImage: UIImage(named: "gradient")!)
        
        #endif
        
        let duration = 0.2
        
        withAnimation(.easeOut(duration: duration)) {
            capturing = true
        }
        
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(.easeIn(duration: duration)) {
                self.capturing = false
            }
        }
        
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
    func gradientImage(from gradient: Gradient) async throws -> UIImage {
        let graphic: Graphic = try await .gradient(direction: gradient.direction.ag, stops: gradient.colorStops.map(\.ag), resolution: kImgRes, options: .bit16)
        return try await graphic.image
    }
    #endif
    
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
