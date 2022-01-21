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
                GradientView(gradient: self.main.liveGradient)
                #endif
            }
                .opacity(0.25)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                
                LiveView(main: self.main)
                    .offset(y: -80)
                
                HStack {
                    Button(action: {
                        self.main.direction = .horizontal
                    }) {
                       Image("gradient_horizontal")
                        .foregroundColor(.primary)
                        .opacity(self.main.direction == .horizontal ? 1.0 : 0.2)
                    }
                    Button(action: {
                        self.main.direction = .vertical
                    }) {
                       Image("gradient_vertical")
                        .foregroundColor(.primary)
                        .opacity(self.main.direction == .vertical ? 1.0 : 0.2)
                    }
                    Button(action: {
                        self.main.direction = .angle
                    }) {
                        Image("gradient_angle")
                            .foregroundColor(.primary)
                            .opacity(self.main.direction == .angle ? 1.0 : 0.2)
                    }
                    Button(action: {
                        self.main.direction = .radial
                    }) {
                        Image("gradient_radial")
                            .foregroundColor(.primary)
                            .opacity(self.main.direction == .radial ? 1.0 : 0.2)
                    }

                }
                
                Spacer()
                
                HStack(spacing: 50) {
                    
                    if self.main.lastSoraGradient != nil {
                        GeometryReader { geo in
                            Button(action: {
                                self.main.display(sg: self.main.lastSoraGradient!, from: geo.frame(in: .global))
                            }) {
                                GradientView(gradient: Main.gradient(from: self.main.lastSoraGradient!)!)
                                    .mask(Circle())
                                    .opacity(self.main.displaySoraGradient == nil ? 1.0 : 0.0)
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
                            GradientView(gradient: self.main.liveGradient)
                            #endif
                        }
                        .mask(Circle())
                            .frame(width: 60, height: 60)
                            .overlay(Circle().stroke(lineWidth: 5).frame(width: 75, height: 75).foregroundColor(.primary))
                    }
                    
                    NavigationLink(destination: GeometryReader { geo in
                            GridView(main: self.main)
                                .frame(height: geo.size.height + 50)
                                .offset(y: -25)
                        }, isActive: Binding<Bool>(get: {
                        self.main.state == .grid
                    }, set: { active in
                        self.main.state = active ? .grid : .capture
                    })) {
                        Image(systemName: "folder")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
            }
                .padding(10)
        }
    }
}

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView(main: Main())
    }
}
