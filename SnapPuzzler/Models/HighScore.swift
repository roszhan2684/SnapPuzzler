//
//  HighScore.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation

struct HighScore: Codable, Identifiable {
    let id: UUID
    let gridSize: Int
    let bestTime: Double
    let bestMoves: Int?
    let date: Date

    init(
        id: UUID = UUID(),
        gridSize: Int,
        bestTime: Double,
        bestMoves: Int? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.gridSize = gridSize
        self.bestTime = bestTime
        self.bestMoves = bestMoves
        self.date = date
    }
}
