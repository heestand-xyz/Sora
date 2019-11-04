//
//  DisplayView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct DisplayView: View {
    @ObservedObject var sora: Main
    var body: some View {
        ZStack {
            VStack {
                GradientTemplateView(sora: self.sora)
                    .aspectRatio(1.0, contentMode: .fit)
                    .mask(Circle())
                    .padding(30)
                Spacer()
            }
            
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(sora: Main())
    }
}
