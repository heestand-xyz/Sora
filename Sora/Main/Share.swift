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
    
    func shareSketch() {
        guard let photo = displayPhoto else { return }
        do {
            let file = try sketch.generate(from: photo, with: photo.gradient)
            share(file)
        } catch {
            shareSketchFailed()
        }
    }
    
    func sharePDF() {
        guard let photo = displayPhoto else { return }
        guard let pdf = try? PDF.create(from: photo) else { return }
        share(pdf)
    }
    
    func sharePhotoImage() {
        guard let photo = displayPhoto else { return }
        guard let data = photo.photoImage.jpegData(compressionQuality: 0.8) else { return }
        shareImage(data: data, for: photo, as: "jpg")
    }
    
    func shareGradientImage() {
        guard let photo = displayPhoto else { return }
        guard let data = photo.gradientImage.pngData() else { return }
        shareImage(data: data, for: photo, as: "png")
    }
    
    func shareImage(data: Data, for photo: Photo, as ext: String) {
        
        let name = Main.name(for: photo)
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docsUrl.appendingPathComponent("\(name).\(ext)")
        
        do {
            try data.write(to: url)
            share(url)
        } catch {}
        
    }
    
    func shareSketchFailed() {}
    
}
