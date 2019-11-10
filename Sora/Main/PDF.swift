//
//  PDF.swift
//  Sora
//
//  Created by Hexagons on 2019-11-10.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import PDFKit

class PDF {
    
    static func create(from photo: Main.Photo) throws -> URL {
        
        let format = UIGraphicsPDFRendererFormat()
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
        
            context.beginPage()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 50, weight: .ultraLight)
            ]
            let text = "Sora"
            text.draw(at: CGPoint(x: pageWidth / 2, y: 0), withAttributes: attributes)
        }
        
        let name = Main.name(for: photo)
        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let soraUrl = docUrl.appendingPathComponent("Sora")
        let photoUrl = soraUrl.appendingPathComponent(photo.id.uuidString)
        try FileManager.default.createDirectory(at: photoUrl, withIntermediateDirectories: true, attributes: nil)
        let pdfUrl = photoUrl.appendingPathComponent("\(name).pdf")
        
        try data.write(to: pdfUrl)
        
        return pdfUrl
    }
    
}
