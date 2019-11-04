//
//  DisplayView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct DisplayView: View {
    @ObservedObject var main: Main
    var body: some View {
        ZStack(alignment: .bottom) {
            if main.displayPhoto != nil {
                Color.primary
                    .colorInvert()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(Double(self.main.displayFraction))
                VStack {
                    VStack(spacing: 25) {
                        GeometryReader { geo in
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .opacity(0.0)
                                GradientView(gradient: self.main.displayPhoto!.gradients.first!)
                                    .mask(Circle())
                                    .offset(x: self.lerp(from: self.main.displayFrame!.minX - geo.frame(in: .global).minX, to: 0.0),
                                            y: self.lerp(from: self.main.displayFrame!.minY - geo.frame(in: .global).minY, to: 0.0))
                                    .frame(width: self.lerp(from: self.main.displayFrame!.width,
                                                            to: geo.size.width),
                                           height: self.lerp(from: self.main.displayFrame!.height,
                                                             to: geo.size.height))
                            }
                        }
                            .aspectRatio(1.0, contentMode: .fit)
                        HStack {
                            ForEach(main.displayPhoto!.gradients.first!.colorSteps) { colorStep in
                                VStack {
                                    Circle()
                                        .foregroundColor(colorStep.color.color)
                                        .frame(width: 30, height: 30)
                                    Text(colorStep.color.hex)
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                }
                            }
                        }
                            .opacity(Double(self.main.displayFraction))
                            .offset(y: (1.0 - self.main.displayFraction) * 200)
                    }
                        .padding(30)
                    Spacer()
                }
                GeometryReader { geo in
                    PhotoView(photo: self.main.photos.first!)
                        .offset(y: geo.size.height * (1.0 - self.main.displayFraction))
                        .gesture(DragGesture()
                            .onChanged({ value in
                                let fraction = min(max(value.translation.height / geo.size.height, 0.0), 1.0)
                                self.main.displayFraction = 1.0 - fraction
                            })
                            .onEnded({ _ in
                                if self.main.displayFraction > 0.5 {
                                    self.main.reDisplayPhoto()
                                } else {
                                    self.main.reHidePhoto()
                                }
                            })
                    )
                }
                    .aspectRatio(.displayPhotoAspectRatio, contentMode: .fit)
            }
        }
            .edgesIgnoringSafeArea(.bottom)
    }
    func lerp(from fromValue: CGFloat, to toValue: CGFloat) -> CGFloat {
        fromValue * (1.0 - main.displayFraction) + toValue * main.displayFraction
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        let main = Main()
        let photo = main.photos.last!
        let frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        main.displayPhoto = photo
        main.displayFrame = frame
        main.displayFraction = 1.0
//        main.display(photo: photo, from: frame)
        return DisplayView(main: main)
    }
}
