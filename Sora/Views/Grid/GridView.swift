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
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(0..<rowCount()) { i in
                        HStack(spacing: 20) {
                            ForEach(0..<self.kColCount) { j in
                                if self.index(row: i, col: j) != nil {
                                    GeometryReader { geo in
                                        Button(action: {
                                            self.main.display(photo: self.photo(row: i, col: j)!, from: geo.frame(in: .global))
                                        }) {
                                            GradientView(gradient: self.photo(row: i, col: j)!.gradient)
                                                .mask(Circle())
                                                .opacity(self.main.displayPhoto == self.photo(row: i, col: j)! ? 0.0 : 1.0)
                                                .onAppear {
                                                    self.main.gridFrames[self.photo(row: i, col: j)!.id] = geo.frame(in: .global)
                                                }
                                        }
                                    }
                                    .frame(width: 75, height: 75)
                                }
                            }
                        }
                    }
                }
            }
            VStack {
                HStack {
                    Button(action: {
                        self.main.state = .capture
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                Spacer()
                Picker(selection: Binding<Int>(get: {
                    Main.SortMethod.allCases.firstIndex(of: self.main.sortMethod)!
                }, set: { index in
                    self.main.sortMethod = Main.SortMethod.allCases[index]
                }), label: EmptyView()) {
                    ForEach(0..<Main.SortMethod.allCases.count) { i in
                        Text(Main.SortMethod.allCases[i].rawValue).tag(i)
                    }
                }
                    .pickerStyle(SegmentedPickerStyle())
            }
                .padding()
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
    func photo(row rowIndex: Int, col colIndex: Int) -> Main.Photo? {
        guard let i = index(row: rowIndex, col: colIndex) else { return nil }
        return main.photos[i]
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(main: Main())
    }
}
