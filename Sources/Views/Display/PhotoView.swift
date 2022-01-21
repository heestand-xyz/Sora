//
//  PhotoView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct PhotoView: View {
    let soraGradient: SoraGradient
    var body: some View {
        
        GeometryReader { geo in
            GeometryReader { _ in
                ZStack{
                    Image(uiImage: UIImage(data: self.soraGradient.photoImage!)!)
                        .resizable()
                        .scaledToFill()
                    LinearGradient(gradient: Gradient(colors: [.black, .clear])
                        , startPoint: .top, endPoint: .center)
                        .opacity(0.75)
                    VStack {
                        HStack{
                            Image({
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
                            }())
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .padding(.trailing, 10.0)
                            VStack(alignment: .leading){
                                Text(self.date())
                                    .font(.system(size: 24, weight: .regular))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 1.0)
                                Text(self.time())
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white)
            
                           }
                       Spacer()}
                    Spacer()
                    }
                    .padding([.top], 40.0)
                    .padding([.leading], 50.0)
                    //.frame(width: 320.0, height: 260.0)
                    
                }
                
            }
            
                .mask(ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: .displayPhotoCornerRadius)
                    Rectangle()
                        .frame(height: .displayPhotoCornerRadius)
                   
                    
                    }
            )
        }
        .aspectRatio(.displayPhotoAspectRatio, contentMode: .fit)
    }
    func date() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return "\(dateFormatter.string(from: soraGradient.date!))"
    }
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return "\(dateFormatter.string(from: soraGradient.date!))"
    }
    
    
    
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(soraGradient: Main().templateSoraGradient())
    }
}
