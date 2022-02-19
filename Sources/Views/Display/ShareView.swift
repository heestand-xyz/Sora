//
//  ShareView.swift
//  Sora
//
//  Created by 松原明香 on 2019/11/10.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct ShareView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var main: Main
    let soraGradient: SoraGradient
    let close: () -> ()
    var body: some View {
        VStack {
            
            Text("Share Options")
                .font(.system(size: 18, weight: .bold))
                .frame(height: 60.0)
            
            
            Divider()
            
            
            HStack {
                Spacer()
                ShareOption(
                    text:"Gradient",
                    imagename: {
                        if let direction = soraGradient.direction {
                            switch direction {
                            case .horizontal:
                                return "gradient_horizontal"
                            case .vertical:
                                return "gradient_vertical"
                            case .angle:
                                return "gradient_angle"
                            case .radial:
                                return "gradient_radial"
                            }
                        }
                        return ""
                    }(),
                    download: { self.main.saveGradientImage() },
                    share: { self.main.shareGradientImage() },
                    quicklook: nil)
                    .frame(width: 100.0)
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                ShareOption(
                    text:"Photo",
                    imagename: "share_photo",
                    download: { self.main.savePhotoImage() },
                    share: { self.main.sharePhotoImage() },
                    quicklook: nil)
                    .frame(width: 100.0)
                
                Spacer()
            }
            .frame(height: 200)
            
            
            Divider()
            
            
            HStack {
                
                Spacer()
                
                ShareOption(
                    text:"Sketch",
                    imagename: "share_sketch",
                    download: nil,
                    share: { self.main.shareSketch() },
                    quicklook: nil)
                    .frame(width: 100.0)
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                ShareOption(
                    text:"PDF",
                    imagename: "share_pdf",
                    download: nil,
                    share: { self.main.sharePDF() },
                    quicklook: { self.main.quickLookPDF() })
                    .frame(width: 100.0)
                
                Spacer()
                
            }
            .frame(height: 200)
            
            VStack{
                
                Divider()
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    close()
                    Timer.scheduledTimer(withTimeInterval: main.kAnimationSeconds + 0.01, repeats: false) { _ in
                        self.main.delete(soraGradient: self.soraGradient)
                    }
                }) {
                    Text("Delete")
                        .font(.system(size: 18, weight: .bold))
                        .accentColor(Color(red: 2.0, green: 0.3, blue: 0.1, opacity: 1.0))
                        .frame(height: 40.0)
                    
                }
                Spacer()
                
                Divider()
                Spacer()
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .bold))
                        .frame(height: 40.0)
                        .accentColor(.gray)
                    
                }
                Spacer()
                
            }
            
            
        }
        .padding(.all, 20.0)
        .sheet(isPresented: Binding<Bool>(get: {
            self.main.showShare || self.main.showQuickLook
        }, set: { active in
            if !active {
                self.main.showShare = false
                self.main.showQuickLook = false
            }
        })) {
            Group {
                if self.main.showShare {
                    ShareSheetView(items: self.$main.shareItems)
                } else if self.main.showQuickLook {
                    QuickLookView(items: self.$main.quickLookItems)
                }
            }
        }
    }
}


struct ShareOption:View {
    let text:String
    let imagename:String
    let download:(() -> ())?
    let share:(() -> ())?
    let quicklook:(() -> ())?
    var body: some View {
        VStack {
            VStack {
                Image(imagename)
                    .renderingMode(.template)
                Text(text)
                    .padding(.bottom, 10.0)
            }
            HStack {
                HStack {
                    if share != nil{
                        Button(action: share!) {
                            Image(systemName: "square.and.arrow.up")
                                .padding(.trailing, 3.0)
                                .font(.system(size: 22))
                                .accentColor(Color(red: 0.0, green: 0.5, blue: 0.7, opacity: 1.0))
                            
                            
                            
                            
                        }
                    }
                    if download != nil{
                        Button(action: download!) {
                            Image(systemName:"square.and.arrow.down")
                                .font(.system(size: 22))
                                .accentColor(Color(red: 0.0, green: 0.5, blue: 0.7, opacity: 1.0))
                            
                        }
                    }
                    if quicklook != nil{
                        Button(action: quicklook!) {
                            Image(systemName:"eye")
                                .padding(.top, 8.0)
                                .font(.system(size: 22))
                                .accentColor(Color(red: 0.0, green: 0.5, blue: 0.7, opacity: 1.0))
                        }
                    }
                    
                    
                }
                
            }
        }
        
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        let main = Main()
        return ShareView(main: main, soraGradient: main.templateSoraGradient(), close: {})
    }
}
