//
//  DisplayPhotoView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-09.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct DisplayPhotoView: View {
    let photo: Main.Photo
    let fraction: CGFloat
    let frame: CGRect
    var body: some View {
        VStack(spacing: 25) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .opacity(0.0)
                    GradientView(gradient: self.photo.gradient)
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
                    ForEach(0..<self.photo.gradient.colorStops.count) { i in
                        VStack {
                            Circle()
                                .foregroundColor(self.photo.gradient.colorStops[i].color.color)
                                .frame(width: 30, height: 30)
                            Text(self.photo.gradient.colorStops[i].color.hex)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                    }
                    Rectangle()
                        .opacity(0.0)
                        .frame(width: 20)
                }
            }
                .frame(height: 50)
                .opacity(Double(fraction))
                .offset(y: (1.0 - fraction) * 200)
                .mask(LinearGradient(gradient: Gradient(stops: [
                    Gradient.Stop(color: .clear, location: 0.0),
                    Gradient.Stop(color: .white, location: 0.15),
                    Gradient.Stop(color: .white, location: 0.85),
                    Gradient.Stop(color: .clear, location: 1.0)
                ]), startPoint: .leading, endPoint: .trailing))
        }
            .padding(30)
    }
    func lerp(from fromValue: CGFloat, to toValue: CGFloat) -> CGFloat {
        fromValue * (1.0 - fraction) + toValue * fraction
    }
}

struct DisplayPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayPhotoView(photo: Main().photos.first!, fraction: 1.0, frame: .zero)
    }
}
