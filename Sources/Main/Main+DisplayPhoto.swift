//
//  DisplayPhoto.swift
//  Sora
//
//  Created by Hexagons on 2019-11-09.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import CoreGraphics

extension Main {
    
    enum Way {
        case left
        case right
        var extra: Int {
            switch self {
            case .left: return -1
            case .right: return 1
            }
        }
    }
    
    func loadNextDisplaySoraGradient(in way: Way) {
        guard let sg = displaySoraGradient else { return }
        guard let sgs = soraGradients else { return }
        let currentIndex = sgs.firstIndex(of: sg)!
        let nextIndex = currentIndex + way.extra
        guard nextIndex >= 0 && nextIndex < sgs.count else { return }
        nextDisplaySoraGradient = sgs[nextIndex]
        nextDisplayFraction = 0.0
        nextDisplayWay = way
    }
    
    func display(sg: SoraGradient, from frame: CGRect) {
        displayFrame = frame
        displaySoraGradient = sg
        animate(for: kAnimationSeconds, ease: .easeOut, animate: { fraction in
            self.displayFraction = fraction
        }) {}
    }
    
    func hideSoraGradient() {
        animate(for: kAnimationSeconds, ease: .easeOut, animate: { fraction in
            self.displayFraction = 1.0 - fraction
        }) {
            self.displaySoraGradient = nil
            self.displayFrame = nil
        }
    }
    
    func reDragSoraGradient() {
        if let timer = animationTimer {
            timer.invalidate()
        }
    }
    
    func reDisplaySoraGradient() {
        let currentFraction = displayFraction
        guard currentFraction != 1.0 else { return }
        animate(for: kAnimationSeconds * (1.0 - currentFraction), ease: .easeOut, animate: { fraction in
            self.displayFraction = currentFraction * (1.0 - fraction) + fraction
        }) {}
    }
    
    func reHideSoraGradient() {
        let currentFraction = displayFraction
        guard currentFraction != 0.0 else { return }
        animate(for: kAnimationSeconds * currentFraction, ease: .easeOut, animate: { fraction in
            self.displayFraction = currentFraction * (1.0 - fraction)
        }) {
            self.displaySoraGradient = nil
            self.displayFrame = nil
        }
    }
    
    func reNext() {
        guard let currentFraction = nextDisplayFraction else { self.reNextPost(); reReset(); return }
        guard currentFraction != 1.0 else { self.reNextPost(); reReset(); return }
        animate(for: kAnimationSeconds * (1.0 - currentFraction), ease: .easeOut, animate: { fraction in
            self.nextDisplayFraction = currentFraction * (1.0 - fraction) + fraction
        }) {
            self.reNextPost()
            self.reReset()
        }
    }
    
    func reNextPost() {
        guard let sg = nextDisplaySoraGradient else { return }
        displaySoraGradient = sg
        if state == .grid {        
            displayFrame = gridFrames[sg.id!] ?? .zero
        }
    }
    
    func reBack() {
        guard let currentFraction = nextDisplayFraction else { reReset(); return }
        guard currentFraction != 0.0 else { reReset(); return }
        animate(for: kAnimationSeconds * currentFraction, ease: .easeOut, animate: { fraction in
            self.nextDisplayFraction = currentFraction * (1.0 - fraction)
        }) {
            self.reReset()
        }
    }
    
    func reReset() {
        nextDisplaySoraGradient = nil
        nextDisplayFraction = nil
        nextDisplayWay = nil
    }
    
    enum Ease {
        case easeIn
        case easeOut
        case easeInOut
    }
    
    func animate(for seconds: CGFloat, ease: Ease? = nil, animate: @escaping (CGFloat) -> (), done: @escaping () -> ()) {
        if let timer = animationTimer {
            timer.invalidate()
        }
        var index = 0
        let count = Int(seconds / 0.01)
        animationTimer = Timer(timeInterval: 0.01, repeats: true, block: { timer in
            index += 1
            var fraction = CGFloat(index) / CGFloat(count)
            if let ease = ease {
                switch ease {
                case .easeIn:
                    fraction = sin(fraction * .pi / 2 - .pi / 2) + 1.0
                case .easeOut:
                    fraction = sin(fraction * .pi / 2)
                case .easeInOut:
                    fraction = sin(fraction * .pi - .pi / 2) / 2 + 0.5
                }
            }
            animate(fraction)
            if index >= count {
                timer.invalidate()
                self.animationTimer = nil
                done()
            }
        })
        RunLoop.current.add(animationTimer!, forMode: .common)
    }
    
    func copyHex(color: Color) {
        UIPasteboard.general.string = "#\(color.hex)"
    }
    
    func copyRGB(color: Color) {
        let red = Int(round(color.red * 255))
        let green = Int(round(color.green * 255))
        let blue = Int(round(color.blue * 255))
        UIPasteboard.general.string = "\(red) \(green) \(blue)"
    }
    
}
