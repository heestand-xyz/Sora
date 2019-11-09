//
//  CaptureView.swift
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

struct CaptureView: View {
    @ObservedObject var main: Main
    var body: some View {
        ZStack {
            Group {
                #if targetEnvironment(simulator)
                GradientTemplateView(main: self.main)
                #else
                GradientView(gradient: self.main.liveGaradient)
                #endif
            }
                .opacity(0.25)
                .edgesIgnoringSafeArea(.all)
            VStack {
                LiveView(main: self.main)
                Picker(selection: Binding<Int>(get: {
                    self.main.direction == .horizontal ? 0 : self.main.direction == .vertical ? 1 : self.main.direction == .angle ? 2 : 3
                }, set: { index in
                    self.main.direction = index == 0 ? .horizontal : index == 1 ? .vertical : index == 2 ? .angle : .radial
                }), label: EmptyView()) {
                    Text("H").tag(0)
                    Text("V").tag(1)
                    Text("A").tag(2)
                    Text("R").tag(3)
                }
                    .pickerStyle(SegmentedPickerStyle())
                Spacer()
                HStack(spacing: 50) {
                    if !main.photos.isEmpty {
                        GeometryReader { geo in
                            Button(action: {
                                self.main.display(photo: self.main.photos.last!, from: geo.frame(in: .global))
                            }) {
                                GradientView(gradient: self.main.photos.last!.gradient)
                                    .mask(Circle())
                                    .opacity(self.main.displayPhoto == nil ? 1.0 : 0.0)
                            }
                        }
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .opacity(0.0)
                            .frame(width: 40, height: 40)
                    }
                    Button(action: {
                        self.main.capture()
                    }) {
                        Group {
                            #if targetEnvironment(simulator)
                            GradientTemplateView(main: self.main)
                            #else
                            GradientView(gradient: self.main.liveGaradient)
                            #endif
                        }
                        .mask(Circle())
                            .frame(width: 60, height: 60)
                            .overlay(Circle().stroke(lineWidth: 5).frame(width: 75, height: 75).foregroundColor(.primary))
                    }
                    Button(action: {
                        self.main.state = .grid
                    }) {
                        Color.primary
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

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView(main: Main())
    }
}
