//
//  FrozenCapturedFrameView.swift
//  SnapPuzzler
//

import SwiftUI

struct FrozenCapturedFrameView: View {
    let image: UIImage
    let frameRect: FrameRect

    var body: some View {
        GeometryReader { geometry in
            if frameRect.isVisible {
                let width = frameRect.size.width * geometry.size.width
                let height = frameRect.size.height * geometry.size.height
                let centerX = frameRect.center.x * geometry.size.width
                let centerY = frameRect.center.y * geometry.size.height

                Image(uiImage: image)
                    .resizable()
                    .frame(width: width, height: height)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .position(x: centerX, y: centerY)
            }
        }
        .allowsHitTesting(false)
    }
}
