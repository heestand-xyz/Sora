//
//  DisplayView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct DisplayView: View {
    @ObservedObject var main: Main
    let photo: Main.Photo
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                VStack {
                    GradientTemplateView(main: self.main)
                        .aspectRatio(1.0, contentMode: .fit)
                        .mask(Circle())
                    HStack {
                        ForEach(photo.gradients.first!.colorSteps) { colorStep in
                            VStack {
                                Circle()
                                    .foregroundColor(colorStep.color.color)
                                    .frame(width: 30, height: 30)
                                Text(colorStep.color.hex)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                            }
                        }
                    }
                }
                    .padding(30)
                Spacer()
            }
            PhotoView(photo: main.photos.first!)
                .offset(y: .displayPhotoCornerRadius)
        }
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        let main = Main()
        return DisplayView(main: main, photo: main.photos.first!)
    }
}
