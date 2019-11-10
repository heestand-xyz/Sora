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
            HStack {
                ForEach(0..<4) { i in
                    VStack {
                        Circle()
                            .foregroundColor(self.color(at: i).color)
                            .frame(width: 30, height: 30)
                        Text(self.color(at: i).hex)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                }
            }
            .opacity(Double(fraction))
            .offset(y: (1.0 - fraction) * 200)
        }
            .padding(30)
    }
    func color(at index: Int) -> Main.Color {
        let relIndex = index * 3
        let colorStops = photo.gradient.colorStops
        guard relIndex < colorStops.count else {
            return colorStops.last!.color
        }
        return colorStops[relIndex].color
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
