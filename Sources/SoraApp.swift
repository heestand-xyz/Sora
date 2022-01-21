//
//  SoraApp.swift
//  Sora
//
//  Created by Anton Heestand on 2022-01-21.
//  Copyright © 2022 Hexagons. All rights reserved.
//

import SwiftUI

@main
struct SoraApp: App {
    
    @StateObject var main = Main()
        
    var body: some Scene {
        WindowGroup {
            ContentView(main: main)
        }
    }
}
