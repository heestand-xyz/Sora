//
//  DisplayView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct DisplayView: View {
    let kCacheCount: Int = 10
    let kVelocityLimit: CGFloat = 5.0
    @ObservedObject var main: Main
    enum Dragging {
        case no
        case yes
        case yesX
        case yesY
    }
    @State var dragging: Dragging = .no
    @State var translationCache: [CGPoint] = []
    @State var showShareOptions: Bool = false
    var body: some View {
        ZStack(alignment: .bottom) {
            if main.displayPhoto != nil {
                Color.primary
                    .colorInvert()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(Double(self.main.displayFraction))
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showShareOptions = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                        }
                    }
                        .padding()
                    Spacer()
                }
                VStack {
                    GeometryReader { geo in
                        ZStack {
                            DisplayPhotoView(photo: self.main.displayPhoto!, fraction: self.main.displayFraction, frame: self.main.displayFrame!)
                                .offset(x: self.offsetX(at: geo.size))
                                .gesture(DragGesture()
                                    .onChanged({ value in
                                        self.onDragChange(with: value, at: geo.size)
                                    })
                                    .onEnded({ _ in
                                        self.onDragEnded()
                                    })
                            )
                            if self.main.nextDisplayPhoto != nil {
                                DisplayPhotoView(photo: self.main.nextDisplayPhoto!, fraction: 1.0, frame: .zero)
                                    .offset(x: self.nextOffsetX(at: geo.size))
                            }
                        }
                            .layoutPriority(1)
                    }
                    Spacer()
                }
                if self.photo() != nil {                
                    GeometryReader { geo in
                        PhotoView(photo: self.photo()!)
                            .offset(y: self.comboOffsetY(at: geo.size))
                            .gesture(DragGesture()
                                .onChanged({ value in
                                    self.onDragChange(with: value, at: geo.size, swipe: false)
                                })
                                .onEnded({ _ in
                                    self.onDragEnded(swipe: false)
                                })
                        )
                    }
                    .aspectRatio(.displayPhotoAspectRatio, contentMode: .fit)
                }
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
                    .default(Text("PDF"), action: {
                        self.showShareOptions = false
                        self.main.sharePDF()
                    }),
                    .cancel()
                ])
            })
            .sheet(isPresented: self.$main.showShare) {
                ShareView(items: self.$main.shareItems)
        }
    }
    func onDragChange(with value: DragGesture.Value, at size: CGSize, swipe: Bool = true) {
        if dragging == .no {
            main.reDragPhoto()
            dragging = .yes
        } else {
            if dragging == .yes {
                let firstPos = translationCache.first!
                let lastPos = translationCache.last!
                let diffX = lastPos.x - firstPos.x
                let diffY = lastPos.y - firstPos.y
                if diffX != 0.0 || diffY != 0.0 {
                    dragging = abs(diffX) > abs(diffY) ? .yesX : .yesY
                    if dragging == .yesX && swipe {
                        let way: Main.Way = diffX > 0.0 ? .right : .left
                        main.loadNextDisplayPhoto(in: way)
                    }
                }
            } else if dragging == .yesX && swipe && main.nextDisplayPhoto != nil {
                let x = value.translation.width
                var fraction = min(max(x / size.width, -1.0), 1.0)
                if main.nextDisplayWay == .left {
                    fraction = max(-fraction, 0.0)
                } else if main.nextDisplayWay == .right {
                    fraction = max(fraction, 0.0)
                }
                main.nextDisplayFraction = fraction
            } else if dragging == .yesY {
                let y = value.translation.height
                let fraction = 1.0 - min(max(y / size.height, 0.0), 1.0)
                main.displayFraction = fraction
            }
        }
        if translationCache.count >= kCacheCount {
            translationCache.remove(at: 0)
        }
        translationCache.append(CGPoint(x: value.translation.width,
                                             y: value.translation.height))
    }
    func onDragEnded(swipe: Bool = true) {
        var velocity: CGPoint?
        if translationCache.count >= kCacheCount {
            let fromPos = translationCache.first!
            let toPos = translationCache.last!
            velocity = CGPoint(x: toPos.x - fromPos.x,
                               y: toPos.y - fromPos.y)
        }
        if dragging == .yesX && swipe && main.nextDisplayPhoto != nil {
            if velocity != nil && abs(velocity!.y) > kVelocityLimit {
                if main.nextDisplayWay == .left {
                    if velocity!.x < 0.0 {
                        main.reNext()
                    } else {
                        main.reBack()
                    }
                } else if main.nextDisplayWay == .right {
                    if velocity!.x > 0.0 {
                        main.reNext()
                    } else {
                        main.reBack()
                    }
                }
            } else {
                if (main.nextDisplayFraction ?? 0.0) > 0.5 {
                    main.reNext()
                } else {
                    main.reBack()
                }
            }
        } else if dragging == .yesY {
            if velocity != nil && abs(velocity!.y) > kVelocityLimit {
                if velocity!.y < 0.0 {
                    main.reDisplayPhoto()
                } else {
                    main.reHidePhoto()
                }
            } else {
                if main.displayFraction > 0.5 {
                    main.reDisplayPhoto()
                } else {
                    main.reHidePhoto()
                }
            }
        }
        dragging = .no
        translationCache = []
    }
    func comboOffsetY(at size: CGSize) -> CGFloat {
        if let fraction = main.nextDisplayFraction {
            let waveFraction = cos(fraction * .pi * 2 + .pi) / 2 + 0.5
            return size.height * waveFraction
        }
        return size.height * (1.0 - self.main.displayFraction)
    }
    func offsetX(at size: CGSize) -> CGFloat {
        guard let way = main.nextDisplayWay else { return 0.0 }
        guard let fraction = main.nextDisplayFraction else { return 0.0 }
        if way == .left {
            return -fraction * size.width
        } else {
            return fraction * size.width
        }
    }
    func nextOffsetX(at size: CGSize) -> CGFloat {
        guard let way = main.nextDisplayWay else { return 0.0 }
        guard var fraction = main.nextDisplayFraction else { return 0.0 }
        fraction -= 1.0
        if way == .left {
            return -fraction * size.width
        } else {
            return fraction * size.width
        }
    }
    func photo() -> Main.Photo? {
        let fraction = main.nextDisplayFraction
        if fraction != nil && fraction! > 0.5 {
            return main.nextDisplayPhoto
        }
        return main.displayPhoto
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
