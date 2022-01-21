//
//  Main+App.swift
//  Sora
//
//  Created by Anton Heestand on 2022-01-21.
//  Copyright © 2022 Hexagons. All rights reserved.
//

import UIKit

extension Main {
    
    func listenToApp() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func didBecomeActive() {
        go(active: true)
    }
    
    @objc func willResignActive() {
        go(active: false)
    }
    
    @objc func willEnterForeground() {}
    
    @objc func didEnterBackground() {}
    
    func go(active: Bool) {
        if state == .capture {
            bypass = !active
        }
    }
}
