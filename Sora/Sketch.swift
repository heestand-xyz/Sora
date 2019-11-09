//
//  Sketch.swift
//  Sora
//
//  Created by Hexagons on 2019-11-05.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import CoreGraphics
import Zip

class Sketch {
    
    let kId: String = "994B654D-14C7-4395-BEBE-5550E9AC9765"
    let kColorStop: String =
        """
        {
          "_class": "gradientStop",
          "position": <<<position>>>,
          "color": {
            "_class": "color",
            "alpha": 1,
            "blue": <<<blue>>>,
            "green": <<<green>>>,
            "red": <<<red>>>
          }
        }
        """

    let documentJson: String
    let userJson: String
    let metaJson: String
    let pageJson: String
    
    init() {
        
        let documentUrl = Bundle.main.url(forResource: "document", withExtension: "json")!
        documentJson = try! String(contentsOf: documentUrl)
        
        let userUrl = Bundle.main.url(forResource: "user", withExtension: "json")!
        userJson = try! String(contentsOf: userUrl)
        
        let metaUrl = Bundle.main.url(forResource: "meta", withExtension: "json")!
        metaJson = try! String(contentsOf: metaUrl)
        
        let pageUrl = Bundle.main.url(forResource: "page", withExtension: "json")!
        pageJson = try! String(contentsOf: pageUrl)
        
    }
    
    func generate(from photo: Main.Photo, with gradient: Main.Gradient) throws -> URL {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        let name = "Sora \(dateFormatter.string(from: photo.date))"
        
        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let soraUrl = docUrl.appendingPathComponent("Sora")
        let photoUrl = soraUrl.appendingPathComponent(photo.id.uuidString)
        let sketchUrl = photoUrl.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: sketchUrl, withIntermediateDirectories: true, attributes: nil)
        let sketchPagesUrl = sketchUrl.appendingPathComponent("pages")
        try FileManager.default.createDirectory(at: sketchPagesUrl, withIntermediateDirectories: false, attributes: nil)
        let sketchPreviewsUrl = sketchUrl.appendingPathComponent("previews")
        try FileManager.default.createDirectory(at: sketchPreviewsUrl, withIntermediateDirectories: false, attributes: nil)
        
        let documentUrl = sketchUrl.appendingPathComponent("document.json")
        let userUrl = sketchUrl.appendingPathComponent("user.json")
        let metaUrl = sketchUrl.appendingPathComponent("meta.json")
        let pageUrl = sketchPagesUrl.appendingPathComponent("\(kId).json")
        let previewUrl = sketchPreviewsUrl.appendingPathComponent("preview.png")

        
        let documentData = documentJson.data(using: .utf8)!
        try documentData.write(to: documentUrl)
        
        let userData = userJson.data(using: .utf8)!
        try userData.write(to: userUrl)
        
        let metaData = metaJson.data(using: .utf8)!
        try metaData.write(to: metaUrl)
        
        let pageCustomJson = makeCustomPageJson(from: gradient)
        let pageData = pageCustomJson.data(using: .utf8)!
        try pageData.write(to: pageUrl)
        
        if let previewData = photo.gradientImage.pngData() {
            try previewData.write(to: previewUrl)
        }
        
        let zipFilePath = try Zip.quickZipFiles([documentUrl, userUrl, metaUrl, sketchPagesUrl, sketchPreviewsUrl], fileName: name)
        let sketchFilePath = photoUrl.appendingPathComponent("\(name).sketch")
        
        try FileManager.default.moveItem(atPath: zipFilePath.path, toPath: sketchFilePath.path)
        
        return sketchFilePath
        
    }
    
    func makeCustomPageJson(from gradient: Main.Gradient) -> String {
        
        var pageCustomJson = pageJson
        
        let gradientType: Int = gradient.direction == .angle ? 2 : gradient.direction == .radial ? 1 : 0
        pageCustomJson = pageCustomJson.replacingOccurrences(of: "<<<gradientType>>>", with: "\(gradientType)")
        
        let gradientFrom: CGPoint
        switch gradient.direction {
        case .horizontal:
            gradientFrom = CGPoint(x: 0.0, y: 0.5)
        case .vertical:
            gradientFrom = CGPoint(x: 0.5, y: 1.0)
        case .angle:
            gradientFrom = CGPoint(x: 0.5, y: 0.5)
        case .radial:
            gradientFrom = CGPoint(x: 0.5, y: 0.5)
        }
        pageCustomJson = pageCustomJson.replacingOccurrences(of: "<<<gradientFrom>>>", with: "\"{\(gradientFrom.x), \(gradientFrom.y)}\"")
        
        let gradientTo: CGPoint
        switch gradient.direction {
        case .horizontal:
            gradientTo = CGPoint(x: 1.0, y: 0.5)
        case .vertical:
            gradientTo = CGPoint(x: 0.5, y: 0.0)
        case .angle:
            gradientTo = CGPoint(x: 0.5, y: 1.0)
        case .radial:
            gradientTo = CGPoint(x: 0.5, y: 1.0)
        }
        pageCustomJson = pageCustomJson.replacingOccurrences(of: "<<<gradientTo>>>", with: "\"{\(gradientTo.x), \(gradientTo.y)}\"")
        
        let rotation: CGFloat = gradient.direction == .angle ? 90.0 : 0.0
        pageCustomJson = pageCustomJson.replacingOccurrences(of: "<<<rotation>>>", with: "\(rotation)")

        var gradientStops: [String] = []
        for colorStop in gradient.colorStops {
            var gradientStop = kColorStop
            gradientStop = gradientStop.replacingOccurrences(of: "<<<position>>>", with: "\(colorStop.fraction)")
            gradientStop = gradientStop.replacingOccurrences(of: "<<<red>>>", with: "\(colorStop.color.red)")
            gradientStop = gradientStop.replacingOccurrences(of: "<<<green>>>", with: "\(colorStop.color.green)")
            gradientStop = gradientStop.replacingOccurrences(of: "<<<blue>>>", with: "\(colorStop.color.blue)")
            gradientStops.append(gradientStop)
        }
        pageCustomJson = pageCustomJson.replacingOccurrences(of: "<<<gradientStops>>>", with: gradientStops.joined(separator: ","))
        
        return pageCustomJson
        
    }

}
