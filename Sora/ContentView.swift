//
//  ContentView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import PixelKit

struct ContentView: View {
    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack() {
                    LinearGradient(gradient: Gradient(colors: [.orange, .blue]), startPoint: .bottom, endPoint: .top)
                        .mask(ZStack {
                            Rectangle()
                                .frame(height: geo.size.width / 2)
                                .offset(y: -geo.size.width / 4)
                            Circle()
                        })
                        .offset(y: geo.size.width / 4)
                    Group {
                        #if targetEnvironment(simulator)
                        Rectangle()
                            .foregroundColor(.black)
                        #else
                        CameraPIXUI()
                        #endif
                    }
                        .mask(Circle())
                        .offset(y: -geo.size.width / 4)
                }
            }
            .aspectRatio(1.0 / 1.5, contentMode: .fit)
            Picker(selection: .constant(0), label: EmptyView()) {
                Text("Horizontal").tag(0)
                Text("Vertical").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
            Circle()
                .frame(width: 100, height: 100)
            Spacer()
        }
            .padding(30)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
