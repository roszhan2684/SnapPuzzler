//
//  PuzzleBoard.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 16/03/26.
//

//
//  PuzzleBoard.swift
//  SnapPuzzler
//

import Foundation

struct PuzzleBoard {
    let gridSize: Int
    var tiles: [PuzzleTile]

    var isSolved: Bool {
        tiles.allSatisfy { $0.correctIndex == $0.currentIndex }
    }

    mutating func swapTiles(first: PuzzleTile, second: PuzzleTile) {
        guard
            let firstIndex = tiles.firstIndex(where: { $0.id == first.id }),
            let secondIndex = tiles.firstIndex(where: { $0.id == second.id })
        else {
            return
        }

        let firstCurrent = tiles[firstIndex].currentIndex
        let secondCurrent = tiles[secondIndex].currentIndex

        tiles[firstIndex].currentIndex = secondCurrent
        tiles[secondIndex].currentIndex = firstCurrent
    }

    func tileAtCurrentIndex(_ index: Int) -> PuzzleTile? {
        tiles.first(where: { $0.currentIndex == index })
    }
}
