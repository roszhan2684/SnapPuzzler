//
//  Theme.swift
//  SnapPuzzler
//

import SwiftUI

enum Theme {
    static let spaceBlack = Color(red: 18 / 255, green: 19 / 255, blue: 19 / 255)
    static let neonCoral = Color(red: 255 / 255, green: 96 / 255, blue: 68 / 255)

    static let backgroundGradient = LinearGradient(
        colors: [spaceBlack, spaceBlack.opacity(0.92)],
        startPoint: .top,
        endPoint: .bottom
    )
}

enum ThemeFont {
    static func title(_ size: CGFloat) -> Font {
        .custom("Didot", size: size)
    }

    static func body(_ size: CGFloat) -> Font {
        .custom("Avenir Next", size: size)
    }
}
