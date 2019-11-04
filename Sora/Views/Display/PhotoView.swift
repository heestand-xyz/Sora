//
//  PhotoView.swift
//  Sora
//
//  Created by Hexagons on 2019-11-04.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI

struct PhotoView: View {
    let photo: SoraPhoto
    var body: some View {
        Image(uiImage: photo.photoImage)
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .cornerRadius(.displayPhotoCornerRadius)
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(photo: Main().photos.first!)
    }
}
