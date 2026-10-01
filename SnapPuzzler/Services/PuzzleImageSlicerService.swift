//
//  PuzzleImageSlicerService.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 16/03/26.
//

//
//  PuzzleImageSlicerService.swift
//  SnapPuzzler
//

import Foundation
import UIKit
import CoreGraphics

final class PuzzleImageSlicerService {
    func makePuzzleBoard(from image: UIImage, gridSize: Int) -> PuzzleBoard? {
        guard let cgImage = image.cgImage else { return nil }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        let tileWidth = width / CGFloat(gridSize)
        let tileHeight = height / CGFloat(gridSize)

        var tiles: [PuzzleTile] = []

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let index = row * gridSize + col

                let cropRect = CGRect(
                    x: CGFloat(col) * tileWidth,
                    y: CGFloat(row) * tileHeight,
                    width: tileWidth,
                    height: tileHeight
                ).integral

                guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
                    return nil
                }

                let tileImage = UIImage(cgImage: croppedCGImage)

                let tile = PuzzleTile(
                    correctIndex: index,
                    currentIndex: index,
                    image: tileImage
                )

                tiles.append(tile)
            }
        }

        var shuffledTiles = tiles
        shuffleTiles(&shuffledTiles)

        return PuzzleBoard(gridSize: gridSize, tiles: shuffledTiles)
    }

    private func shuffleTiles(_ tiles: inout [PuzzleTile]) {
        let shuffledOrder = Array(0..<tiles.count).shuffled()

        for index in tiles.indices {
            tiles[index].currentIndex = shuffledOrder[index]
        }

        let solved = tiles.allSatisfy { $0.correctIndex == $0.currentIndex }
        if solved, tiles.count >= 2 {
            let first = tiles[0].currentIndex
            tiles[0].currentIndex = tiles[1].currentIndex
            tiles[1].currentIndex = first
        }
    }
}
