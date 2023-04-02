//
//  ContentView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var main: Main
    var body: some View {
        ZStack {
            CaptureView(main: main)
            DisplayView(main: main)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(main: Main())
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                ContentView(main: Main())
                    .colorScheme(.dark)
            }
        }
    }
}
