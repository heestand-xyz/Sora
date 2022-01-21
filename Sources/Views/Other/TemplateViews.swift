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
            .aspectRatio(contentMode: .fit)
    }
}

struct GradientTemplateView: View {
    @ObservedObject var main: Main
    var body: some View {
        GradientView(gradient: main.liveTemplateGradient)
    }
}
