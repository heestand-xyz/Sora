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
        let dir: Main.Direction = gradient.direction
        let ramp = Gradient(colors: gradient.colorStops.map({ $0.color.color }))
        return Group {
            if dir == .horizontal {
                LinearGradient(gradient: ramp,
                               startPoint: .leading,
                               endPoint: .trailing)
            } else if dir == .vertical {
                LinearGradient(gradient: ramp,
                               startPoint: .bottom,
                               endPoint: .top)
            } else if dir == .angle {
                AngularGradient(gradient: ramp,
                                center: .center,
                                angle: Angle(radians: -.pi / 2))
            } else if dir == .radial {
                GeometryReader { geo in
                    RadialGradient(gradient: ramp,
                                   center: .center,
                                   startRadius: 0.0,
                                   endRadius: geo.size.width / 2)
                        .aspectRatio(1.0, contentMode: .fill)
                }
            }
        }
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView(gradient: Main().templateGradient())
    }
}

