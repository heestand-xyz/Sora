//
//  ContentView.swift
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

struct ContentView: View {
    @ObservedObject var sora: Sora
    var body: some View {
        ZStack {
            Group {
                #if targetEnvironment(simulator)
                GradientTemplateView(sora: self.sora)
                #else
                RawNODEUI(node: self.sora.backgroundPix)
                #endif
            }
                .opacity(0.25)
                .edgesIgnoringSafeArea(.all)
            VStack {
                LiveView(sora: self.sora)
                Picker(selection: Binding<Int>(get: {
                    self.sora.direction == .horizontal ? 0 : 1
                }, set: { index in
                    self.sora.direction = index == 0 ? .horizontal : .vertical
                }), label: EmptyView()) {
                    Text("Horizontal").tag(0)
                    Text("Vertical").tag(1)
                }
                    .pickerStyle(SegmentedPickerStyle())
                Spacer()
                Group {
                    #if targetEnvironment(simulator)
                    GradientTemplateView(sora: self.sora)
                    #else
                    RawNODEUI(node: self.sora.capturePix)
                    #endif
                }
                    .mask(Circle())
                    .frame(width: 80, height: 80)
                Spacer()
            }
                .padding(30)
        }
    }
}

struct CameraTemplateView: View {
    @ObservedObject var sora: Sora
    var body: some View {
        Rectangle()
            .foregroundColor(.black)
    }
}

struct GradientTemplateView: View {
    @ObservedObject var sora: Sora
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.orange, .blue]), startPoint: self.sora.direction == .horizontal ? .leading : .bottom, endPoint: self.sora.direction == .horizontal ? .trailing : .top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sora: Sora())
    }
}
