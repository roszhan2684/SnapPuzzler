//
//  PuzzleTileView.swift
//  SnapPuzzler
//

import SwiftUI

struct PuzzleTileView: View {
    let tile: PuzzleTile
    let isSelected: Bool

    var body: some View {
        ZStack {
            Image(uiImage: tile.image)
                .resizable()
                .interpolation(.high)
                .antialiased(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Rectangle()
                .stroke(
                    isSelected ? Theme.neonCoral : Color.white.opacity(0.35),
                    lineWidth: isSelected ? 3 : 0.6
                )
        }
        .clipped()
        .contentShape(Rectangle())
    }
}
