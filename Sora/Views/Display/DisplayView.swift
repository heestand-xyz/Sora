//
//  DisplayView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct DisplayView: View {
    @ObservedObject var sora: Main
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                VStack {
                    GradientTemplateView(sora: self.sora)
                        .aspectRatio(1.0, contentMode: .fit)
                        .mask(Circle())
                    HStack {
                        ForEach(sora.photos.first!.gradients.first!.colorSteps) { colorStep in
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
            PhotoView(photo: sora.photos.first!)
                .offset(y: .displayPhotoCornerRadius)
        }
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(sora: Main())
    }
}
