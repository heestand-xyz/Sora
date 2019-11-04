//
//  PhotoView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct PhotoView: View {
    let photo: Main.Photo
    var body: some View {
        GeometryReader { geo in
            GeometryReader { _ in
                Image(uiImage: self.photo.photoImage)
                    .resizable()
                    .scaledToFill()
            }
                .mask(ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: .displayPhotoCornerRadius)
                    Rectangle()
                        .frame(height: .displayPhotoCornerRadius)
                }
            )
        }
        .aspectRatio(.displayPhotoAspectRatio, contentMode: .fit)
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(photo: Main().photos.first!)
    }
}
