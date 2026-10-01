//
//  PuzzleBoardView.swift
//  SnapPuzzler
//

import SwiftUI

struct PuzzleBoardView: View {
    let board: PuzzleBoard
    let frameRect: FrameRect
    let selectedTile: PuzzleTile?
    let onTileTap: (PuzzleTile) -> Void

    var body: some View {
        GeometryReader { geometry in
            if frameRect.isVisible {
                let boardWidth = frameRect.size.width * geometry.size.width
                let boardHeight = frameRect.size.height * geometry.size.height
                let centerX = frameRect.center.x * geometry.size.width
                let centerY = frameRect.center.y * geometry.size.height

                let tileWidth = boardWidth / CGFloat(board.gridSize)
                let tileHeight = boardHeight / CGFloat(board.gridSize)

                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<board.gridSize, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<board.gridSize, id: \.self) { col in
                                    let index = row * board.gridSize + col

                                    if let tile = board.tileAtCurrentIndex(index) {
                                        PuzzleTileView(
                                            tile: tile,
                                            isSelected: selectedTile?.id == tile.id
                                        )
                                        .frame(width: tileWidth, height: tileHeight)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            onTileTap(tile)
                                        }
                                    } else {
                                        Color.clear
                                            .frame(width: tileWidth, height: tileHeight)
                                    }
                                }
                            }
                        }
                    }

                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Theme.neonCoral.opacity(0.9), lineWidth: 2)
                }
                .frame(width: boardWidth, height: boardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .position(x: centerX, y: centerY)
            }
        }
        .allowsHitTesting(true)
    }
}
