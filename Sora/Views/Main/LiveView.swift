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
    @ObservedObject var sora: Main
    var body: some View {
        GeometryReader { geo in
            ZStack() {
                Group {
                    #if targetEnvironment(simulator)
                    GradientTemplateView(sora: self.sora)
                    #else
                    RawNODEUI(node: self.sora.finalPix)
                    #endif
                }
                    .mask(ZStack {
                        Rectangle()
                            .frame(height: geo.size.width / 2)
                            .offset(y: -geo.size.width / 4)
                        Circle()
                    })
                    .offset(y: geo.size.width / 4)
                Group {
                    #if targetEnvironment(simulator)
                    CameraTemplateView(sora: self.sora)
                    #else
                    RawNODEUI(node: self.sora.cameraPix)
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
        LiveView(sora: Main())
    }
}
