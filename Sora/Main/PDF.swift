//
//  PDF.swift
//  Sora
//
//  Created by Hexagons on 2019-11-10.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import PDFKit
import RenderKit

class PDF {
    
    static func create(from photo: Main.Photo) throws -> URL {
        
        let format = UIGraphicsPDFRendererFormat()
        
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let padding: CGFloat = 100
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
        
            context.beginPage()
            
            photo.gradientImage.draw(in: CGRect(x: padding, y: padding, width: 200, height: 200))
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
            let info = dateFormatter.string(from: photo.date)
            
            let infoText = NSAttributedString(string: info, attributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor(white: 0.0, alpha: 0.5)
            ])
            infoText.draw(at: CGPoint(x: padding, y: 325))
            
            let image = photo.photoImage
            let width = image.size.width
            let croppedImage = Texture.resize(image, to: CGSize(width: width, height: width), placement: .fill)
            croppedImage.draw(in: CGRect(x: padding, y: 400, width: 200, height: 200))
            
            let drawContext = context.cgContext
            for (i, colorStep) in photo.gradient.colorStops.enumerated() {
                
                let x = pageWidth - 250
                let y = padding + CGFloat(i) * 50
                
                drawContext.saveGState()
                drawContext.setFillColor(colorStep.color.uiColor.cgColor)
                drawContext.addEllipse(in: CGRect(x: x, y: y, width: 25, height: 25))
                drawContext.fillPath()
                drawContext.restoreGState()
                
                var r = "\(Int(round(colorStep.color.red * 255)))"
                if r.count == 1 { r = r + "  " } else if r.count == 2 { r = r + " " }
                var g = "\(Int(round(colorStep.color.green * 255)))"
                if g.count == 1 { g = g + "  " } else if g.count == 2 { g = g + " " }
                var b = "\(Int(round(colorStep.color.blue * 255)))"
                if b.count == 1 { b = b + "  " } else if b.count == 2 { b = b + " " }
                let colorTxt = "\(colorStep.color.hex)\nR:\(r) G:\(g) B:\(b)"
                let colorText = NSAttributedString(string: colorTxt, attributes: [
                    .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: UIColor(white: 0.0, alpha: 0.5)
                ])
                colorText.draw(at: CGPoint(x: x + 35, y: y))
                
            }
            
            let footerText = NSAttributedString(string: "sora", attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .regular),
                .foregroundColor: UIColor(white: 0.0, alpha: 0.5)
            ])
            footerText.draw(at: CGPoint(x: (pageWidth - footerText.size().width) / 2, y: pageHeight - footerText.size().height - 25))
            
            
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
