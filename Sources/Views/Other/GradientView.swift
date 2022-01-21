//
//  GradientView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct GradientView: View {
    let gradient: Main.Gradient
    var body: some View {
        let direction: Main.Direction = gradient.direction
        let ramp = Gradient(colors: gradient.colorStops.map({ $0.color.color }))
        return Group {
            switch direction {
            case .horizontal:
                LinearGradient(gradient: ramp,
                               startPoint: .leading,
                               endPoint: .trailing)
            case .vertical:
                LinearGradient(gradient: ramp,
                               startPoint: .bottom,
                               endPoint: .top)
            case .angle:
                AngularGradient(gradient: ramp,
                                center: .center,
                                angle: Angle(radians: -.pi / 2))
            case .radial:
                GeometryReader { geo in
                    RadialGradient(gradient: ramp,
                                   center: .center,
                                   startRadius: 0.0,
                                   endRadius: geo.size.width / 2)
                }
            }
        }
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView(gradient: Main().templateGradient(in: .vertical))
    }
}

