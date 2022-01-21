//
//  SoraGradient.swift
//  Sora
//
//  Created by Anton Heestand on 2022-01-21.
//  Copyright © 2022 Hexagons. All rights reserved.
//

import Foundation
import CoreData

extension SoraGradient {
    static func sortedFetchRequest() -> NSFetchRequest<SoraGradient> {
        let request: NSFetchRequest<SoraGradient> = SoraGradient.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    static func == (lhs: SoraGradient, rhs: SoraGradient) -> Bool {
        lhs.id! == rhs.id!
    }
}

extension SoraGradient {
    var mainGradient: Main.Gradient? {
        guard let text = gradient else { return nil }
        guard let data = text.data(using: .utf8) else { return nil }
        guard let gradient = try? JSONDecoder().decode(Main.Gradient.self, from: data) else { return nil }
        return gradient
    }
    var direction: Main.Direction? {
        mainGradient?.direction
    }
}
