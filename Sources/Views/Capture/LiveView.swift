//
//  LiveView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
#if !targetEnvironment(simulator)
import RenderKit
import PixelKit
#endif

struct LiveView: View {
    @ObservedObject var main: Main
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Group {
                    #if targetEnvironment(simulator)
                    GradientTemplateView(main: self.main)
                        .aspectRatio(1.0, contentMode: .fit)
                    #else
//                    RawNODEUI(node: self.main.finalPix)
                    GradientView(gradient: self.main.liveGradient)
                    #endif
                }
                .mask(ZStack {
                    Rectangle()
                        .frame(height: geo.size.width / 2)
                        .offset(y: -geo.size.width / 4)
                    Circle()
                })
                .offset(y: geo.size.width / 4)
                ZStack {
                    Circle()
                        .foregroundColor(.gray)
                    #if targetEnvironment(simulator)
                    CameraTemplateView()
                    #else
                    PixelView(pix: self.main.cameraPix)
                    #endif
                }
                .mask(Circle())
                .offset(y: -geo.size.width / 4)
            }
        }
        .aspectRatio(1.0 / 1.5, contentMode: .fit)
    }
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView(main: Main())
    }
}
