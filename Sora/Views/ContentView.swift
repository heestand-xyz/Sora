//
//  ContentView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var sora: Main
    var body: some View {
        Group {
            if sora.state == .main {
                MainView(sora: sora)
            } else if sora.state == .display {
                DisplayView(sora: sora)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(sora: Main())
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                ContentView(sora: Main())
                    .colorScheme(.dark)
            }
        }
    }
}
