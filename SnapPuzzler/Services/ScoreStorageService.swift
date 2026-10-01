//
//  ScoreStorageService.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation

final class ScoreStorageService {
    private let key = "snappuzzler.highscores"

    func loadScores() -> [HighScore] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        do {
            return try JSONDecoder().decode([HighScore].self, from: data)
        } catch {
            print("Failed to decode high scores: \(error)")
            return []
        }
    }

    func saveScores(_ scores: [HighScore]) {
        do {
            let data = try JSONEncoder().encode(scores)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to encode high scores: \(error)")
        }
    }

    func updateBestScore(gridSize: Int, newTime: Double, newMoves: Int?) {
        var scores = loadScores()

        if let index = scores.firstIndex(where: { $0.gridSize == gridSize }) {
            let existing = scores[index]
            var bestTime = existing.bestTime
            var bestMoves = existing.bestMoves
            var didUpdate = false

            if newTime < bestTime {
                bestTime = newTime
                didUpdate = true
            }

            if let newMoves {
                if let currentMoves = bestMoves {
                    if newMoves < currentMoves {
                        bestMoves = newMoves
                        didUpdate = true
                    }
                } else {
                    bestMoves = newMoves
                    didUpdate = true
                }
            }

            if didUpdate {
                scores[index] = HighScore(
                    id: existing.id,
                    gridSize: gridSize,
                    bestTime: bestTime,
                    bestMoves: bestMoves,
                    date: Date()
                )
            }
        } else {
            scores.append(
                HighScore(
                    gridSize: gridSize,
                    bestTime: newTime,
                    bestMoves: newMoves,
                    date: Date()
                )
            )
        }

        saveScores(scores)
    }
}
