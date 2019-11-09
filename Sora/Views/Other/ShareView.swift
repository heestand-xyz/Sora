//
//  ShareView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-05.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct ShareView: UIViewControllerRepresentable {

    @Binding var items: [Any]

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareView>) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ShareView>) {}

}
