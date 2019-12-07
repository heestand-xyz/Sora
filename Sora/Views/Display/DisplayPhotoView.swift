//
//  DisplayPhotoView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-09.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct DisplayPhotoView: View {
    @ObservedObject var main: Main
    let soraGradient: SoraGradient
    let fraction: CGFloat
    let frame: CGRect
    @State var color: Main.Color?
    @State var showColorAlert: Bool = false
    var body: some View {
        VStack(spacing: 25) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .opacity(0.0)
                    GradientView(gradient: self.gradient())
                        .mask(Circle())
                        .offset(x: self.lerp(from: self.frame.minX - geo.frame(in: .global).minX, to: 0.0),
                                y: self.lerp(from: self.frame.minY - geo.frame(in: .global).minY, to: 0.0))
                        .frame(width: self.lerp(from: self.frame.width,
                                                to: geo.size.width),
                               height: self.lerp(from: self.frame.height,
                                                 to: geo.size.height))
                }
            }
                .aspectRatio(1.0, contentMode: .fit)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Rectangle()
                        .opacity(0.0)
                        .frame(width: 20)
                    ForEach(0..<self.gradient().colorStops.count) { i in
                        VStack {
                            Circle()
                                .foregroundColor(self.gradient().colorStops[i].color.color)
                                .frame(width: 30, height: 30)
                            Text(self.gradient().colorStops[i].color.hex)
//                                .foregroundColor(.primary)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
//                        .onLongPressGesture {
//                            let color = self.gradient().colorStops[i].color
//                            self.main.copyColor(color)
//                            self.color = color
//                            self.showColorAlert = true
//                        }
                    }
                    Rectangle()
                        .opacity(0.0)
                        .frame(width: 20)
                }
            }
                .frame(height: 50)
                .opacity(Double(fraction))
                .mask(LinearGradient(gradient: Gradient(stops: [
                    Gradient.Stop(color: .clear, location: 0.0),
                    Gradient.Stop(color: .white, location: 0.15),
                    Gradient.Stop(color: .white, location: 0.85),
                    Gradient.Stop(color: .clear, location: 1.0)
                ]), startPoint: .leading, endPoint: .trailing))
        }
            .padding(30)
        .alert(isPresented: $showColorAlert) { () -> Alert in
            Alert(title: Text("Color \(self.color?.hex ?? "#")"), message: Text("Copied to clipboard."), dismissButton: .default(Text("Ok")))
        }
    }
    func gradient() -> Main.Gradient {
        let gradient = Main.gradient(from: soraGradient)
        if gradient == nil {
            print("Gradient not found in View")
        }
        return gradient!
    }
    func lerp(from fromValue: CGFloat, to toValue: CGFloat) -> CGFloat {
        fromValue * (1.0 - fraction) + toValue * fraction
    }
}

struct DisplayPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        let main = Main()
        return DisplayPhotoView(main: main, soraGradient: Main.templateSoraGradient(), fraction: 1.0, frame: .zero)
    }
}
