//
//  LiveView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import AsyncGraphics

struct LiveView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var main: Main
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                Group {
                    #if targetEnvironment(simulator)
                    GradientTemplateView(main: main)
                    #else
                    if let gradient = main.liveGradient {
                        GradientView(gradient: gradient)
                    }
                    #endif
                }
                .aspectRatio(1.0, contentMode: .fit)
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
                    if let graphic = main.cameraGraphic {
                        GraphicView(graphic: graphic)
                    }
                    #endif
                }
                .mask(Circle())
                .overlay(ZStack {
                    Circle()
                        .fill(.thinMaterial)
                        .mask(
                            ZStack {
                                Circle()
                                    .foregroundColor(.white)
                                let fraction = main.capturing ? 0.0 : 1.0
                                Circle()
                                    .foregroundColor(.black)
                                    .frame(width: geo.size.width * fraction,
                                           height: geo.size.height * fraction)
                            }
                            .compositingGroup()
                            .luminanceToAlpha()
                        )
                })
                .offset(y: -geo.size.width / 4)
                
                RoundedRectangle(cornerRadius: geo.size.width / 2)
                    .foregroundColor(.white)
                    .opacity(main.capturing ? 0.5 : 0.0)
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
