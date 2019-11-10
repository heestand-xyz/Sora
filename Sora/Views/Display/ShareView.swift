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
    let photo: Main.Photo
    var body: some View {
        VStack {
            
            Text("Share Options")
            
            
            Divider()
            
           
            HStack {
                 Spacer()
                ShareOption(
                    text:"Gradient",
                    imagename: "gradient_vertical",
                    download: { self.main.saveGradientImage() },
                    share: { self.main.shareGradientImage() },
                    quicklook: nil)
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                ShareOption(
                    text:"Photo",
                    imagename: "gradient_vertical",
                    download: { self.main.savePhotoImage() },
                    share: { self.main.sharePhotoImage() },
                    quicklook: nil)
                Spacer()
            }
            .frame(height: 200)
            
            
            Divider()
            
            
            HStack {
                
                Spacer()
                
                ShareOption(
                text:"Sketch",
                imagename: "gradient_vertical",
                    download: nil,
                    share: { self.main.shareSketch() },
                    quicklook: nil)
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                ShareOption(
                text:"PDF",
                imagename: "gradient_vertical",
                    download: nil,
                    share: { self.main.sharePDF() },
                    quicklook: { self.main.quickLookPDF() })
                
                Spacer()
                
            }
            .frame(height: 200)
            
            VStack{

                 Divider()
                 
                 Spacer()
                 
                 Button(action: {
                    self.main.delete(photo: self.photo)
                 }) {
                    Text("Delete")
                        .accentColor(/*@START_MENU_TOKEN@*/.red/*@END_MENU_TOKEN@*/)
                    
                 }
                 Spacer()
                 
                 Divider()
                 Spacer()
                 
                 Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                 }) {
                     Text("Cancel")
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
                Text(text)
            }
            HStack {
                HStack {
                    if share != nil{
                    Button(action: share!) {
                         Image(systemName: "square.and.arrow.up")
                        }
                    }
                    if download != nil{
                        Button(action: download!) {
                            Image(systemName:"square.and.arrow.down")
                        }
                    }
                   if quicklook != nil{
                    Button(action: quicklook!) {
                        Image(systemName:"eye")
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
        return ShareView(main: main, photo: main.photos.last!)
    }
}
