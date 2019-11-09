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
    @State var dragging: Bool = false
    @State var dragPosCache: [CGFloat] = []
    @State var showShareOptions: Bool = false
    var body: some View {
        ZStack(alignment: .bottom) {
            if main.displayPhoto != nil {
                Color.primary
                    .colorInvert()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(Double(self.main.displayFraction))
                VStack {
                    VStack(spacing: 25) {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showShareOptions = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .opacity(0.0)
                                if self.main.displayPhoto != nil {
                                    GradientView(gradient: self.main.displayPhoto!.gradient)
                                        .mask(Circle())
                                        .offset(x: self.lerp(from: self.main.displayFrame!.minX - geo.frame(in: .global).minX, to: 0.0),
                                                y: self.lerp(from: self.main.displayFrame!.minY - geo.frame(in: .global).minY, to: 0.0))
                                        .frame(width: self.lerp(from: self.main.displayFrame!.width,
                                                                to: geo.size.width),
                                               height: self.lerp(from: self.main.displayFrame!.height,
                                                                 to: geo.size.height))
                                }
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
                            .opacity(Double(self.main.displayFraction))
                            .offset(y: (1.0 - self.main.displayFraction) * 200)
                    }
                        .padding(30)
                    Spacer()
                }
                GeometryReader { geo in
                    PhotoView(photo: self.main.displayPhoto!)
                        .offset(y: geo.size.height * (1.0 - self.main.displayFraction))
                        .gesture(DragGesture()
                            .onChanged({ value in
                                if !self.dragging {
                                    self.main.reDragPhoto()
                                }
                                let pos = value.translation.height
                                let fraction = 1.0 - min(max(pos / geo.size.height, 0.0), 1.0)
                                print("fraction", fraction)
                                self.main.displayFraction = fraction
                                self.dragging = true
                                if self.dragPosCache.count >= 10 {
                                    self.dragPosCache.remove(at: 0)
                                }
                                self.dragPosCache.append(pos)
                            })
                            .onEnded({ _ in
                                var velocity: CGFloat?
                                if self.dragPosCache.count >= 10 {
                                    let fromPos = self.dragPosCache.first!
                                    let toPos = self.dragPosCache.last!
                                    print("fromPos", fromPos, "toPos", toPos)
                                    velocity = toPos - fromPos
                                }
                                print("velocity", velocity)
                                if velocity != nil && velocity! > 5.0 {
                                    if velocity! < 0.0 {
                                        self.main.reDisplayPhoto()
                                    } else {
                                        self.main.reHidePhoto()
                                    }
                                } else {
                                    if self.main.displayFraction > 0.5 {
                                        self.main.reDisplayPhoto()
                                    } else {
                                        self.main.reHidePhoto()
                                    }
                                }
                                self.dragging = false
                                self.dragPosCache = []
                            })
                    )
                }
                    .aspectRatio(.displayPhotoAspectRatio, contentMode: .fit)
            }
        }
            .edgesIgnoringSafeArea(.bottom)
            .actionSheet(isPresented: self.$showShareOptions, content: {
                ActionSheet(title: Text("Share Gradient"),
                            message: Text("From \(self.main.displayPhoto?.gradient.colorStops.first?.color.hex ?? "#") to \(self.main.displayPhoto?.gradient.colorStops.last?.color.hex ?? "#")"),
                            buttons: [
                    .default(Text("Photo"), action: {
                        self.showShareOptions = false
                        self.main.sharePhotoImage()
                    }),
                    .default(Text("Gradient"), action: {
                        self.showShareOptions = false
                        self.main.shareGradientImage()
                    }),
                    .default(Text("Sketch"), action: {
                        self.showShareOptions = false
                        self.main.shareSketch()
                    }),
                    .cancel()
                ])
            })
            .sheet(isPresented: self.$main.showShare) {
                ShareView(items: self.$main.shareItems)
        }
    }
    func color(at index: Int) -> Main.Color {
        let relIndex = index * 3
        let colorStops = main.displayPhoto!.gradient.colorStops
        guard relIndex < colorStops.count else {
            return colorStops.last!.color
        }
        return colorStops[relIndex].color
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
