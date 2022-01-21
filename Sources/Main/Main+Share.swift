//
//  Share.swift
//  Sora
//
//  Created by Hexagons on 2019-11-10.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

extension Main {
    
    func share(_ item: Any) {
        shareItems = [item]
        showShare = true
    }
    
    func quickLook(_ item: URL) {
        quickLookItems = [item]
        showQuickLook = true
    }
    
    // MARK: - Sketch
    
    func shareSketch() {
        guard let sg = displaySoraGradient else { return }
        guard let gradient = Main.gradient(from: sg) else { return }
        do {
            let file = try sketch.generate(from: sg, with: gradient)
            share(file)
        } catch {
            shareSketchFailed()
        }
    }
    
    func shareSketchFailed() {}
    
    // MARK: - PDF
    
    func sharePDF() {
        guard let sg = displaySoraGradient else { return }
        guard let pdf = try? PDF.create(from: sg) else { return }
        share(pdf)
    }
    
    func quickLookPDF() {
        guard let sg = displaySoraGradient else { return }
        guard let pdf = try? PDF.create(from: sg) else { return }
        quickLook(pdf)
    }
    
    // MARK: - Image
    
    func savePhotoImage() {
        
    }
    
    func saveGradientImage() {
        
    }
    
    func sharePhotoImage() {
        guard let sg = displaySoraGradient else { return }
        shareImage(data: sg.photoImage!, for: sg, as: "jpg")
    }
    
    func shareGradientImage() {
        guard let sg = displaySoraGradient else { return }
        shareImage(data: sg.gradientImage!, for: sg, as: "png")
    }
    
    func shareImage(data: Data, for sg: SoraGradient, as ext: String) {
        
        let name = Main.name(for: sg)
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docsUrl.appendingPathComponent("\(name).\(ext)")
        
        do {
            try data.write(to: url)
            share(url)
        } catch {}
        
    }
    
}
