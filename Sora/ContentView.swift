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
    @ObservedObject var sora: Main
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
                    self.sora.direction == .horizontal ? 0 : self.sora.direction == .vertical ? 1 : self.sora.direction == .angle ? 2 : 3
                }, set: { index in
                    self.sora.direction = index == 0 ? .horizontal : index == 1 ? .vertical : index == 2 ? .angle : .radial
                }), label: EmptyView()) {
                    Text("H").tag(0)
                    Text("V").tag(1)
                    Text("A").tag(2)
                    Text("R").tag(3)
                }
                    .pickerStyle(SegmentedPickerStyle())
                Spacer()
                HStack(spacing: 50) {
                    Button(action: {
                        self.sora.state = .preview
                    }) {
                        Group {
                            GradientTemplateView(sora: self.sora)
                        }
                        .mask(Circle())
                            .frame(width: 40, height: 40)
                    }
                    Button(action: {
                        self.sora.capture()
                    }) {
                        Group {
                            #if targetEnvironment(simulator)
                            GradientTemplateView(sora: self.sora)
                            #else
                            RawNODEUI(node: self.sora.capturePix)
                            #endif
                        }
                        .mask(Circle())
                            .frame(width: 60, height: 60)
                            .overlay(Circle().stroke(lineWidth: 5).frame(width: 75, height: 75).foregroundColor(.primary))
                    }
                    Button(action: {
                        
                    }) {
                        Group {
                            Color.primary
                        }
                        .mask(Circle())
                            .frame(width: 40, height: 40)
                    }
                }
                Spacer()
            }
                .padding(30)
        }
    }
}

struct CameraTemplateView: View {
    @ObservedObject var sora: Main
    var body: some View {
        Rectangle()
            .foregroundColor(.black)
    }
}

struct GradientTemplateView: View {
    @ObservedObject var sora: Main
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.orange, .blue]), startPoint: self.sora.direction == .horizontal ? .leading : .bottom, endPoint: self.sora.direction == .horizontal ? .trailing : .top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(sora: Main())
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                ContentView(sora: Main())
                    .colorScheme(.dark)
            }
        }
    }
}
