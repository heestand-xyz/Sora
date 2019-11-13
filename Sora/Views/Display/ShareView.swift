//
//  ShareView.swift
//  Sora
//
//  Created by 松原明香 on 2019/11/10.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct ShareView: View {
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
                    imagename: "gradient_vertical",
                    download:{},
                    share:{},
                    quicklook: nil)
                    .frame(width: 100.0)
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                ShareOption(
                    text:"Photo",
                    imagename: "share_photo",
                    download:{},
                    share:{},
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
                    share:{},
                    quicklook: nil)
                    .frame(width: 100.0)
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                ShareOption(
                text:"PDF",
                imagename: "share_pdf",
                    download: nil,
                    share:{},
                    quicklook:{})
                    .frame(width: 100.0)
                
                Spacer()
                
            }
            .frame(height: 200)
            
            VStack{

                 Divider()
                 
                 Spacer()
                 
                 Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                    Text("Delete")
                        .font(.system(size: 18, weight: .bold))
                        .accentColor(Color(red: 2.0, green: 0.3, blue: 0.1, opacity: 1.0))
                        .frame(height: 40.0)
                    
                 }
                 Spacer()
                 
                 Divider()
                 Spacer()
                 
                 Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                     Text("Cancel")
                    .font(.system(size: 18, weight: .bold))
                     .frame(height: 40.0)
                        .accentColor(.gray)
                    
                 }
                 Spacer()
                
            }
              
            
        }
        .padding(.all, 30.0)
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
        ShareView()
    }
}
