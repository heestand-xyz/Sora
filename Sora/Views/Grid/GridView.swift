//
//  GridView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct GridView: View {
    let kColCount = 4
    @ObservedObject var main: Main
    @State var heroFrame: CGRect?
    @State var heroIndex: Int?
    @State var frames: [CGRect] = []
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(0..<rowCount()) { i in
                    HStack(spacing: 20) {
                        ForEach(0..<self.kColCount) { j in
                            if self.index(row: i, col: j) != nil {
                                Button(action: {
                                    self.heroIndex = self.index(row: i, col: j)!
                                }) {
                                    GeometryReader { geo in
                                        ZStack {
                                            GradientView(gradient: self.main.photos[self.index(row: i, col: j)!].gradients.first!)
                                                .mask(Circle())
                                                .onAppear {
                                                    self.frames.append(geo.frame(in: .global))
                                            }
                                        }
                                    }
                                        .frame(width: 80, height: 80)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func rowCount() -> Int {
        Int(ceil(CGFloat(main.photos.count) / CGFloat(kColCount)))
    }
    func index(row rowIndex: Int, col colIndex: Int) -> Int? {
        let index = rowIndex * kColCount + colIndex
        guard index < main.photos.count else { return nil }
        return index
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(main: Main())
    }
}
