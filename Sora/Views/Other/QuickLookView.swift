//
//  QuickLookView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-10.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import QuickLook

struct QuickLookView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var items: [URL]
    var body: some View {
        VStack {
            QuickLook(items: $items)
            Divider()
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }
        }
    }
}

struct QuickLook: UIViewControllerRepresentable {

    @Binding var items: [URL]

    func makeUIViewController(context: UIViewControllerRepresentableContext<QuickLook>) -> QLPreviewController {
        let quickLook = QLPreviewController()
        quickLook.dataSource = context.coordinator
        return quickLook
    }

    func updateUIViewController(_ uiViewController: QLPreviewController,
                                context: UIViewControllerRepresentableContext<QuickLook>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(items: $items)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        
        let items: Binding<[URL]>
        
        init(items: Binding<[URL]>) {
            self.items = items
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            items.wrappedValue.count
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            items.wrappedValue[index] as QLPreviewItem
        }
        
    }
    
}
