//
//  DisplayPhoto.swift
//  Sora
//
//  Created by Hexagons on 2019-11-09.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
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
    
    func loadNextDisplayPhoto(in way: Way) {
        guard let currentPhoto = displayPhoto else { return }
        let currentIndex = photos.firstIndex(of: currentPhoto)!
        let nextIndex = currentIndex + way.extra
        guard nextIndex >= 0 && nextIndex < photos.count else { return }
        nextDisplayPhoto = photos[nextIndex]
        nextDisplayFraction = 0.0
        nextDisplayWay = way
    }
    
    func display(photo: Photo, from frame: CGRect) {
        displayFrame = frame
        displayPhoto = photo
        animate(for: kAnimationSeconds, ease: .easeOut, animate: { fraction in
            self.displayFraction = fraction
        }) {}
    }
    
    func hidePhoto() {
        animate(for: kAnimationSeconds, ease: .easeOut, animate: { fraction in
            self.displayFraction = 1.0 - fraction
        }) {
            self.displayPhoto = nil
            self.displayFrame = nil
        }
    }
    
    func reDragPhoto() {
        if let timer = animationTimer {
            timer.invalidate()
        }
    }
    
    func reDisplayPhoto() {
        let currentFraction = displayFraction
        guard currentFraction != 1.0 else { return }
        animate(for: kAnimationSeconds * (1.0 - currentFraction), ease: .easeOut, animate: { fraction in
            self.displayFraction = currentFraction * (1.0 - fraction) + fraction
        }) {}
    }
    
    func reHidePhoto() {
        let currentFraction = displayFraction
        guard currentFraction != 0.0 else { return }
        animate(for: kAnimationSeconds * currentFraction, ease: .easeOut, animate: { fraction in
            self.displayFraction = currentFraction * (1.0 - fraction)
        }) {
            self.displayPhoto = nil
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
        guard let photo = nextDisplayPhoto else { return }
        displayPhoto = photo
        if state == .grid {        
            displayFrame = gridFrames[photo.id] ?? .zero
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
        nextDisplayPhoto = nil
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
    
}
