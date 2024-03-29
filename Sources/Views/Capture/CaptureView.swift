//
//  CaptureView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import AsyncGraphics

struct CaptureView: View {
    
    @ObservedObject var main: Main
    
    @State private var capturing: Bool = false
    
    var body: some View {
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
            .opacity(0.25)
            .edgesIgnoringSafeArea(.all)
            
//            Color.white
//                .opacity(main.capturing ? 0.5 : 0.0)
//                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {

                Spacer()
                
                LiveView(main: self.main)
                    
                Spacer()
                
                HStack {
                    Button(action: {
                        self.main.direction = .horizontal
                    }) {
                        Image("gradient_horizontal")
                            .foregroundColor(.white)
                            .opacity(self.main.direction == .horizontal ? 1.0 : 0.2)
                    }
                    Button(action: {
                        self.main.direction = .vertical
                    }) {
                        Image("gradient_vertical")
                            .foregroundColor(.white)
                            .opacity(self.main.direction == .vertical ? 1.0 : 0.2)
                    }
                    Button(action: {
                        self.main.direction = .angle
                    }) {
                        Image("gradient_angle")
                            .foregroundColor(.white)
                            .opacity(self.main.direction == .angle ? 1.0 : 0.2)
                    }
                    Button(action: {
                        self.main.direction = .radial
                    }) {
                        Image("gradient_radial")
                            .foregroundColor(.white)
                            .opacity(self.main.direction == .radial ? 1.0 : 0.2)
                    }   
                }
                
                Spacer()
                    .frame(height: 20)
                                
                HStack {
            
                    HStack {
                        
                        Spacer()
                        
                        recentView
                        
                        Spacer()
                    }
                    
                    captureView
                    
                    HStack {
                        
                        Spacer()
                        
                        folderView
                        
                        Spacer()
                            .frame(width: 25)
                        
                        cameraView
                    }
                }
                .padding(.horizontal, 20)
            
                Spacer()
                    .frame(height: 20)
            }
        }
    }
    
    var captureView: some View {
        Button {
            capture()
        } label: {
            Circle()
                .fill(.white)
                .frame(width: 60, height: 60)
                .overlay {
                    Circle()
                        .stroke(lineWidth: 5)
                        .fill(.white)
                        .frame(width: 75, height: 75)
                }
        }
        .disabled(capturing)
    }
    
    @ViewBuilder
    var recentView: some View {
        if self.main.lastSoraGradient != nil {
            GeometryReader { geo in
                Button(action: {
                    self.main.display(sg: self.main.lastSoraGradient!, from: geo.frame(in: .global))
                }) {
                    GradientView(gradient: Main.gradient(from: self.main.lastSoraGradient!)!)
                        .mask(Circle())
                        .opacity(self.main.displaySoraGradient == nil ? 1.0 : 0.0)
                        .overlay {
                            Circle()
                                .stroke(lineWidth: 2)
                                .fill(.white)
                        }
                }
            }
            .frame(width: 40, height: 40)
        } else {
            Color.clear
                .frame(width: 40, height: 40)
        }
    }
    
    var folderView: some View {
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
                .foregroundColor(.white)
        }
    }
    
    var cameraView: some View {
        ZStack {
            Rectangle()
                .fill(.black)
            #if targetEnvironment(simulator)
            CameraTemplateView()
            #else
            if let graphic = main.cameraGraphic {
                GraphicView(graphic: graphic)
            }
            #endif
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .frame(width: 60, height: 60)
    }
    
    private func capture() {
        capturing = true
        Task {
            do {
                try await main.capture()
            } catch {
                print("Capture Failed:", error)
            }
            capturing = false
        }
    }
}

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView(main: Main())
    }
}
