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
    @ObservedObject var main: Main
    var body: some View {
        let gradient = main.makeGradient(at: main.kSteps,
                                         from: Main.Color(red: 1.0, green: 0.5, blue: 0.0),
                                         to: Main.Color(red: 0.0, green: 0.5, blue: 1.0),
                                         in: main.direction)
        return GradientView(gradient: gradient)
    }
}
