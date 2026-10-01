//
//  HighScoresViewModel.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation
import Combine

final class HighScoresViewModel: ObservableObject {
    @Published var scores: [HighScore] = []

    private let storageService: ScoreStorageService

    init(storageService: ScoreStorageService = ScoreStorageService()) {
        self.storageService = storageService
        loadScores()
    }

    func loadScores() {
        scores = storageService.loadScores().sorted { $0.gridSize < $1.gridSize }
    }

    func bestTime(for gridSize: Int) -> String {
        guard let score = scores.first(where: { $0.gridSize == gridSize }) else {
            return "--"
        }
        return String(format: "%.2f sec", score.bestTime)
    }

    func bestMoves(for gridSize: Int) -> String {
        guard let score = scores.first(where: { $0.gridSize == gridSize }),
              let bestMoves = score.bestMoves
        else {
            return "--"
        }
        return "\(bestMoves)"
    }
}
