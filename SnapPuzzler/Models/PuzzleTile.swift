//
//  PuzzleTile.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 16/03/26.
//

//
//  PuzzleTile.swift
//  SnapPuzzler
//

import Foundation
import UIKit

struct PuzzleTile: Identifiable, Equatable {
    let id: UUID
    let correctIndex: Int
    var currentIndex: Int
    let image: UIImage

    init(correctIndex: Int, currentIndex: Int, image: UIImage) {
        self.id = UUID()
        self.correctIndex = correctIndex
        self.currentIndex = currentIndex
        self.image = image
    }

    var isInCorrectPosition: Bool {
        correctIndex == currentIndex
    }
}
