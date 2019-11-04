//
//  TemplateViews.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct CameraTemplateView: View {
    var body: some View {
        PhotoTemplateView()
            .aspectRatio(1.0, contentMode: .fit)
    }
}

struct PhotoTemplateView: View {
    var body: some View {
        Image("photo")
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

struct GradientTemplateView: View {
    @ObservedObject var sora: Main
    var body: some View {
        let gradient = Gradient(colors: [.orange, .blue])
        return Group {
            if sora.direction == .horizontal {
                LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
            } else if sora.direction == .vertical {
                LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
            } else if sora.direction == .angle {
                AngularGradient(gradient: gradient, center: .center, angle: Angle(radians: -.pi / 2))
            } else if sora.direction == .radial {
                GeometryReader { geo in
                    RadialGradient(gradient: gradient, center: .center, startRadius: 0.0, endRadius: geo.size.width / 2)
                }
            }
        }
    }
}
