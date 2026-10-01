//
//  FrozenBackgroundView.swift
//  SnapPuzzler
//

import SwiftUI

struct FrozenBackgroundView: View {
    let image: UIImage

    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .allowsHitTesting(false)
    }
}
