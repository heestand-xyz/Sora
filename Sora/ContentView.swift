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
    @EnvironmentObject var sora: Sora
    var body: some View {
        ZStack {
            Group {
                #if targetEnvironment(simulator)
                LinearGradient(gradient: Gradient(colors: [.orange, .blue]), startPoint: self.sora.direction == .horizontal ? .leading : .bottom, endPoint: self.sora.direction == .horizontal ? .trailing : .top)
                #else
                RawNODEUI(node: self.sora.backgroundPix)
                #endif
            }
                .opacity(0.25)
                .edgesIgnoringSafeArea(.all)
            VStack {
                GeometryReader { geo in
                    ZStack() {
                        Group {
                            #if targetEnvironment(simulator)
                            LinearGradient(gradient: Gradient(colors: [.orange, .blue]), startPoint: self.sora.direction == .horizontal ? .leading : .bottom, endPoint: self.sora.direction == .horizontal ? .trailing : .top)
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
                            Rectangle()
                                .foregroundColor(.black)
                            #else
                            RawNODEUI(node: self.sora.cameraPix)
                            #endif
                        }
                            .mask(Circle())
                            .offset(y: -geo.size.width / 4)
                    }
                }
                .aspectRatio(1.0 / 1.5, contentMode: .fit)
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
                ZStack {
                    Group {
                        #if targetEnvironment(simulator)
                        LinearGradient(gradient: Gradient(colors: [.orange, .blue]), startPoint: self.sora.direction == .horizontal ? .leading : .bottom, endPoint: self.sora.direction == .horizontal ? .trailing : .top)
                        #else
                        RawNODEUI(node: self.sora.capturePix)
                        #endif
                    }
//                    Color.primary
//                        .opacity(0.5)
                }
                    .mask(Circle())
                    .frame(width: 80, height: 80)
                Spacer()
            }
                .padding(30)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Sora())
    }
}
