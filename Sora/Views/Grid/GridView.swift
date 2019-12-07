//
//  GridView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct GridView: View {
    @FetchRequest(fetchRequest: SoraGradient.fetchRequest()) var soraGradients: FetchedResults<SoraGradient>
    let kColCount = 3
    @ObservedObject var main: Main
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: self.iPhoneScreen(min: 20, max: 25)) {
                    ForEach(0..<rowCount()) { i in
                        HStack(spacing: self.iPhoneScreen(min: 20, max: 25)) {
                            ForEach(0..<self.kColCount) { j in
                                if self.index(row: i, col: j) != nil {
                                    GeometryReader { geo in
                                        Button(action: {
                                            self.main.display(sg: self.soraGradient(row: i, col: j)!, from: geo.frame(in: .global))
                                        }) {
                                            GradientView(gradient: Main.gradient(from: self.soraGradient(row: i, col: j)!)!)
                                                .mask(Circle())
                                                .opacity(self.main.displaySoraGradient == self.soraGradient(row: i, col: j)! ? 0.0 : 1.0)
                                                .onAppear {
                                                    self.main.gridFrames[self.soraGradient(row: i, col: j)!.id!] = geo.frame(in: .global)
                                                }
                                        }
                                    }
                                    .frame(width: self.iPhoneScreen(min: 75, max: 95),
                                           height: self.iPhoneScreen(min: 75, max: 95))
                                }
                            }
                        }
                    }
                }
            }
            VStack {
//                HStack {
//                    Button(action: {
//                        self.main.state = .capture
//                    }) {
//                        Image(systemName: "arrow.left")
//                            .font(.title)
//                            .foregroundColor(.primary)
//                    }
//                    Spacer()
//                }
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
        Int(ceil(CGFloat(soraGradients.count) / CGFloat(kColCount)))
    }
    func index(row rowIndex: Int, col colIndex: Int) -> Int? {
        let index = rowIndex * kColCount + colIndex
        guard index < soraGradients.count else { return nil }
        return index
    }
    func soraGradient(row rowIndex: Int, col colIndex: Int) -> SoraGradient? {
        guard let i = index(row: rowIndex, col: colIndex) else { return nil }
        return soraGradients[i]
    }
    func iPhoneScreen(min:CGFloat,max:CGFloat) -> CGFloat {
        let Min : CGFloat = 640
        let Max : CGFloat = 1242
        let fraction = (UIScreen.main.nativeBounds.width - Min) / (Max - Min)
        return min * (1 - fraction) + max * fraction
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(main: Main())
    }
}
